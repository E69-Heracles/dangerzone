<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br/><br/><br/>
<?php
		print "<FORM METHOD=\"GET\" ACTION=\"sqd_file.php\">\n<b>Find Sqd:</b>\n";
		print "<input type=\"text\" size=\"16\" name=\"sqd\" value=\"$sqd\">\n<input TYPE=\"SUBMIT\" VALUE=\"Find\">\n</form>\n";

?>


<FORM METHOD="GET" ACTION="sqd_file.php"> <br>
<table >
<tr><td align="right">Select Squadron : </td> <td><select name="sqd" size="1">
<option value="NONE">------------------</option> 

<?php
	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");
	$query="select sqdname8 from badc_sqd_file order by sqdname8 ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
		$i++;
		$num=$row[0];
		if ($row[0] != "NONE") {
		$row[0]=preg_replace("/</","&lt;",$row[0]);
		$row[0]=preg_replace("/>/","&gt;",$row[0]);
			printf("  <option value=\"%s\">%s</option>\n", $row[0], $row[0]);
		}
	} 
?> 
</select></td>
<td align="right">&nbsp;</td><td> <input TYPE="SUBMIT" VALUE="Vew"></td></tr>	
</table>
</form>

<?php 
include ("./dz_page_footer.php");
?>