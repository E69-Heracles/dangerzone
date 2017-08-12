#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();

$|=1; # hot output

my @row;
my $dbh;
my $sth;

# data
my $adm_hlname="";
my $adm_pwd="";
my $boot_pilot="";

my $sqd_id=0;
my $sqd_pref="";




sub update_data(){

    $adm_hlname=$in{'hlname'};
    $adm_pwd=$in{'pwd'};
    $boot_pilot=$in{'boot_pilot'};

    # special case, when calling from leave_squadron.php
    # boot_name is set to "self remove"
    if ($boot_pilot eq "self remove") {
	$boot_pilot=$adm_hlname;
    }

    $adm_hlname=~ s/^ *//g;
    $adm_hlname=~ s/ *$//g;
    $boot_pilot=~ s/^ *//g;
    $boot_pilot=~ s/ *$//g;
    if ($boot_pilot =~ m/ / || $boot_pilot eq "" || $adm_hlname  =~ m/ / || $adm_hlname eq "" ) {
	print "<font color=\"red\" size=\"+1\">ERROR:</font>  Null name. <br>\n";
	return(0);
    }
    if ($adm_pwd eq "") {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Null password.<br>\n";
	return(0);
    }

    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");

    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    #verify Password for adm_hlname
    $sth = $dbh->prepare("SELECT password FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($adm_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $adm_pwd) { #pwd no match
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Your password is incorrect<br>\n";
	return(0);
    }

    # html special chars on $boot_pilot
    $html_boot_pilot=$boot_pilot;
    $html_boot_pilot =~ s/</&lt;/g;
    $html_boot_pilot =~ s/>/&gt;/g;
    
    # get boot_pilot sqadron
    $sth = $dbh->prepare("SELECT in_sqd_id,in_sqd_name,sqd_accepted FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($boot_pilot);
    @row = $sth->fetchrow_array;
    $sth->finish;
    $sqd_id=$row[0];
    $sqd_pref=$row[1];

    # html special chars on $sqd_pref
    $html_sqd_pref=$sqd_pref;
    $html_sqd_pref =~ s/</&lt;/g;
    $html_sqd_pref =~ s/>/&gt;/g;

    if ($row[2] == 0) { # was not accepted in squadron.
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The pilot $html_boot_pilot was not active pilot in squadron.<br><br>\n";
	if ($adm_hlname ne $boot_pilot) {  
	    print "Try use <b>reject aplication</b> form, from squad admin menu.<br>\n";
	    print "Aditionally you shuld never see this message. Hacking Forms?.<br>\n";
	}
	else {
	    print " You currentlly have a pending request for squadron $html_sqd_pref.<br> If you want to apply to a different squadron than $html_sqd_pref,<br> just go to <b>join squadron</b> and fill a new request.<br>\n";
	}
	
	return(0);
    }

 
    if ($adm_hlname ne $boot_pilot) {  

	# if is not himself, check admin sqd_id match boot_pilot sqd_id
	$sth = $dbh->prepare("SELECT in_sqd_id,in_sqd_name FROM $pilot_file_tbl WHERE hlname=?");
	$sth->execute($adm_hlname);
	@row = $sth->fetchrow_array;
	$sth->finish;
	if ($row[0] != $sqd_id) { #  admin is in diferent sqd
	    print "<font color=\"red\" size=\"+1\">ERROR:</font> The pilot $html_boot_pilot is not in your squadron!<br>\n";
	    return(0);
	}
    
	# look if admin is a CO or XO with admin rights
	$sth = $dbh->prepare("SELECT coname,xoname,allowxoedit FROM $sqd_file_tbl WHERE id=?");
	$sth->execute($sqd_id);
	@row = $sth->fetchrow_array;
	$sth->finish;
	if (!( 
	       ($row[0] eq $adm_hlname) || 
	       ($row[1] eq $adm_hlname && $row[2] eq "1") )){
	    print "<font color=\"red\" size=\"+1\">ERROR:</font> You do not have access to administration task.<br>\n";
	    return(0);
	}
    }
    
    # if we are here: $sqd_id and $sqd_prefix holds squadron data from  boot_player.
    # it can be itself deleteing from sqd or a valid admin booting pilot from same sqd_id.
    # ... or both things: itself + he is a CO or XO.
    # If boot_pilot == CO : denny action,  make a new CO first.
    # If boot_pilot == XO : clear XO


    # look if boot pilot is a CO or XO
    $sth = $dbh->prepare("SELECT coname,xoname,allowxoedit FROM $sqd_file_tbl WHERE id=?");
    $sth->execute($sqd_id);
    @row = $sth->fetchrow_array;
    $sth->finish;

    if ($row[0] eq $boot_pilot){ # is the CO
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The CO cant leave squadron before leave place to other pilot!<br>\n";
	print "CO must go to <b>Squad Edit</b> and leave CO place to other member, after that, it can leave squadron.<br>\n";
	return(0);
    }
    if ($row[1] eq $boot_pilot){ # is the XO
	$dbh->do("UPDATE $sqd_file_tbl SET  xoname=\"\", allowxoedit= 0 WHERE id=\"$sqd_id\"");
	print "<b>WARNING: </b> $html_boot_pilot was the XO of $html_sqd_pref. XO is now empty.<br>\n";
    }

    print "<h3>$boot_pilot leaving squadron :</h3><br>\n";

    $dbh->do("UPDATE $pilot_file_tbl SET  sqd_army=0, sqd_accepted = 0, in_sqd_id = 1, in_sqd_name =\"NONE\" WHERE hlname=\"$boot_pilot\"");
    print "+ $html_boot_pilot transfered out from  $html_sqd_pref<br>\n";

    # squadron stats reduced because pilot left
    $sth = $dbh->prepare("SELECT  missions, akills, gkills, victorias, points, kia_mia FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($boot_pilot);
    @row = $sth->fetchrow_array;
    $sth->finish;
    $dbh->do("Update  $sqd_file_tbl SET totalpilot = totalpilot - 1, totalmis = totalmis - \"$row[0]\", totalakill = totalakill - \"$row[1]\", totalgkill = totalgkill - \"$row[2]\", totalvict = totalvict - \"$row[3]\", totalpoints = totalpoints - \"$row[4]\", totalkiamia  = totalkiamia - $row[5]   WHERE sqdname8=\"$sqd_pref\"");

    # re-compute by missions sqd stats
    $sth = $dbh->prepare("SELECT totalmis,totalakill,totalgkill,totalpoints,totalkiamia FROM $sqd_file_tbl WHERE id=?");
    $sth->execute($sqd_id);
    @row = $sth->fetchrow_array;
    $sth->finish;

    my $ak_x_mis = 0;
    my $gk_x_mis = 0;
    my $points_x_mis = 0;
    my $kia_x_mis =0;

    if ($row[0]>0) {  # missions >0 
	 $ak_x_mis= $row[1]/$row[0];
	 $gk_x_mis=$row[2]/$row[0];
	 $points_x_mis=$row[3]/$row[0];
	 $kia_x_mis=$row[4]/$row[0];
    }
    $dbh->do("UPDATE $sqd_file_tbl SET ak_x_mis = $ak_x_mis, gk_x_mis = $gk_x_mis, points_x_mis = $points_x_mis, kia_x_mis = $kia_x_mis  WHERE id=\"$sqd_id\"");

    open (PILOT_LOG, ">>Pilot_log.txt") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
    print PILOT_LOG  "L ". scalar(localtime(time)) ." $boot_pilot has leaved $sqd_pref, by request from : $adm_hlname\n";
    close (PILOT_LOG);

    print "+ $html_boot_pilot statistics deleted from squadron $html_sqd_pref <br>\n";
    print "<br>Return to <a href=\"/mng_pilot.php\">register menu</a><br>\n";

}


# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------
print &PrintHeader;
print &print_start_html();

# Limit upload size
$cgi_lib::maxdata = 512; 
$cgi_lib::maxdata = 512; 

&ReadParse(%in); # Read data
update_data();

print &print_end_html();
exit (0);

# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
