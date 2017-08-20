<?php  
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>


<br><br><br>

<center>

<FORM METHOD="GET" ACTION="sqd_admin2.php"> <br>
<table>
<tr><td align="right">Select your Squadron : </td> <td><select name="sqd" size="1">

<?php
	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");
	$query="select sqdname8 from badc_sqd_file order by sqdname8 ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
		$i++;
		$num=$row[0];
                                 $html_name=$row[0];
                                $html_name=preg_replace("/</","&lt;",$html_name); 
                                $html_name=preg_replace("/>/","&gt",$html_name); 
		printf("  <option value=\"%s\">%s</option>\n", $row[0], $html_name);
	} 
?> 
</select></td></tr>
<tr><td align="right"> </td><td> <input TYPE="SUBMIT" VALUE="Enviar"></td></tr>	
</table>
</form>

</center>

<br>
<br>

<?php 
include ("./dz_page_footer.php");
?>

