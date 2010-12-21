<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br><br><br>

<FORM METHOD="POST" ACTION="/cgi-bin/join_sqd.pl"> <br>
<table>
<tr><td align="right">Select a Squadron : </td> <td><select name="sqd_id" size="1">

<?php
	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");
	$query="select id,sqdname8 from badc_sqd_file order by sqdname8 ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
		$i++;
		$num=$row[0];	
		$row[1]=preg_replace("/</","&lt;",$row[1]);
		$row[1]=preg_replace("/>/","&gt;",$row[1]);
		printf("  <option value=\"%s\">%s</option>\n", $row[0], $row[1]);
	} 
?> 
</select></td></tr>
<tr><td align="right">&nbsp; &nbsp; &nbsp; HypperLobby nickname : </td><td><input type="text" size="20" name="hlname"></td></tr>
<tr><td align="right">Password : </td><td><input type="password" size="15" name="pwd"></td></tr>
<tr><td align="right">&nbsp;</td><td> <input TYPE="SUBMIT" VALUE="Enviar"></td></tr>	
</table>
</form>


<br>
<br>

<?php 
include ("./dz_page_footer.php");
?>