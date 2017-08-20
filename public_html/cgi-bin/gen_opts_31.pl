#!/usr/bin/perl

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();


&ReadParse(*in);
print &PrintHeader;
print &print_start_html();

#init to default values: 4/4, no ai, no type
my $fig_attk_nbr=4;
my $fig_attk_ai="off";
my $fig_def_nbr=4;
my $fig_def_ai="off";


my $bomb_attk_type="";
my $bomb_attk_nbr=4;
my $bomb_attk_ai="on";

my $bomb_def_type="";
my $bomb_def_nbr=4;
my $bomb_def_ai="on";

my $target="";
my $max_human=8;
my $max_ai=6;
                                     # FORM LINE RELETED  (output from take_slot.pl)
my $army=$in{'army'};                # <input type="hidden" name="army" value="R">
my $hlname=$in{'hlname'};            # <td>Name: <input type="TEXT" name="hlname" size="20" value=""> </td>
   $hlname =~ s/\'//g;
   $hlname =~ s/\"//g;
   $hlname =~ s/;//g;
my $pwd=$in{'pwd'};                  # <td>Password: <input type="password" name="pwd" size="20" value=""></td>
my $slot=$in{'slot'};                # <td><input type="hidden" name="slot" value="BW1BR">German Attack:</td>

$target=$in{'target'};               # <td><select name="target" size="1" style="width:180;" 
$max_human=$in{'max_human'};         # <td><input type="hidden" name="max_human" value="8">&nbsp;</td>
$max_ai=$in{'max_ai'};               # <td><input type="hidden" name="max_ai" value="6">&nbsp;</td>


$bomb_attk_type=$in{'bomb_attk_type'};    # <td><select name="bomb_attk_type" size="1" style="width:180;"
$bomb_attk_nbr=$in{'bomb_attk_nbr'};      # <td><input type="text" name="bomb_attk_nbr" size="2" value=0
$bomb_attk_ai=$in{'bomb_attk_ai'};        # <td><input type="checkbox" name="bomb_attk_ai"
if ($bomb_attk_ai eq "on") {$bomb_attk_ai=1;}
else {$bomb_attk_ai=0;}

$bomb_def_type=$in{'bomb_def_type'};     # <td><select name="bomb_def_type" size="1" style="width:180;"
$bomb_def_nbr=$in{'bomb_def_nbr'};      # <td><input type="text" name="bomb_def_nbr" size="2" value=0 
$bomb_def_ai=$in{'bomb_def_ai'};         # <td><input type="checkbox" name="bomb_def_ai"
if ($bomb_def_ai eq "on") {$bomb_def_ai=1;}
else {$bomb_def_ai=0;}

$fig_attk_nbr=$in{'fig_attk_nbr'};       # <td><input type="text" name="fig_attk_nbr" size="2" value=0
$fig_def_nbr=$in{'fig_def_nbr'};         # <td><input type="text" name="fig_def_nbr" size="2" value=0

$fig_attk_ai=$in{'fig_attk_ai'};           # <td><input type="checkbox" name="fig_attk_ai"
if ($fig_attk_ai eq "on") {$fig_attk_ai=1;}
else {$fig_attk_ai=0;}

$fig_def_ai=$in{'fig_def_ai'};             # <td><input type="checkbox" name="fig_def_ai"
if ($fig_def_ai eq "on") {$fig_def_ai=1;}
else {$fig_def_ai=0;}

my $err_msg="<font color=\"red\"><b>Error:</b></font>";
my $referer = $ENV{'HTTP_REFERER'};
my $server = $ENV{'HTTP_HOST'};

# Referer check is used to avoid custom forms hacking.

# 1) tolerant check:
#if ( $referer !~ m/$server/ ) {
#    print " $err_msg : Found a problem on yor....

