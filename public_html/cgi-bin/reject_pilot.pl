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
    $rej_pilot=$in{'rejpilot'};

    $rej_pilot=~ s/^ *//g;
    $rej_pilot=~ s/ *$//g;
    if ($rej_pilot =~ m/ / || $rej_pilot eq "") {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Name of pilot to reject is empty or not valid <br>\n";
	return(0);
    }

    if ($adm_hlname  =~ m/ / || $adm_hlname eq "") {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Incorrect CO/XO  name.<br>\n";
	return(0);
    }

    if ($adm_hlname eq "") {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> You didnt write your password.<br>\n";
	return(0);
    }


    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    
    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    #verifyPassword from adm_hlname
    $sth = $dbh->prepare("SELECT password FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($adm_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $adm_pwd) { #pwd no match
	print "<font color=\"red\" size=\"+1\">ERROR:</font>  CO/XO password is incorrect<br>\n";
	return(0);
    }

    # look for squadron ID using adm_hlname pilot file
    $sth = $dbh->prepare("SELECT in_sqd_id,in_sqd_name FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($adm_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    $sqd_id=$row[0];
    $sqd_pref=$row[1];

    # now using sqd ID find admin names (co/XO) and permissions
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

    # verify if the pilot to reject has applyed to this squadron
    $sth = $dbh->prepare("SELECT in_sqd_id,sqd_accepted FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($rej_pilot);
    @row = $sth->fetchrow_array;
    $sth->finish;
    $sqd_id=$row[0];    
    if ($row[0] ne $sqd_id) { #Pilot to reject has not correct ID. can be a bug or hacking attempt
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The pilot $rej_pilot didnt applyed to your squad. Hacking?\n";
	return(0);
    }
    if ($row[1] == 1) { # pilot to reject was already accepted 
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The pilot $rej_pilot was already incorporated to your squad.\n";
	return(0);
    }


    print "<h3>Rejection of $rej_pilot aplication :</h3><br>\n";

    # Update pilot file, seting squadron NONE, ID=1 army =0
    $dbh->do("UPDATE $pilot_file_tbl SET  in_sqd_name=\"NONE\" , in_sqd_id =\"1\" , sqd_army=\"0\" WHERE hlname=\"$rej_pilot\"");

    open (PILOT_LOG, ">>Pilot_log.txt") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
    print PILOT_LOG  "X ".scalar(localtime(time)) ." $adm_hlname has rejected $rej_pilot aplication for $sqd_pref\n";
    close (PILOT_LOG);

    print "+ $rej_pilot aplication was rejected from $sqd_pref<br>\n";

    print "<br>Return to <a href=\"/mng_sqd.php\">register menu</a><br>\n";

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
$sqd_file_tbl=$sqd_file_tbl;
