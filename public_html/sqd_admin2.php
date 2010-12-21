<?php  
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br><br><br>

<center>
<table border="0" width=635><tr><td>
<?php

  	$sqd=$HTTP_GET_VARS['sqd'];

	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");

	print "<FORM METHOD=\"POST\" ACTION=\"/cgi-bin/accept_pilot.pl\"> <br>\n";
	print "<table>\n";
	print "<tr><td align=\"right\">Squadron : </td><td><input type=\"text\" name=\"sqd\" value=\"$sqd\" readonly></td></tr>\n";	
	print "<tr><td align=\"right\"><font color=\"#009933\">Accept</font> aplication : </td> <td><select name=\"addpilot\" size=\"1\">\n";
	print "<option>Select pilot</option>";
	$query="select hlname from badc_pilot_file where in_sqd_name='$sqd' and sqd_accepted='0' order by hlname ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
		$pending=$row[0];
		$html_pending=$pending;
		$html_pending=preg_replace("/</","&lt;",$html_pending);
		$html_pending=preg_replace("/>/","&gt;",$html_pending);
		printf("<option value=\"%s\">%s</option>\n",$pending,$html_pending);
	} 
	print "</select></td></tr>\n";

	print "<tr><td align=\"right\">CO/XO name: </td><td><input type=\"text\" size=\"20\" name=\"hlname\"></td></tr>\n";
	print "<tr><td align=\"right\">CO/XO Password : </td><td><input type=\"password\" size=\"15\" name=\"pwd\"></td></tr>\n";
	print "<tr><td></td><td> <input TYPE=\"SUBMIT\" VALUE=\"Incorporate\"></td></tr>\n";
	print "</table></form>\n";
?>
</td><td>

<?php
	print "<FORM METHOD=\"POST\" ACTION=\"/cgi-bin/reject_pilot.pl\"> <br>\n";
	print "<table>\n";
	print "<tr><td align=\"right\">Squadron : </td><td><input type=\"text\" name=\"sqd\" value=\"$sqd\" readonly></td></tr>\n";	
	print "<tr><td align=\"right\"><font color=\"red\">Reject</font>  aplication : </td> <td><select name=\"rejpilot\" size=\"1\">\n";
	print "<option>Select pilot</option>";
	$query="select hlname from badc_pilot_file where in_sqd_name='$sqd' and sqd_accepted='0' order by hlname ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
		$pending=$row[0];
		$html_pending=$pending;
		$html_pending=preg_replace("/</","&lt;",$html_pending);
		$html_pending=preg_replace("/>/","&gt;",$html_pending);
		printf("<option value=\"%s\">%s</option>\n",$pending,$html_pending);
	} 
	print "</select></td></tr>\n";

	print "<tr><td align=\"right\">CO/XO name: </td><td><input type=\"text\" size=\"20\" name=\"hlname\"></td></tr>\n";
	print "<tr><td align=\"right\">CO/XO Password : </td><td><input type=\"password\" size=\"15\" name=\"pwd\"></td></tr>\n";
	print "<tr><td></td><td> <input TYPE=\"SUBMIT\" VALUE=\"Reject\"></td></tr>\n";
	print "</table></form>\n";
?>
</td></tr>
<tr><td>
<?php

  	$sqd=$HTTP_GET_VARS['sqd'];

	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");

	print "<FORM METHOD=\"POST\" ACTION=\"/cgi-bin/leave_squad.pl\"> <br>\n";
	print "<table>\n";
	print "<tr><td align=\"right\">Squadron : </td><td><input type=\"text\" name=\"sqd\" value=\"$sqd\" readonly></td></tr>\n";	
	print "<tr><td align=\"right\"><font color=\"red\">Remove</font> pilot: </td> <td><select name=\"boot_pilot\" size=\"1\">\n";
	print "<option>Select pilot</option>";
	$query="select hlname from badc_pilot_file where in_sqd_name='$sqd' and sqd_accepted='1' order by hlname ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
		$pending=$row[0];
		$html_pending=$pending;
		$html_pending=preg_replace("/</","&lt;",$html_pending);
		$html_pending=preg_replace("/>/","&gt;",$html_pending);
		printf("<option value=\"%s\">%s</option>\n",$pending,$html_pending);
	} 
	print "</select></td></tr>\n";

	print "<tr><td align=\"right\">CO/XO name: </td><td><input type=\"text\" size=\"20\" name=\"hlname\"></td></tr>\n";
	print "<tr><td align=\"right\">CO/XO Password : </td><td><input type=\"password\" size=\"15\" name=\"pwd\"></td></tr>\n";
	print "<tr><td></td><td> <input TYPE=\"SUBMIT\" VALUE=\"Delete\"></td></tr>\n";
	print "</table></form>\n";
?>
</td></tr></table>
</center>

<br>
<br>


<?php 
include ("./dz_page_footer.php");
?>
