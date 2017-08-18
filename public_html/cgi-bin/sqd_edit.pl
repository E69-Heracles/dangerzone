#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();

$|=1; # hot output

my @row;
my $dbh;
my $sth;

# sqd data
my $hlname="";
my $pwd="";
my $sqd_id=0;
my $sqd_name="";
my $sqd_pref="";
my $sqd_side=0;
my $co_hlname="";
my $co_email="";
my $xo_hlname="";
my $xo_email="";
my $xo_allowed=0;
my $sqd_web="";
my $sqd_logo="";
my $co_pwd="";
my $auth_code="";
my $succeed=1;

# TO DO: CHECK, review sizes of string to not overflow DB tables strings

sub print_login() {
    print <<Login;

    <form method="POST" action="/cgi-bin/sqd_edit.pl">
    <table>
      <tr><td align="right">Nombre (HL nick): </td><td><input type="text" size="16" name="hlname"></td></tr>
      <tr><td align="right">Password : </td><td><input type="password" size="16" name="pwd"></td></tr>
      <tr><td></td><td><input type=submit name="accion" value="Send"></td></tr>
    </table>
    </form>

Login
    ; # emacs related
}

sub print_old_data (){

    $hlname=$in{'hlname'};
    $pwd=$in{'pwd'};
    $hlname=~ s/^ *//g;
    $hlname=~ s/ *$//g;
    if ($hlname =~ m/ / || $hlname eq "" || $pwd eq "" ){ 
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Name or password not valid<br>\n";
	print &print_end_html();
	return(0);
    }
    
    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    
    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    #verify pwd
    $sth = $dbh->prepare("SELECT password  FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $pwd) {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Name or password not valid<br>\n";
	return(0);
    }
    
    #find squadron ID using pilot file
    $sth = $dbh->prepare("SELECT in_sqd_id,in_sqd_name FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    $sqd_id=$row[0];
    $sqd_name=$row[1];
    
    $sth = $dbh->prepare("SELECT coname,xoname,allowxoedit FROM $sqd_file_tbl WHERE id=?");
    $sth->execute($sqd_id);
    @row = $sth->fetchrow_array;
    $sth->finish;

    if ($row[0] ne $hlname) {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Only the CO of squadron is allowed to edit squad data.<br>\n";
	return(0);
    }

    $sth = $dbh->prepare("SELECT sqdname,sqdname8,coname,xoname,allowxoedit,sqdweb,sqdlogo FROM $sqd_file_tbl WHERE id=?");
    $sth->execute($sqd_id);
    @row = $sth->fetchrow_array;
    $sth->finish;

    $sqd_name=$row[0];
    $sqd_pref=$row[1];
    $co_hlname=$row[2];
    $xo_hlname=$row[3];
    $xo_allowed=$row[4];
    $sqd_web=$row[5];
    $sqd_logo=$row[6];


    print <<Part1;
    </div>
<FORM METHOD="POST" ACTION="/cgi-bin/sqd_edit.pl"> 
<table>
<tr><td align="right">Squadron name &nbsp; </td>
    <td><input type="text" size="40" name="sqdname" value="$sqd_name"></td></tr>
<tr><td align="right">Squadron prefix <font color="c00000">*</font></td>
    <td><input type="text" size="8" name="sqdname8" value="$sqd_pref" readonly></td></tr>
<tr><td align="right">CO name &nbsp </td>    
    <td><input type="text" size="20" name="coname" value="$co_hlname" readonly></td></tr>
Part1
    ;

    print "<tr><td align=\"right\">New CO &nbsp; </td>\n";
    print "<td><select name=\"newconame\" size=\"1\">\n";

    $sth = $dbh->prepare("SELECT hlname FROM $pilot_file_tbl WHERE sqd_accepted='1' AND in_sqd_name=? ");
    $sth->execute($sqd_pref);

    while ( @row = $sth->fetchrow_array ) {
	if ($row[0] eq $hlname) {
	    print "<option selected value=\"$row[0]\">$row[0]</option>\n";
	}
	else {
	    print "<option value=\"$row[0]\">$row[0]</option>\n";
	}
    }
    $sth->finish;


    print "<tr><td align=\"right\">XO name &nbsp; </td>\n";
    print "<td><select name=\"xoname\" size=\"1\">\n";
    if ($xo_hlname eq "") {
	print "<option selected value=\"\">---------------</option>\n";
    }
    else {
	print "<option value=\"\">---------------</option>\n";
    }

    $sth = $dbh->prepare("SELECT hlname FROM $pilot_file_tbl WHERE sqd_accepted='1' AND in_sqd_name=? ");
    $sth->execute($sqd_pref);

    while ( @row = $sth->fetchrow_array ) {
	print "<!-- $row[0] -->\n";
	if ($row[0] eq $xo_hlname) {
	    print "<option selected value=\"$row[0]\">$row[0]</option>\n";
	}
	else {
	    print "<option value=\"$row[0]\">$row[0]</option>\n";
	}
    }
    $sth->finish;


    print "<tr><td align=\"right\"> &nbsp; XO allowed to admin &nbsp; </td><td><input type=\"checkbox\" name=\"allowedit\""; 
    if ($xo_allowed==1){ print "checked";}
    print "></td><tr>\n";

    print <<Part2;
<tr><td align="right">Squadron Web page &nbsp; </td>
    <td><input type="text"  size="50" name="weburl" value=$sqd_web></td></tr>
<tr><td align="right">Squadron image link &nbsp; </td>
    <td><input type="text" size="50" name="logourl" value=$sqd_logo></td></tr>
<tr><td align="right">Your Password &nbsp; </td>
    <td><input type="password" size="15" name="copwd"></td></tr>
<tr><td></td>
    <td><input type=submit name=accion value="Save"></td></tr>

</table>
</form>
<br> &nbsp; &nbsp; &nbsp;
    The fields with an (<font color="c00000">*</font>) are read only and cant be changed.<br>

Part2
    ;
}


sub update_data(){

    $sqd_name=$in{'sqdname'};
    $sqd_pref=$in{'sqdname8'};
    $co_hlname=$in{'coname'};
    $new_co_hlname=$in{'newconame'};
    $co_email="";
    $xo_hlname=$in{'xoname'};
    $xo_email="";
    $xo_allowed=$in{'allowedit'};
    if ($xo_hlname ne "" && $xo_allowed eq "on") {$xo_allowed=1;}
    else {$xo_allowed=0;}
    $sqd_web=$in{'weburl'};
    $sqd_logo=$in{'logourl'};
    $co_pwd=$in{'copwd'};

    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    
    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    #verify pwd
    $sth = $dbh->prepare("SELECT password,email FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($co_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $co_pwd) { #pwd no match
	print "<font color=\"red\" size=\"+1\">ERROR:</font>  CO password is incorrect<br>\n";
	return(0);
    }
    $co_email=$row[1];
    
    # find sqd ID using pilot file
    $sth = $dbh->prepare("SELECT in_sqd_id FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($co_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    $sqd_id=$row[0];
    
    $sth = $dbh->prepare("SELECT coname,sqdname8 FROM $sqd_file_tbl WHERE id=?");
    $sth->execute($sqd_id);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $co_hlname) {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Only the CO of squadron is allowed to edit squadron data. Hacking?<br>\n";
	return(0);
    }
    if ($row[1] ne $sqd_pref) {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> You are the  CO of $row[1] and you cant edit $sqd_pref - Hacking?<br>\n";
	return(0);
    }
    
    $sqd_name=~ s/^ *//g;
    $sqd_name=~ s/ *$//g;
    if ($sqd_name eq ""){
	print "You didnt fill the squad name<br>\n";
	$succeed=0;
    }
    
    $sqd_pref=~ s/^ *//g;
    $sqd_pref=~ s/ *$//g;
    if ($sqd_pref eq ""){
	print "You didnt fill the squad prefix <br>\n";
	$succeed=0;
    }
    

    if ($new_co_hlname ne ""){
	#verifiy new CO
	$sth = $dbh->prepare("SELECT in_sqd_id,sqd_accepted,email FROM $pilot_file_tbl WHERE hlname=?");
	$sth->execute($new_co_hlname);
	@row = $sth->fetchrow_array;
	$sth->finish;
	if ($row[0] ne $sqd_id) {
	    print "The selected CO is not member of sqd. Hacking?<br>\n";
	    $succeed=0;
	}
	if ($row[1] != 1) {
	    print "The selected CO has not yet been accepted in squadron. Hacking?<br>\n";
	    $succeed=0;
	}
	$co_hlname=$new_co_hlname;
	$co_email=$row[2];
    }


    if ($xo_hlname ne ""){
	#verify new XO
	$sth = $dbh->prepare("SELECT in_sqd_id,sqd_accepted,email FROM $pilot_file_tbl WHERE hlname=?");
	$sth->execute($xo_hlname);
	@row = $sth->fetchrow_array;
	$sth->finish;
	if ($row[0] ne $sqd_id) {
	    print "The selected XO is not member of sqd. Hacking?<br>\n";
	    $succeed=0;
	}
	if ($row[1] != 1) {
	    print "The selected XO has not yet been accepted in squadron. Hacking?<br>\n";
	    $succeed=0;
	}
	$xo_email=$row[2];
    }
    
    $sqd_web=~ s/ //g;
    $sqd_web=~ s/\'//g;
    $sqd_web=~ s/\`//g;
    $sqd_web=~ s/\"//g;
    $sqd_web=~ s/>//g;
    $sqd_web=~ s/<//g;
    if ($sqd_web eq ""){ 
	print "<font color=\"red\" size=\"+1\">Warning:</font>  You didnt suply a squad home page.<br>\n";
    }
    
    $sqd_logo=~ s/ //g;
    $sqd_logo=~ s/\'//g;
    $sqd_logo=~ s/\`//g;
    $sqd_logo=~ s/\"//g;
    $sqd_logo=~ s/>//g;
    $sqd_logo=~ s/<//g;
    if ($sqd_logo eq ""){ 
	print "<font color=\"red\" size=\"+1\">Warning:</font>  You didnt suply a squad logo link.<br>\n";
    }


    # if there are error, end here
    if (!$succeed) {
	return(0);
    }

    if ($co_hlname eq $xo_hlname ) { 
	print "<font color=\"red\" size=\"+1\">Warning:</font> The CO and XO must be diferent pilots. Field XO cleared.<br>\n";
	$xo_hlname="";
	$xo_email="";
	$xo_allowed=0;
    }
    
    $dbh->do("Update  $sqd_file_tbl SET sqdname = \"$sqd_name\", coname =\"$co_hlname\", comail = \"$co_email\", xoname = \"$xo_hlname\", xomail = \"$xo_email\", allowxoedit = \"$xo_allowed\", sqdweb = \"$sqd_web\", sqdlogo = \"$sqd_logo\" WHERE sqdname8=\"$sqd_pref\"");
    
    open (PILOT_LOG, ">>Pilot_log.txt") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
    print PILOT_LOG  "W ". scalar(localtime(time)) ." $co_hlname edited squadron $sqd_pref\n";
    close (PILOT_LOG);

    print "Data updated.<br>\n";
    print "<br><br>Return to <a href=\"/mng_sqd.php\">register page</a><br>\n";
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

my $accion=$in{'accion'};
if ($accion eq "") { 
    print_login(); 
}
elsif ($accion eq "Send") { #<input type=submit name=accion value=enviar>
    print_old_data();
}
elsif ($accion eq "Save") { #<input type=submit name=accion value=guardar>
    update_data();
}
else { # unknow form action
    print "Error :) <br>\n";
}
print &print_end_html();
exit (0);

# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
