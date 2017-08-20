#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
use DBI();

$|=1; # hot output

my @row;
my $dbh;
my $sth;

# sqd data
my $hlname="";
my $pwd="";
my $repnbr ="";
my $succeed=1;



sub print_start_html(){
    print &PrintHeader;
    print <<TOP;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
      <META HTTP-EQUIV="PRAGMA" CONTENT="no-cache">
      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      <link rel="stylesheet" type="text/css" href="/badc.css">
      <script type="text/javascript" src="/js/mapzoom.js"></script>
      <script type="text/javascript" src="/js/cvi_tip_lib.js"></script>
      <title>Write Mission report.</title>
</head>
<body>


<div id="hoja">

  <a href="/index.html"><img border="0" src="/images/logo.gif"  alt="index" style="margin-left: 40px; margin-top: 0px" ></a>
  <br>

<div id="central">
TOP
    ; # emacs related
}

sub print_end_html(){
    print "</div><br></div>\n";
    print &HtmlBot;
}

sub print_form() {
    print <<FRM;

<script type="text/javascript">

    function Check(){
	if (document.reportf.hlname.value == ""){
	    alert("Enter your name.");
	    return false;
	}
	if (document.reportf.pwd.value == ""){
	    alert("Enter your password");
	    return false;
	}
	if (document.reportf.comments.value == ""){
	    alert("Enter your report data");
	    return false;
	}
    }
    
    function insertar (cara) {
 	var texto = document.reportf.comments;
	texto.value  += ' ' + cara + ' ';
  	texto.focus();
    }

</script>



    <form name="reportf" method="POST" action="/cgi-bin/write_comm.pl" onSubmit="return Check()">
    <input type="hidden" name="repnbr" value="$repnbr">
    <table>
      <tr><td align="right">Name (HL nick): </td><td><input type="text" size="16" name="hlname" value="$hlname"></td></tr>
      <tr><td align="right">Password : </td><td><input type="password" size="16" name="pwd" value="$pwd"></td></tr>


      <tr><td align=middle colSpan=2><hr size="1"></td></tr>
      <tr>
	<td align=middle colSpan=2>
	  <table border="0">
	    <tr> 
	      <td>&nbsp;<a href="JavaScript:insertar(':)')"><img src="/images/mi01.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(';)')"><img src="/images/mi02.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':O')"><img src="/images/mi03.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':D')"><img src="/images/mi04.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':S')"><img src="/images/mi05.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':(')"><img src="/images/mi06.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':[')"><img src="/images/mi07.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':8')"><img src="/images/mi08.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':X')"><img src="/images/mi09.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':o')"><img src="/images/mi10.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':L')"><img src="/images/mi11.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':]')"><img src="/images/mi12.gif" border="0"></a>&nbsp;</td>
	    </tr>
	    <tr> 
	      <td>&nbsp;<a href="JavaScript:insertar(':P')"><img src="/images/mi13.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':p')"><img src="/images/mi14.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':C')"><img src="/images/mi15.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':~')"><img src="/images/mi16.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':^')"><img src="/images/mi17.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':V')"><img src="/images/mi18.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':|')"><img src="/images/mi19.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':s')"><img src="/images/mi20.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':/')"><img src="/images/mi21.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':%')"><img src="/images/mi22.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':*')"><img src="/images/mi23.gif" border="0"></a>&nbsp;</td>
	      <td>&nbsp;<a href="JavaScript:insertar(':!')"><img src="/images/mi24.gif" border="0"></a>&nbsp;</td>
	    </tr>
	  </table>
	</td>
      </tr>
      <tr><td align=middle colSpan=2><hr size="1"></td></tr>

      <tr><td align="left">Your report:</td><td>&nbsp;</td></tr>
      <tr><td align="center" colspan="2">
        <textarea rows=10 cols=60 name="comments"></textarea></td></tr>
      </table>
      <center>
	<input type=submit name="accion" value="Send"> 
      </center>
    </form>

FRM
    ;
}

sub write_comment(){


if (! -e "$PATH_DYNAMIC_REP/$repnbr.html") {
    print "Error opening report file.<br>\n";
    die " $0 : ". scalar(localtime(time))." File not exists $PATH_DYNAMIC_REP/$repnbr.html";
}

if (! open (REPORT, "+<$PATH_DYNAMIC_REP/$repnbr.html")) {
    print "Error opening report file.<br>\n";
    die " $0 : ". scalar(localtime(time))." Could not open $PATH_DYNAMIC_REP/$repnbr.html";
}

#seek warning: rewind depends on what O.S. you are: win use 2 bytes for newlines, unix only 1 byte
# also changing table layout or text can make incorrect rewinds.

if ($WINDOWS) {
    seek (REPORT, -263, 2);
}
else {
    seek (REPORT, -252, 2);
}

my $html_hlname=$hlname;
$html_hlname =~ s/(.*)<(.*)/$1&lt;$2/g; #algunos nombres son incompatibles con html <
$html_hlname =~ s/(.*)>(.*)/$1&gt;$2/g;

$date= scalar(localtime(time));
print REPORT "\n\n<tr><td>Report by <font size=\"+1\" color=\"#cc0000\"><strong>".$html_hlname;
print REPORT "</strong></font> on ". $date . "</td></tr>\n";
print REPORT "<tr><td align=\"center\"><hr size=\"1px\" width=\"600\"></td></tr>\n";
print REPORT "<tr><td bgcolor=\"dddddd\">\n";
print REPORT "<br>\n";
print REPORT $text;
print REPORT "<br>---<br>\n</td></tr>\n";
print REPORT "<tr><td>&nbsp;</td></tr>\n";

print REPORT <<EB2;



</table>
</center>
<div id="final">
<br>
<a href="/cgi-bin/write_comm.pl?repnbr=$repnbr">Write report</a><br><br>
<a href="/index.html" title="Inicio">Return</a>
<br>
<br>
</div> <!-- Cierra final -->
</div> <!-- Cierra reporte -->
</body></html>
EB2

close REPORT;

print<<Eoc;
  <head>
    <META HTTP-EQUIV='refresh' CONTENT='2; URL=$RELATIVE_DYNAMIC_REP/$repnbr.html#reports'>
  </head>
Eoc
    ;

$dbh->do("UPDATE $mis_prog SET coments = coments + 1 WHERE misrep=\"$repnbr\" and campanya=\"$CAMPANYA\" and mapa=\"$MAP_NAME_LONG\"");

print "Thanks for your comments. &nbsp;&nbsp;&nbsp; Reloading ...";
print "          </body></html>";

}




# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------

print_start_html();

# Limit upload size: to avid buffer overflow attack
$cgi_lib::maxdata = 5120; 
$cgi_lib::maxdata = 5120; 


&ReadParse(%in); # Read data

my $accion=$in{'accion'};

if ($accion eq "") { 

    $repnbr = $in{'repnbr'};
    # we expect a parameter rep + _ + 5 numbers. Later we add .html file extension.
    # this can be used to open other files (hacking), so we die in case paramerter do not fits on what we expect.
    if ($repnbr !~ m/^rep_[0-9]{5}$/) { 
	print "Error: Incorrect report number";
	print_end_html();
	die "write_comm.pl: incorrect report number";
    }

    # retrive cookie if exist
    my @rawCookies = split (/; /,$ENV{'HTTP_COOKIE'});
    foreach(@rawCookies){
	($key, $val) = split (/=/,$_);
	if ($key eq "badc_user"){
	    ($hlname,$pwd) = split (/ /,$val);
	}
    } 

    print_form(); # print  name and  password filed, icon images and offer textbox

}
elsif ($accion eq "Send") { #<input type=submit name=accion value=Send>

    $repnbr = $in{'repnbr'};
    if ($repnbr !~ m/^rep_[0-9]{5}$/) {  #same checking as before 
	print "Error: Incorrect report number";
	print_end_html();
	die "write_comm.pl: incorrect report number on Send action";
    }

    $hlname=$in{'hlname'};
    $pwd=$in{'pwd'};
    $hlname=~ s/^ *//g;
    $hlname=~ s/ *$//g;
    if ($hlname =~ m/ / || $hlname eq "" || $pwd eq "" ){ 
	print "Error: Name or password not valid<br>\n";
	print_end_html();
	die "write_comm.pl: name or password not valid check_1 <br>\n";
    }

    eval{fork and exit;};

    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    
    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    $sth = $dbh->prepare("SELECT password  FROM $pilot_file_tbl WHERE hlname=? and sqd_accepted=1");
    $sth->execute($hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $pwd) {
	print "Error: Name or password invalid <br>\n";
	print_end_html();
	die "write_comm.pl: name or password not valid check_2 <br>\n";
    }
    

    $text = $in{'comments'};
    
    #replace < >
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;

    #parse emoticons 
    $text =~ s/:\) / <img src=\"\/images\/mi01.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/;\) / <img src=\"\/images\/mi02.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:O / <img src=\"\/images\/mi03.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:D / <img src=\"\/images\/mi04.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:S / <img src=\"\/images\/mi05.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:\( / <img src=\"\/images\/mi06.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:\[ / <img src=\"\/images\/mi07.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:8 / <img src=\"\/images\/mi08.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:X / <img src=\"\/images\/mi09.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:o / <img src=\"\/images\/mi10.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:L / <img src=\"\/images\/mi11.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:\] / <img src=\"\/images\/mi12.gif\" border=\"0\" alt=\"\"> /g;

    $text =~ s/:P / <img src=\"\/images\/mi13.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:p / <img src=\"\/images\/mi14.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:C / <img src=\"\/images\/mi15.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:~ / <img src=\"\/images\/mi16.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:\^ / <img src=\"\/images\/mi17.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:V / <img src=\"\/images\/mi18.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:\| / <img src=\"\/images\/mi19.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:s / <img src=\"\/images\/mi20.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:\/ / <img src=\"\/images\/mi21.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:\% / <img src=\"\/images\/mi22.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:\* / <img src=\"\/images\/mi23.gif\" border=\"0\" alt=\"\"> /g;
    $text =~ s/:! / <img src=\"\/images\/mi24.gif\" border=\"0\" alt=\"\"> /g;

    $text =~ s/\[b\]/<b>/g;
    $text =~ s/\[\/b\]/<\/b>/g;
    $text =~ s/\[small\]/<font size=\"-1\">/g;
    $text =~ s/\[\/small\]/<\/font>/g;

    # new lines stuff
    $text =~ s/\n/<br>\n/g; 
    $text =~ s/\cM//g;
    write_comment();
}
else { # action is not "" and is not "Send"
    print "Error :) <br>\n";
}
print_end_html();
exit (0);



# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
$pilot_file_tbl=$pilot_file_tbl;
$mis_prog=$mis_prog;
$WINDOWS=$WINDOWS;
