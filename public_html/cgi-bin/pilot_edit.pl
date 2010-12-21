#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();

$|=1; # hot output

my @row;
my $dbh;
my $sth;

my $hlname="";
my $pwd="";
my $pwd1="";
my $pwd2="";
my $email="";
my $avatar="";
my $succeed=1;


sub print_login() {
    print <<Login;

    <form method="POST" action="/cgi-bin/pilot_edit.pl">
    <table>
      <tr><td align="right">Name (HL nick): </td><td><input type="text" size="16" name="hlname" value="$hlname"></td></tr>
      <tr><td align="right">Passwod: </td><td><input type="password" size="16" name="pwd" value="$pwd"></td></tr>
      <tr><td></td><td><input type=submit name="accion" value="send"></td></tr>
    </table>
    </form>

Login
    ;
}

sub print_old_data (){

    $hlname=$in{'hlname'};
    $pwd=$in{'pwd'};
    $hlname=~ s/^ *//g;
    $hlname=~ s/ *$//g;
    if ($hlname =~ m/ / || $hlname eq "" || $pwd eq "" ){ 
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Name or password not valid<br>\n";
	return(0);
    }
    
    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    
    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    #verify pwd
    $sth = $dbh->prepare("SELECT password,email,avatar  FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $pwd) {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Name or password not valid<br>\n";
	return(0);
    }
    print <<Eoform;
 
<FORM METHOD="POST" ACTION="/cgi-bin/pilot_edit.pl">
<table>
<tr><td align="right">Pilot Profile for: </td>
    <td bgcolor="#FCFCDC">&nbsp;&nbsp;<input type="hidden" size="20" name="hlname" value="$hlname" readonly><b>$hlname</b></td></tr>
<tr><td align="right">Actual Password  <font color="red">*</font></td>
    <td>&nbsp;&nbsp;<input type="password" size="15" name="pwd" value="$pwd"></td></tr>
<tr><td align="right">New Password  <font color="blue">*</font></td>
    <td>&nbsp;&nbsp;<input type="password" size="15" name="pwd1"></td></tr>
<tr><td align="right">Confirm new Password  <font color="blue">*</font></td>
    <td>&nbsp;&nbsp;<input type="password" size="15" name="pwd2"></td></tr>
<tr><td align="right">email &nbsp; </td>
    <td>&nbsp;&nbsp;<input type="text" value="$row[1]" size="30" name="email"></td></tr>
<tr><td align="right">Avatar link &nbsp; </td>
   <td>&nbsp;&nbsp;<input type="text" value="$row[2]" size="50" name="avatar"></td></tr>

<tr><td align="left" colspan="2"> <font color="red">*</font> Actual password is required &nbsp; &nbsp; 
<tr><td align="left" colspan="2"> <font color="blue">*</font> Fill only if you want to change password &nbsp; &nbsp; 

<tr><td></td><td><input type=submit name=accion value=save></td></tr>

Eoform
    ; # emacs related
}

sub update_data(){

    $hlname=$in{'hlname'};
    $pwd=$in{'pwd'};
    $pwd1=$in{'pwd1'};
    $pwd2=$in{'pwd2'};
    $email=$in{'email'};
    $avatar=$in{'avatar'};


    $hlname=~ s/^ *//g;
    $hlname=~ s/ *$//g;
    if ($hlname =~ m/ / || $hlname eq ""){
  print &PrintHeader; 
	print &print_start_html();
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Incorrect HL name<br>\n";
	return(0);
    }
    if ($pwd eq ""){
  print &PrintHeader;
	print &print_start_html();
	print "<font color=\"red\" size=\"+1\">ERROR:</font> You didnt suply a password<br>\n";
	return(0);
    }
    if ($pwd1 ne $pwd2){
  print &PrintHeader;
	print &print_start_html();
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The password and its verification do not match<br>\n";
	return(0);
    }
    
    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    
    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    #verify Password
    $sth = $dbh->prepare("SELECT password FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $pwd) { #pwd no match
  print &PrintHeader;    	
	print &print_start_html();
	print "<font size=\"+1\" color=\"red\">Error: incorrect actual Password</font><br>\n";
	return(0);
    }
    
    if ($pwd1 ne "") {
	if ($pwd1 eq $hlname){
			print &PrintHeader;
	    print &print_start_html();
	    print "<font color=\"red\" size=\"+1\">ERROR:</font>  The password and your name needs not to be equal<br>\n";
	    return(0);
	}
	if (length($pwd1) < 6){
	    print &PrintHeader;
	    print &print_start_html();
	    print "<font color=\"red\" size=\"+1\">ERROR:</font> Passwords must have at least a lenght of 6 chars.<br>\n";
	    return(0);
	}
	$pwd=$pwd1; #  pwd change
    }
    
    $email=~ s/^ *//g;
    $email=~ s/ *$//g;
    $email=~ s/\'//g;
    $email=~ s/\`//g;
    $email=~ s/\"//g;
    $email=~ s/>//g;
    $email=~ s/<//g;
    if ($email eq ""){ 
	#print "Warning: CO Email not specified<br>\n";
    }

    $avatar=~ s/ //g;
    $avatar=~ s/\'//g;
    $avatar=~ s/\`//g;
    $avatar=~ s/\"//g;
    $avatar=~ s/>//g;
    $avatar=~ s/<//g;
    if ($avatar eq ""){ 
	#print "Warning: You didnt suply a squad home page.<br>\n";
    }

    $dbh->do("UPDATE $pilot_file_tbl SET password = \"$pwd\", email = \"$email\", avatar = \"$avatar\" WHERE hlname=\"$hlname\"");
    
    open (PILOT_LOG, ">>Pilot_log.txt") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
    print PILOT_LOG  "E ". scalar(localtime(time)) ." $hlname edited his profile\n";
    close (PILOT_LOG);

    # set cookie user and password info.

    print "Set-Cookie: ";
    print "badc_user=".$hlname." ".$pwd."; expires=".$cookie_expire."; path=/\n";
    print &PrintHeader;
    print &print_start_html();
    print "Data updated.<br>\n";
    print "Return to <a href=\"/mng_pilot.php\">register menu</a><br>\n"; 
}


# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------



# Limit upload size
$cgi_lib::maxdata = 256; 
$cgi_lib::maxdata = 256; 

$hlname="";
$pwd="";
&ReadParse(%in); # Read data
my $accion=$in{'accion'};

if ($accion eq "") { 
    # read cookie
    my @rawCookies = split (/; /,$ENV{'HTTP_COOKIE'});
    foreach(@rawCookies){
	($key, $val) = split (/=/,$_);
	if ($key eq "badc_user"){
	    ($hlname,$pwd) = split (/ /,$val);
	}
    } 

		print &PrintHeader;
    print &print_start_html();
    print_login(); 
}
elsif ($accion eq "send") { #<input type=submit name=accion value=enviar>
    print &PrintHeader;
    print &print_start_html();
    print_old_data();
}
elsif ($accion eq "save") { #<input type=submit name=accion value=guardar>
    # print &print_start_html();  No yet,  because we set a cookie :)
    update_data();
}
else { # unknown action
		print &PrintHeader;
    print &print_start_html();
    print "Error :) <br>\n";
}
print &print_end_html();
exit (0);

# useless lines to avoid used only once messages 
$cookie_expire=$cookie_expire;
