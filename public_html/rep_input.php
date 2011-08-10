<?php   
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>
  <script type="text/javascript">
	function Check(){
	    if (document.rep.host.value == ""){
		alert("Enter your name.");
		return false;
	    }
	    if (document.rep.pwd.value == ""){
		alert("Enter your password");
		return false;
	    }
	    if (document.rep.upfile.value == ""){
		alert("Select a file.");
		return false;
	    }
	    if (document.rep.num.value == ""){
		alert("Write mission number to report.");
		return false;
	    }
	}
    </script>
<br>
<div id="central">

<h3>Mission Report</h3> 

<p>To report a mission you need to provide the <a href="manual.php#hostproc" title="Help: Host configuration">eventlog</a> (usually coop.txt) and indicate the mission number to report.<br><br>

<?php
list($hlname, $pwd) = split(' ', $HTTP_COOKIE_VARS["badc_user"]);
?>

    <FORM NAME=rep METHOD=POST ENCTYPE="multipart/form-data"
    ACTION="/cgi-bin/badc_par_2.pl" onSubmit="return Check()">
        Mission: <input type="TEXT" name="num" size=12 value="badc_00000">
	coop.txt: <input type="file" name="upfile" size="32"><br><br>

<?php
print "Name: <input type=\"text\" size=\"20\" name=\"host\" value=\"$hlname\">\n";
print "Password: <input type=\"password\" size=\"20\" name=\"pwd\" value=\"$pwd\">\n";
?>
	<input TYPE=SUBMIT VALUE="Send">
    </FORM>

<br>
<?php
if ($hlname){
    mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
    mysql_select_db("$database");

    $now_epoch=date("U");
    $five_hours_back=$now_epoch - 10800;

    $query="select misnum,date,time from badc_mis_prog where reported = 0 and epoca > $five_hours_back and host = \"$hlname\" and campanya=\"$campanya\" and mapa=\"$mapa\" order by misnum ASC";
    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

    print "Unreported missions (<b>3 hours back</b>):<br>\n<table  >\n<tr><td>N</td><td><b>Mission</b></td><td>date</td><td>time</td></tr>\n";
    $i=0;
    while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
        $i++;
        $misnum=$row[2];
        $date=$row[3];
        $time=$row[4];
        printf("<tr> <td> %d </td> <td>&nbsp;<font color=\"#CC0000\"><b>%s</b></font>&nbsp;</td> <td> %s </td> <td> %s </td><tr>\n", $i, $row[2], $row[3], $row[4]);
    } 
    print "</table>\n";
}
?> 
<br>

<?php 
include ("./dz_page_footer.php");
?>



