#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();

my @row;
my $dbh;
my $sth;


my $hlname="";
my $pwd="";
my $sqd_id="";
my $sqd_name="";
my $sqd_army="";


$|=1; # hot output

# Limit upload size
$cgi_lib::maxdata = 128; 
$cgi_lib::maxdata = 128; 

&ReadParse(%in); # Read data
$hlname=$in{'hlname'};
$pwd=$in{'pwd'};
$sqd_id=$in{'sqd_id'};


# TO DO: Check string lengts, so it not overuns defined string size on database

print &PrintHeader;
print &print_start_html();

$hlname=~ s/^ *//g;
$hlname=~ s/ *$//g;
if ($hlname =~ m/ / || $hlname eq "" || $pwd eq "" ){ 
    print "<font color=\"red\" size=\"+1\">ERROR:</font> Name or password not valid<br>\n";
    
    print &print_end_html();
    exit(0);
}

if ($sqd_id ==1 ){ 
    print "<font color=\"red\" size=\"+1\">ERROR:</font> You must select a squadron diferent from \"NONE\".<br>\n";
    
    print &print_end_html();
    exit(0);
}

if ($sqd_id==0) { 
    print "<font color=\"red\" size=\"+1\">Error: <b>Sqdid-assign-joinsqd-pl</b><br>Problem on asignation of SQD-ID. Please inform this problem in forum<br></font>";
    
    print &print_end_html();
    exit(0);
}

    # html special chars on $hlname
    $html_hlname=$hlname;
    $html_hlname =~ s/</&lt;/g;
    $html_hlname =~ s/>/&gt;/g;


# db connect
$dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");

if (! $dbh) { 
    print "Can't connect to DB\n";
    die "$0: Can't connect to DB\n";
}

#verify pwd
$sth = $dbh->prepare("SELECT password,in_sqd_name,sqd_accepted  FROM $pilot_file_tbl WHERE hlname=?");
$sth->execute($hlname);
@row = $sth->fetchrow_array;
$sth->finish;
if ($row[0] ne $pwd) {
    print "<font color=\"red\" size=\"+1\">ERROR:</font> Name or password not valid<br>\n";
    
    print &print_end_html();
    exit(0);
}
if ($row[2] == "1") {
    print "<font color=\"red\" size=\"+1\">ERROR:</font>  You already are in squadron $row[1]<br>\n";
    print "Before join other squadron you must quit actual squadron.<br>\n";
    
    print &print_end_html();
    exit(0);
}

$sth = $dbh->prepare("SELECT sqdname8,sqd_army  FROM $sqd_file_tbl WHERE id=?");
$sth->execute($sqd_id);
@row = $sth->fetchrow_array;
$sth->finish;
$sqd_name=$row[0];
$sqd_army=$row[1];

$dbh->do("UPDATE $pilot_file_tbl SET in_sqd_name = \"$sqd_name\", in_sqd_id = \"$sqd_id\", sqd_army = \"$sqd_army \", sqd_accepted = 0 WHERE hlname=\"$hlname\"");


# html special chars on $sqd_name
$html_sqd_name=$sqd_name;
$html_sqd_name =~ s/</&lt;/g;
$html_sqd_name =~ s/>/&gt;/g;


open (PILOT_LOG, ">>Pilot_log.txt") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
print PILOT_LOG  "J ". scalar(localtime(time)) ." $hlname has request to join $sqd_name\n";
close (PILOT_LOG);

print "Aplication sent to Squadron:  $html_sqd_name<br>\n";
print " Your squadron roster page is: <a href=\"/sqd_file.php?sqd=$html_sqd_name\">Here</a><br><br>\n";
print "Once your aplication is accepted by Squad Co/Xo your pilot file will be updates, and your stats moved into squadron.<br>\n";

print "<br><br>Back to <a href=\"/mng_pilot.php\">register menu</a><br>\n";


print &print_end_html();
exit(0);

# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
$sqd_file_tbl=$sqd_file_tbl;
