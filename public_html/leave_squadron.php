<?php  
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br>
<br>
<br><br>

<center>
<table border="0" width=835>

<tr>
	<td>
		<font color="red" size=\"+1\">Warning:</font> Cuando rellenes este formulario con tu nombre de usuario y password
		se borrará el registro de tu piloto en el escuadrón en el que esté activo. Tu piloto será movido a un escuadron 
		por defecto llamado "(NONE)" y posteriormente podrás unirte a cualquier otro escuadrón. 
		Stats and nickname will be moved into a default squadron (NONE), So later 
		you can join any other squadron. If you are the CO of a squadron you can not leave. First you have to leave CO place 
		to other member. If you are the CO and only member, you should use <b>delete squadron option</b>.<br><br>
	
		If you are the CO/XO of a squadron and you are looking to remove a pilot from your squadron (not your self), please use 
		<a href="sqd_admin.php" title="Admin squadron">Squad&nbsp;admin</a> menu, and fill 
		<font color="red">Remove</font> pilot form.<br><br><br>
	</td>
</tr>

<tr>
<td align="center">

<?php

  $sqd=$_GET['sqd'];
  mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
  mysql_select_db("$database");

  print "<FORM METHOD=\"POST\" ACTION=\"/cgi-bin/leave_squad.pl\"> <br>\n";

  // pilot name cant have spaces, so is safe to use "self remove"
  print "<input type=\"hidden\" name=\"boot_pilot\" value=\"self remove\">\n";
  print "<table>\n";
  print "<tr><td align=\"right\">Your name: </td><td><input type=\"text\" size=\"20\" name=\"hlname\"></td></tr>\n";
  print "<tr><td align=\"right\">Your Password : </td><td><input type=\"password\" size=\"15\" name=\"pwd\"></td></tr>\n";
  print "<tr><td></td><td> <input TYPE=\"SUBMIT\" VALUE=\"Leave Sqd\"></td></tr>\n";
  print "</table></form>\n";

?>

</td>
</tr></table>
</center>

<br><br>

<?php 
include ("./dz_page_footer.php");
?>

