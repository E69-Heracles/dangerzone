<?php  
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br>
<br>
<br>




<center>
<table border="0" width="835">

<tr>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td>
<font color="red" size=\"+1\">Warning:</font> By filling this form, with correct name and password, your pilot will be deleted from database. All your stats will be deleted and lost. You can not delete yourself if you are an active pilot in a squadron. First you have to leave squadron, from here: <a href="leave_squadron.php" title="Leave squadron">Leave&nbsp;Sqd</a>.<br><br>
</td>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
</tr>

<tr>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td align="center">

<?php

  $sqd=$HTTP_GET_VARS['sqd'];
  mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
  mysql_select_db("$database");

  print "<FORM METHOD=\"POST\" ACTION=\"/cgi-bin/delete_pilot.pl\"> <br>\n";
  print "<table>\n";
  print "<tr><td align=\"right\">Your name: </td><td><input type=\"text\" size=\"20\" name=\"hlname\"></td></tr>\n";
  print "<tr><td align=\"right\">Your Password : </td><td><input type=\"password\" size=\"15\" name=\"pwd\"></td></tr>\n";
  print "<tr><td></td><td> <input TYPE=\"SUBMIT\" VALUE=\"Delete pilot\"></td></tr>\n";
  print "</table></form>\n";
?>

</td>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
</tr></table>
</center>



<?php 
include ("./dz_page_footer.php");
?>
