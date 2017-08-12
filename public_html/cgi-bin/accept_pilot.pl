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
my $new_pilot="";

my $sqd_id=0;
my $sqd_pref="";


sub update_data(){

    $adm_hlname=$in{'hlname'};
    $adm_pwd=$in{'pwd'};
    $new_pilot=$in{'addpilot'};

    $new_pilot=~ s/^ *//g;
    $new_pilot=~ s/ *$//g;
    if ($new_pilot =~ m/ / || $new_pilot eq "") {
	print "<font color=\"red\" size=\"+1\">ERROR:</font>  Name of pilot to join is empty or not valid <br>\n";
	return(0);
    }

    if ($adm_hlname  =~ m/ / || $adm_hlname eq "") {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Incorrect CO/XO  name.<br>\n";
	return(0);
    }

    if ($adm_pwd eq "") {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> You didnt write your password.<br>\n";
	return(0);
    }


    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");

    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    #verify Passwoed of  adm_hlname
    $sth = $dbh->prepare("SELECT password FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($adm_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $adm_pwd) { #pwd no matchs
	print "<font color=\"red\" size=\"+1\">ERROR:</font>  CO/XO password is incorrect<br>\n";
	return(0);
    }

    #find squadron ID f on adm_hlname pilot file
    $sth = $dbh->prepare("SELECT in_sqd_id,in_sqd_name FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($adm_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    $sqd_id=$row[0];
    $sqd_pref=$row[1];

    # using sqd ID  find CO and XO hlnames and permisions (allow XO edit)
    $sth = $dbh->prepare("SELECT coname,xoname,allowxoedit FROM $sqd_file_tbl WHERE id=?");
    $sth->execute($sqd_id);
    @row = $sth->fetchrow_array;
    $sth->finish;

    if (!( 
	   ($row[0] eq $adm_hlname) || 
	   ($row[1] eq $adm_hlname && $row[2] eq "1") )){
	print "<font color=\"red\" size=\"+1\">ERROR:</font> You do not have acces to administration task.<br>\n";
	return(0);
    }

    # check if new pilot has requested to join (he shuld have same squadron ID)
    $sth = $dbh->prepare("SELECT in_sqd_id,sqd_accepted FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($new_pilot);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $sqd_id) { # new pilot has not correct squadron ID
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The pilot $new_pilot didnt aplyed to your squadron. Hacking?\n";
	return(0);
    }
    if ($row[1] == 1) { # new pilot was already incorporated
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The pilot $new_pilot was already in your squdadron.\n";
	return(0);
    }


    print "<h3>Incorporation of $new_pilot :</h3><br>\n";

    #update new pilot file
    $dbh->do("UPDATE $pilot_file_tbl SET  sqd_accepted = 1 WHERE hlname=\"$new_pilot\"");
    print "+ $new_pilot transfered an accepted to $sqd_pref<br>\n";

    #update squadron stats, adding new pilot stats
    $sth = $dbh->prepare("SELECT  missions, akills, gkills, victorias, points, kia_mia FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($new_pilot);
    @row = $sth->fetchrow_array;
    $sth->finish;
    $dbh->do("Update  $sqd_file_tbl SET totalpilot = totalpilot + 1, totalmis = totalmis + \"$row[0]\", totalakill = totalakill + \"$row[1]\", totalgkill = totalgkill + \"$row[2]\", totalvict = totalvict + \"$row[3]\", totalpoints = totalpoints + \"$row[4]\", totalkiamia  = totalkiamia + $row[5]   WHERE sqdname8=\"$sqd_pref\"");

    $sth = $dbh->prepare("SELECT totalmis,totalakill,totalgkill,totalpoints,totalkiamia FROM $sqd_file_tbl WHERE id=?");
    $sth->execute($sqd_id);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0]>0) {  # misones >0 
	my $ak_x_mis= $row[1]/$row[0];
	my $gk_x_mis=$row[2]/$row[0];
	my $points_x_mis=$row[3]/$row[0];
	my $kia_x_mis=$row[4]/$row[0];
	$dbh->do("UPDATE $sqd_file_tbl SET ak_x_mis = $ak_x_mis, gk_x_mis = $gk_x_mis, points_x_mis = $points_x_mis, kia_x_mis = $kia_x_mis  WHERE id=\"$sqd_id\"");
    }
    print "+ $new_pilot statistics transfered to squadron $sqd_pref <br>\n";
    
    open (PILOT_LOG, ">>Pilot_log.txt") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
    print PILOT_LOG  "A ".scalar(localtime(time)) ." $adm_hlname has accepted $new_pilot into $sqd_pref\n";
    close (PILOT_LOG);

    print "<br>Return to <a href=\"/mng_sqd.php\">register menu</a><br>\n";

}


# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------

print &PrintHeader;
print &print_start_html();

# Limit upload size: avoid overflow attemps
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