# 2) less tolerant check: hardcoded hostname and page referer where we require to come from.
#    uses $allowed_ref1 and $allowes_ref2 values that are set on "config.pl"
#if ( !( $referer eq $allowed_ref1 || $referer eq $allowed_ref2) ){
if ( !( $referer eq $allowed_ref1 || $referer eq $allowed_ref2 || !$referer) ){
    my $ua= $ENV{'HTTP_USER_AGENT'};
    
    print " $err_msg : Found a problem on your request. You shuld remake your request.<br><br>\n";
    print " If problem persists, it can be originated if you are using software to remove HTTP_REFERER information.";
    print " Known programs doing manipulations on referers are Norton and Kerio Firewalls among others.";
    print " If this is your case, try to reconfigure them to turn this ferature off, or temporay disble software.<br><br>\n";
    print " If you need help, copy and paste next lines into Bugland forum. Tanks.<br><br>\n";

    print "<pre>\n";
    print "--------------------------------\n";
    print "Readed referer was: $referer \n";
    print "UA was: $ua \n";
    print "Error was: Incorrect HTTP_REFERER \n";
    print "--------------------------------\n";
    print "</pre>\n";

		print &print_end_html();
    exit;

}

# most of this errors are cheked with javascrpit code on take_slot.pl  
# but some people do not enable javascript, so we need to chek here too.

my $is_ok=1; 
if ( $target eq "" ) {print " $err_msg  Target not set. <br>\n>"; $is_ok=0;}
if ( $bomb_attk_type eq "" ) {print " $err_msg  Undefined Attack bombers plane type.<br>\n"; $is_ok=0;}
if ( $bomb_attk_nbr eq "" ) {print " $err_msg  Undefined Attack bomber plane amount.<br>\n"; $is_ok=0;}
if ( $bomb_def_type eq "" ) {print " $err_msg  Undefined Defend bombers plane type.<br>\n"; $is_ok=0;}
if ( $bomb_def_nbr eq "" ) {print " $err_msg  Undefined Defend bombers plane amount.<br>\n"; $is_ok=0;}
if ( $fig_attk_nbr eq "" ) {print " $err_msg  Undefined Attack fighter plane amount. <br>\n"; $is_ok=0;}
if ( $fig_def_nbr eq "" ) {print " $err_msg Undefined Defend figters plane amount. <br>\n"; $is_ok=0;}

my $total_ai=0;
my $total_hum=0;
if ($fig_attk_ai == 0) { $total_hum+=$fig_attk_nbr; }
else { $total_ai+=$fig_attk_nbr; }
if ($fig_def_ai == 0) { $total_hum+=$fig_def_nbr; }
else { $total_ai+=$fig_def_nbr; }
if ($bomb_attk_ai == 1) { $total_ai+=$bomb_attk_nbr; }
else { $total_hum+=$bomb_attk_nbr; }
#if ($bomb_def_ai == 0) { $total_hum+=$bomb_def_nbr; }
#else { $total_ai+=$bomb_def_nbr; }

if ( $total_hum != $max_human ) { 
    print " $err_msg Incorrect human amount of Human planes, must be $max_human planes not $total_hum.<br>\n"; $is_ok=0;}
if ( $total_ai > $max_ai ) {
    print " $err_msg Too much AI planes. Max allowed is:  $max_ai AI planes not $total_ai.<br>\n"; $is_ok=0;}

if (! $is_ok) {
    print " Pleas go <b>back</b> and fix. <br>\n";

		print &print_end_html();
    exit;
}

# verification that targets are listed on possible targets to attacks file list (Options_?.txt)
$is_ok=0;
if ($army eq "R") {
    my $Options_R= $PATH_DYNAMIC_TXT . "/" . "Options_R.txt";
    open (OPR,"<$Options_R");
    while(<OPR>) {
	if ($_ =~ m/$target/) { $is_ok=1; last;}

    }
    close(OPR);
}
else { # Army = B 
    my $Options_B= $PATH_DYNAMIC_TXT . "/" . "Options_B.txt";
    open (OPB,"<$Options_B");
    while(<OPB>) {
	if ($_ =~ m/$target/) { $is_ok=1; last;}
    }
    close(OPB);
}

