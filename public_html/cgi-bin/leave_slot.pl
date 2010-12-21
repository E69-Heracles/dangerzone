#!/usr/bin/perl

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();

$|=1; # hot output


sub print_login() {
    print <<Login;
    <form method="POST" action="/cgi-bin/leave_slot.pl">
    <table>
      <tr><td colspan="2" align="center"><input type="hidden" name="slot" value="$slot">
	  Confirm <font color="red">deletion </font> of  $slot slot.</td></tr>

      <tr><td align="right">Name: </td><td><input type="text" size="16" name="hlname" value="$hlname"></td></tr>
      <tr><td align="right">Password: </td><td><input type="password" size="16" name="pwd" value="$pwd"></td></tr>
      <tr><td></td><td><input type=submit name="accion" value="Delete"></td></tr>
    </table>
    </form>

Login
    ; # emacs related
}


# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------

print &PrintHeader;
print &print_start_html();

# Limit upload size
$cgi_lib::maxdata = 512;
$cgi_lib::maxdata = 512; # repeat to avoid used only once warning 

&ReadParse(%in); # Read data

$accion=$in{'accion'};
$slot=$in{'slot'};             # <td><input type="hidden" name="slot" value="BW1BR">

if ($slot !~ m/BW[123456]([B|R]R)?/) {
    print "<font color=\"red\" size=\"+1\"> Error: Invalid or Unknow Slot. </font><br>\n";
    print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
    print &print_end_html();
    exit(0);
}

if ($accion eq "") { 

    # read cookie
    my @rawCookies = split (/; /,$ENV{'HTTP_COOKIE'});
    foreach(@rawCookies){
	($key, $val) = split (/=/,$_);
	if ($key eq "badc_user"){
	    ($hlname,$pwd) = split (/ /,$val);
	}
    } 
    print_login(); #ask  name and  pwd
}
elsif ($accion eq "Delete") {          #<input type=submit name=accion value=enviar>
    # remove stuff

    $hlname=$in{'hlname'};             # <td>Name: <input type="TEXT" name="hlname" size="20" value=""> </td>
    $pwd=$in{'pwd'};                   # <td>Password: <input type="password" name="pwd" size="20" value=""></td>

    my @row;
    my $dbh;
    my $sth;
    
    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    
    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    #verify pwd
    $sth = $dbh->prepare("SELECT password,sqd_army,sqd_accepted  FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $pwd) {
	print "<font color=\"red\" size=\"+1\"> Error: Name or password not valid </font><br>\n";
	print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
	print &print_end_html();
	exit(0);
    }
    $player_army=$row[1];


    $sth = $dbh->prepare("SELECT hlname FROM $host_slots_tbl WHERE slot=?");
    $sth->execute($slot);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ( ($hlname ne $super_user) && ($row[0] ne $hlname)) { # he is not ower of slot 
	#we will only allow host owners (GAME HOST) to delete requests from any same side
	if ($slot =~ m/BR|RR/) { # if it is a request to be deleted ... 
	    my $parent_slot = $slot; 
	    $parent_slot=~ s/RR//; # we change to parent slot
	    $parent_slot=~ s/BR//; # we change to parent slot
	    $sth = $dbh->prepare("SELECT hlname FROM $host_slots_tbl WHERE slot=?");
	    $sth->execute($parent_slot);
	    @row = $sth->fetchrow_array;
	    $sth->finish;
	    if (!($row[0] eq $hlname)){
		print "<font color=\"red\" size=\"+1\"> Error(2): You are not allowed to delet that slot. </font><br>\n";
		print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
		print &print_end_html();
		exit(0);
	    }
	}
	else { # it is NOT a side request to be deleted and he is not owner of requested slot to be deleted
	    print "<font color=\"red\" size=\"+1\"> Error(1): You are not allowed to delet that slot.</font><br>\n";
	    print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
	    print &print_end_html();
	    exit(0);
	}
    }
    
    # update status related to this deletion
    # if it is a side request slot -> set host to waiting
    # if it is a host slot -> delete all

    if ($slot =~ m/BR|RR/) {
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '', epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"$slot\"");
	$slot =~ s/BR//;
	$slot =~ s/RR//;
	$dbh->do("UPDATE $host_slots_tbl SET  status = 1  WHERE slot=\"$slot\"");
    }
    else {
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=0,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"$slot\"");
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=1,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$slot."RR\"");
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=2,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$slot."BR\"");
    }
    
    print "<font color=\"green\">Slot now is free.</font><br>\n";


    # we can check expired requests, so we "clean DB"
    my $now_epoch = time;
    my @bw_slots = ("BW1","BW2","BW3","BW4","BW5","BW6");
    
    foreach my $look (@bw_slots) {
	$sth = $dbh->prepare("SELECT epoca FROM $host_slots_tbl WHERE slot=?");
	$sth->execute($look);
	@row = $sth->fetchrow_array;
	$sth->finish;
	if ($row[0] < $now_epoch) { # si caduco
	    $dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=0,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"$look\"");
	    $dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=1,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$look."RR\"");
	    $dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=2,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$look."BR\"");
	}
    }
}
else { # unkown action
    print "Error :) <br>\n";
}

    print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
    print "</center>\n";
    
print &print_end_html();
exit (0);

# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;

$pilot_file_tbl=$pilot_file_tbl;
$super_user=$super_user;
$player_army=$player_army;

