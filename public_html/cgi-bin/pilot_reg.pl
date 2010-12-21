#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();


my $hlname="";
my $pwd1="";
my $pwd2="";
my $email="";
my $avatar="";
my $succeed=1;

$|=1; # hot output

# Limit upload size
$cgi_lib::maxdata = 256; 
$cgi_lib::maxdata = 256; 

&ReadParse(%in); # Read data
$hlname=$in{'hlname'};
$pwd1=$in{'pwd1'};
$pwd2=$in{'pwd2'};
$email=$in{'email'};
$avatar=$in{'avatar'};

# TO DO: CHECK, review sizes of string to not overflow DB tables strings

print &PrintHeader;
print &print_start_html();


$hlname=~ s/^ *//g;
$hlname=~ s/ *$//g;
if ($hlname =~ m/ /){ 
    print "<font color=\"red\" size=\"+1\">ERROR:</font> The name (HL nick) can not contain white spaces<br>\n";
    
    print &print_end_html();
    exit(0);
}

if ($hlname eq ""){ 
    print "<font color=\"red\" size=\"+1\">ERROR:</font> The name (HL nick) is NULL<br>\n";
    
    print &print_end_html();
    exit(0);
}

# html special chars on $hlname
$html_hlname=$hlname;
$html_hlname =~ s/</&lt;/g;
$html_hlname =~ s/>/&gt;/g;

my @row;
my $dbh;
my $sth;

# db connect
$dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user","$db_upwd");

if (! $dbh) { 
    print "Can't connect to DB\n";
    die "$0: Can't connect to DB\n";
}

$sth = $dbh->prepare("SELECT COUNT(*) FROM $pilot_file_tbl WHERE hlname=?");
$sth->execute($hlname);
@row = $sth->fetchrow_array;
$sth->finish;
if ($row[0]>0) { #pilot already  exists
    print "<font color=\"red\" size=\"+1\">ERROR:</font> The pilot $html_hlname <b>is already</b> registered.<br><br>\n\n";
    print "Is possible that pilot <b>was registered automatically</b> if a mission was reported and you was present in that mission. In this case, the pilot is registered automatically, and a default password is assigned: your </b>Nickname</b>.\n";
    print "Go to <a href=\"/cgi-bin/pilot_edit.pl\"><b>Pilot edit</b></a>, and use:<br><br>Name: 
<font color=\"blue\"><b>$html_hlname</b></font><br>Password: <font color=\"blue\"> <b> $html_hlname </b></font> <br><br>\n";
    print "If it works, update your information: new password, email and avatar. After that, go to join squadron or create squadron.<br><br>\n";
    print "If that don't works, please infom the problem in the forum, section \"bugs and problems\". Tnx.<br>\n";

}
else {
    if ($pwd1 eq ""){
	print "<font color=\"red\" size=\"+1\">ERROR:</font> You didnt suply a password<br>\n";
	
	print &print_end_html();
	exit(0);
    }
    if ($pwd1 ne $pwd2){
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The password and its verification do not match<br>\n";
	
	print &print_end_html();
	exit(0);
    }
    if ($pwd1 eq $hlname){
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The password and your name needs not to be equal<br>\n";
	
	print &print_end_html();
	exit(0);
    }
    if (length($pwd1) < 6){
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Passwords must have at least a lenght of 6 chars.<br>\n";
	
	print &print_end_html();
	exit(0);
    }

$email=~ s/^ *//g;
$email=~ s/ *$//g;
$email=~ s/\'//g;
$email=~ s/\`//g;
$email=~ s/\"//g;
$email=~ s/>//g;
$email=~ s/<//g;
if ($email eq ""){ 
#    print "Warning: CO Email not specified<br>\n";
}


$avatar=~ s/ //g;
$avatar=~ s/\'//g;
$avatar=~ s/\`//g;
$avatar=~ s/\"//g;
$avatar=~ s/>//g;
$avatar=~ s/<//g;
if ($avatar eq ""){ 
#    print "Warning: You didnt suply a squad home page.<br>\n";
}


    my ($dia,$mes,$anio)=(localtime)[3,4,5];
    my $fecha =($anio+1900)."-".($mes+1)."-".($dia);
    $dbh->do("INSERT INTO $pilot_file_tbl VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",undef,"",$hlname,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"NONE",1,0,0,$pwd1,$email,$avatar,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,100,0,0,0,0,0,0,0,0,0,0,$fecha,0.9,"",0,$INIT_BAN_PLANNIG);

    open (PILOT_LOG, ">>Pilot_log.txt") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
    print PILOT_LOG  "R ". scalar(localtime(time)) ." $hlname has registered\n";
    close (PILOT_LOG);

    print "The pilot <b> $html_hlname </b> has been registered<br>\n";
    print "Your profile page is <a href=\"/pilot.php?hlname=$html_hlname\">Here</a><br><br>";

    print "Now you shuld go to <a href=\"/mng_pilot.php\">register page</a> and create a squadron or join one.<br>\n";

}


print &print_end_html();
exit(0);

# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
$INIT_BAN_PLANNIG=$INIT_BAN_PLANNIG;
