#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();

$|=1; # hot output

my $sqd_name="";
my $sqd_pref="";
my $sqd_side=0;
my $co_hlname="";
my $co_email="";
my $sqd_web="";
my $sqd_logo="";
my $co_pwd="";
my $auth_code="";
my $succeed=1;


# Limit upload size
$cgi_lib::maxdata = 512; 
$cgi_lib::maxdata = 512; 

&ReadParse(%in); # Read data
$sqd_name=$in{'sqdname'};
$sqd_pref=$in{'sqdname8'};
$sqd_side=$in{'lado'};
$co_hlname=$in{'coname'};
$co_email=$in{'comail'};
$sqd_web=$in{'weburl'};
$sqd_logo=$in{'logourl'};
$co_pwd=$in{'copwd'};
$auth_code=$in{'auth'};

# TO DO: CHECK, review sizes of string to not overflow DB tables strings

print &PrintHeader;
print &print_start_html();

$sqd_name=~ s/^ *//;
$sqd_name=~ s/ *$//;
$sqd_logo=~ s/>/&gt;/g;
$sqd_logo=~ s/</&lt;/g;
if ($sqd_name eq ""){
    print "You didnt fill the squad name<br>\n";
    $succeed=0;
}

$sqd_pref=~ s/^ *//;
$sqd_pref=~ s/ *$//;
if ($sqd_pref eq ""){
    print "You didnt fill the squad prefix <br>\n";
    $succeed=0;
}

if (length $sqd_pref >8){
    print "Squad prefix must be 8 chars long max. <br>\n";
    $succeed=0;
}

if ($sqd_side == 0){
    print "You didnt select on wich side the squadron will fly<br>\n";
    $succeed=0;
}

$co_hlname=~ s/^ *//g;
$co_hlname=~ s/ *$//g;
if ($co_hlname =~ " "){ 
    print "Error: The CO names (HL nick) can not contain white spaces<br>\n";
    $succeed=0;
}
if ($co_hlname eq ""){
    print "You have to fill CO field name<br>\n";
    $succeed=0;
}


# if there are error, lets end here
if (!$succeed) {
    
    print &print_end_html();
    exit(0);
}

