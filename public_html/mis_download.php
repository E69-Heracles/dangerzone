<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php"); 
?>

<br>
<div id="central">


<h3>Confirm mission download:</h3>

<br>

<FORM METHOD="POST" ACTION="/cgi-bin/badc_gen_2.pl"> <br>

<?php

list($hlname, $pwd) = split(' ', $HTTP_COOKIE_VARS["badc_user"]);

$red_solic=$HTTP_GET_VARS['red_solic'];
$blue_solic=$HTTP_GET_VARS['blue_solic'];	

print "<input type=\"hidden\" name=\"red_solic\" value=\"$red_solic\">";
print "<input type=\"hidden\" name=\"blue_solic\" value=\"$blue_solic\">";

print "<table>\n";
print "<tr><td align=\"right\">Name: </td><td><input type=\"text\" size=\"20\" name=\"host\" value=\"$hlname\"></td></tr>\n";
print "<tr><td align=\"right\">Password: </td><td><input type=\"password\" size=\"20\" name=\"pwd\" value=\"$pwd\"></td></tr>\n";
?>
<tr><td align="right">&nbsp;</td><td> <input TYPE="SUBMIT" VALUE="Send"></td></tr>	
</table>
</form>

</div>
<br>
<br>

<?php 
include ("./dz_page_footer.php");
?>