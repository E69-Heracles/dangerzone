<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br/><br/><br/>
<?php
		print "<FORM METHOD=\"GET\" ACTION=\"pilot.php\">\n<b>Find Name:</b>\n";
		print "<input type=\"text\" size=\"16\" name=\"hlname\" value=\"$hlname\">\n<input TYPE=\"SUBMIT\" VALUE=\"Find\">\n</form>\n";

?>

<?php 
include ("./dz_page_footer.php");
?>