$sqd_web=~ s/ //g;
$sqd_web=~ s/\'//g;
$sqd_web=~ s/\`//g;
$sqd_web=~ s/\"//g;
$sqd_web=~ s/>//g;
$sqd_web=~ s/<//g;
if ($sqd_web eq ""){ 
    print "Warning: You didnt suply a squad home page.<br>\n";
}

$sqd_logo=~ s/ //g;
$sqd_logo=~ s/\'//g;
$sqd_logo=~ s/\`//g;
$sqd_logo=~ s/\"//g;
$sqd_logo=~ s/>//g;
$sqd_logo=~ s/<//g;
if ($sqd_logo eq ""){ 
    print "Warning: You didnt suply a squad logo link.<br>\n";
}


my $auth_ok=0;

if ($require_auth_code) { # value read from config.pl

    my $keys_file = $PATH_DYNAMIC_TXT . "/" . "claves.txt";
    if (! open(CLA,"<claves.txt")){
	print "Error: cant open claves.txt file.\n";
	
	print &print_end_html();
	die " $0 : ". scalar(localtime(time))." cant open claves.txt file.\n";
    }

    my $used_keys_file = $PATH_DYNAMIC_TXT . "/" . "used_claves.txt";
    if (! open(U_CLA,"+<$used_keys_file")){
	close (CLA);
	print "Error: cant open used_claves.txt file.\n";
	
	print &print_end_html();
	die " $0 : ". scalar(localtime(time))." cant open used_claves.txt file.\n";
    }
    
    
    $auth_ok=0;
    $auth_code =~ s/[^a-zA-Z0-9]//g;
    
    # code has to be listed in file claves.txt
    if ($auth_code ne "" ) {
	while (<CLA>) {
	    if ($_ =~ m/$auth_code/) {
		$auth_ok=1;
		last;
	    }
	}
    }
    
    # and code has NOT to be liste in file used_claves.txt
    if ($auth_ok) {
	while (<U_CLA>) {
	    if ($_ =~ m/$auth_code/) {
		$auth_ok=0;
		last;
	    }
	}
    }

    if (!$auth_ok){
	print "Invalid autorization code<br>\n";

    my $pilot_log = $PATH_DYNAMIC_TXT . "/" . "Pilot_log.txt";
	open (PILOT_LOG, ">>$pilot_log") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
	print PILOT_LOG  "! ". scalar(localtime(time)) ." $co_hlname used invalid code: $auth_code\n";
	close (PILOT_LOG);
	
	print &print_end_html();
	exit(0);
    }
}

my @row;
my $dbh;
my $sth;

# db connect
$dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");

if (! $dbh) { 
    print "Can't connect to DB\n";
    die "$0: Can't connect to DB\n";
}

#verify that sqdron do not exist previously (unique squadron prefix)
# we do this counting how many sqds has same prefix
$sth = $dbh->prepare("SELECT COUNT(*) FROM $sqd_file_tbl WHERE sqdname8=?");
$sth->execute($sqd_pref);
@row = $sth->fetchrow_array;
$sth->finish;
if ($row[0] >0) { #squadron already exists
    print "The squadron $sqd_pref was allready registered<br>\n";
    
    print &print_end_html();
    exit(0);
}

#verify that CO is a registered pilot and verify that CO is not in other squadrn
if ($co_hlname ne "") {  # shild not happen
    #count how many pilots with same name exist
    $sth = $dbh->prepare("SELECT COUNT(*) FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($co_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0]==0) { #pilot not exist 
	print "Error: The CO must be registered as pilot before squadron creation<br>\n";
	
	print &print_end_html();
	exit(0);
    }
    # pilot is registered... lets Find Squadron ID in his pilot file
    $sth = $dbh->prepare("SELECT in_sqd_id FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($co_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0]>1) { # pilot is member of other squadron, different from default "NONE"
	print "Error: The CO belongs to other squadron<br>\n";
	
	print &print_end_html();
	exit(0);
    }
}


#verify CO password
$sth = $dbh->prepare("SELECT password,email FROM $pilot_file_tbl WHERE hlname=?");
$sth->execute($co_hlname);
@row = $sth->fetchrow_array;
$sth->finish;
if ($row[0] ne $co_pwd) { #pwd no match
    print "Error: CO password is incorrect<br>\n";
    
    print &print_end_html();
    exit(0);
}
$co_email=$row[1];

my ($dia,$mes,$anio)=(localtime)[3,4,5];
my $fecha =($anio+1900)."-".($mes+1)."-".($dia);
$dbh->do("INSERT INTO $sqd_file_tbl VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",undef,"",$sqd_name,$sqd_pref,"unused_pwd",1,$sqd_side,$co_hlname,$co_email,"","",0,0,0,0,0,0,0,$sqd_web,$sqd_logo,$fecha,"0","0","0","0","0");

print "<br><br>\n";
print "<font color=\"green\"><b>squadron created and registered succesfuly.</b></font><br>\n";

print "<br><h3>Incorporated data</h3><br>\n";
print "Squad name: ". $sqd_name . "<br>\n";
print "Prefix: " . $sqd_pref . "<br>\n";
print "Side: " . $sqd_side . " &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (1=VVS 2=LW)<br>\n";
print "Co name: " . $co_hlname . "<br>\n";
print "Co email: " . $co_email . "<br>\n";
print "sqd web: " . $sqd_web . "<br>\n";
print "sqd logo: " . $sqd_logo . "<br>\n";
print "<hr size=\"1\" width=\"400px\">\n";


print "<br><h3>Co Incorporation:</h3><br>\n";
# Get the squadron ID just created
$sth = $dbh->prepare("SELECT id FROM $sqd_file_tbl WHERE sqdname8=?");
$sth->execute($sqd_pref);
@row = $sth->fetchrow_array;
$sth->finish;
my $sqd_id=$row[0];


#update CO pilot file 
$dbh->do("UPDATE $pilot_file_tbl SET in_sqd_name = \"$sqd_pref\", in_sqd_id = \"$sqd_id\", sqd_army = \"$sqd_side\", sqd_accepted = 1 WHERE hlname=\"$co_hlname\"");
print "+ $co_hlname transfered an accepted to $sqd_pref<br>\n";

#incorporate CO stats into sqadron stats
$sth = $dbh->prepare("SELECT  missions, akills, gkills, victorias, points, killed,captured FROM $pilot_file_tbl WHERE hlname=?");
$sth->execute($co_hlname);
@row = $sth->fetchrow_array;
$sth->finish;
my $totalkiamia=$row[5]+$row[6];
$dbh->do("Update  $sqd_file_tbl SET totalpilot = totalpilot + 1, totalmis = totalmis + \"$row[0]\", totalakill = totalakill + \"$row[1]\", totalgkill = totalgkill + \"$row[2]\", totalvict = totalvict + \"$row[3]\", totalpoints = totalpoints + \"$row[4]\", totalkiamia = $totalkiamia WHERE sqdname8=\"$sqd_pref\"");

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
print "+ $co_hlname statistics transfered to $sqd_pref<br>\n";

my $pilot_log = $PATH_DYNAMIC_TXT . "/" . "Pilot_log.txt";
open (PILOT_LOG, ">>$pilot_log") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
print PILOT_LOG  "S ". scalar(localtime(time)) ." $co_hlname registered squadron $sqd_pref - code used: $auth_code\n";
close (PILOT_LOG);


print "Return to <a href=\"/mng_sqd.php\">register nemu</a> page.<br>\n";
print "<p>Remmember to visit the \"Admin Sqd\"  to accept pilots aplications and other admin tasks.<br>\n";

print &print_end_html();

if ($require_auth_code) {
    if ($auth_ok) { print U_CLA "$auth_code  - sqd pref: $sqd_pref   id: $sqd_id  coname: $co_hlname \n";}
    close (CLA);
    close (U_CLA);
}

# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