if (! $is_ok) {
    print " $err_msg Taget $target is  not aviable right now. This can be because a recent report.<br>\n";
    print " Pleas go <b>back</b> and remake request. Be sure to reload pages and not use a cached version.<br>\n";

		print &print_end_html();
    exit;
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

# pwd verification
$sth = $dbh->prepare("SELECT password,sqd_army,sqd_accepted  FROM $pilot_file_tbl WHERE hlname=?");
$sth->execute($hlname);
@row = $sth->fetchrow_array;
$sth->finish;
if ($row[0] ne $pwd) {
    print "Name or password not valid<br>\n";

		print &print_end_html();
    exit(0);
}
if ($row[1] == 0 || $row[2] == 0) {
    print "You have belong to a squadron to make mission requests <br>\n";

		print &print_end_html();
    exit(0);
}

# we only allow request for pilots in own side, exeption for super_user (defined on config.pl)
if ($hlname ne $super_user && $row[1] == 1 && $army eq "B") {
    print "You are a VVS pilot and you can't make LW requests<br\n";

		print &print_end_html();
    exit(0);
}
if ($hlname ne $super_user && $row[1] == 2 && $army eq "R") {
    print "You are a LW pilot and you can't make VVS requests<br\n";

		print &print_end_html();
    exit(0);
}


my $epoca = time;
my $ID= $epoca.",$army,$hlname,$total_hum,$target,$fig_attk_nbr,$fig_attk_ai,$fig_def_nbr,$fig_def_ai,$bomb_attk_type,$bomb_attk_nbr,$bomb_attk_ai,$bomb_def_type,$bomb_def_nbr,$bomb_def_ai,\n";

my $options_file = $PATH_DYNAMIC_TXT . "/" . "options.txt";
if (! open(OPT,">>$options_file")){
    print "Error: No se puede abrir archivo de opciones para escribir.\n";
    die"no se puede abrir archivo de opciones para escribir.\n";
}
print OPT $ID;
close(OPT);

$sth = $dbh->prepare("SELECT status, hlname FROM $host_slots_tbl WHERE slot=?");
$sth->execute($slot);
@row = $sth->fetchrow_array;
$sth->finish;
if ($row[0] == 1 && $hlname eq  $row[1] ) { # if staus is  waiting(1) and is hlname is owner of slot
    # update values of request and set status ro ready(2)
    $dbh->do("UPDATE $host_slots_tbl SET status = 2, hlname = '$hlname', epoca = $epoca, date = '', tgt_name = '$target', time = '', max_human = $max_human, fig_attk_nbr = $fig_attk_nbr, fig_def_nbr = $fig_def_nbr, bomb_attk_type = '$bomb_attk_type' , bomb_attk_nbr = $bomb_attk_nbr, bomb_attk_ai = $bomb_attk_ai , bomb_def_type = '$bomb_def_type', bomb_def_nbr = $bomb_def_nbr , bomb_def_ai = $bomb_def_ai WHERE slot=\"$slot\"");

    # look if now BOTH request are ready
    if ( $slot =~ m/RR/ ) { # if slot was a red request (we now red is ready, and we need to check blue)
	$slot =~ s/RR/BR/;  # we change to blue
	$sth = $dbh->prepare("SELECT status FROM $host_slots_tbl WHERE slot=?");
	$sth->execute($slot);
    @row = $sth->fetchrow_array;
	$sth->finish;
	if ($row[0] == 2) { # if blue is ready
	    $slot =~ s/BR//; #we swich to host slot and set ready ( that will be ready to download)
	    $dbh->do("UPDATE $host_slots_tbl SET status = 2 WHERE slot=\"$slot\"");
	}
    }
    else { 
	$slot =~ s/BR/RR/;  # we change to red (blue request is ready, need to check red request)
	$sth = $dbh->prepare("SELECT status FROM $host_slots_tbl WHERE slot=?");
	$sth->execute($slot);
	@row = $sth->fetchrow_array;
	$sth->finish;
	if ($row[0] == 2) { # if red is ready
	    $slot =~ s/RR//; #swich to host slot and set ready (for download)
	    $dbh->do("UPDATE $host_slots_tbl SET status = 2 WHERE slot=\"$slot\"");
	}
    }
    
    print "Request accepted : " . $hlname . " -  Human planes: ". $total_hum ."\n";
}
else {
    print "Request <font color=\"red\">refused</font>\n";
}

print "<br><br><font size=\"+1\"><a href=\"/create.php\">Back</a></font><br>\n";
print &print_end_html();


# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
$allowed_ref1=$allowed_ref1;
$allowed_ref2=$allowed_ref2;
$pilot_file_tbl=$pilot_file_tbl;
