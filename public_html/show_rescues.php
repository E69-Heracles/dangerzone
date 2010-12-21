<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br/><br/><br/>



<?php
	$count=$HTTP_GET_VARS['count'];
  	$hlname=$HTTP_GET_VARS['hlname'];

	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");

	$query="select count(*) from badc_pilot_file where  hlname='$hlname' ";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
	$row4 = mysql_fetch_array($result, MYSQL_NUM);
	
	if (! $row4[0]){
		print "<br><br><br>Pilot not found</div></body></html>";
		exit(0);
	}

	// el piloto existe
	$html_hlname=$hlname;
	$use_regex=0;
	if (preg_match("/[<>]/",$hlname)){
 		$use_regex=1;
		$html_hlname=preg_replace("/</","&lt;",$html_hlname);
		$html_hlname=preg_replace("/>/","&gt;",$html_hlname);
	}


?>

  <center>
    <h3> <b><?php print "$html_hlname" ?></b> - Rescued pilots</h3>

 <table class=rndtable>
  <tr class=first>
    <td class="ltr70c">&nbsp;&nbsp;&nbsp;</td>
    <td class="ltr70c" align="center">Mission</td>
    <td class="ltr70c" align="center">Pilot</td>
    <td class="ltr70c" align="center">Rescued to</td>
  </tr>

<?php

$tdo="<td class=\"ltr70c\">";
$tdor="<td class=\"ltr70c\" align=\"right\">";
$tdoc="<td class=\"ltr70c\" align=\"center\">";
$tdol="<td class=\"ltr70c\" align=\"left\">";


	$query="select count(*) from badc_rescues where rescatador='$hlname' ";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row4 = mysql_fetch_array($result, MYSQL_NUM);
	$totalresc=$row4[0];

	$query="select misnum,misrep,rescatado from badc_rescues where rescatador='$hlname' order by misnum DESC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

	$irc=0;
	while ($row4 = mysql_fetch_array($result, MYSQL_NUM)) {
		$irc++;

		if ($i%2) { printf("\n <tr>\n");}
		else      { printf("\n <tr class=odd>\n");}	

	
		$rescatado=$row4[2];
		$row4[2]=preg_replace("/</","&lt;",$row4[2]);	
		$row4[2]=preg_replace("/>/","&gt;",$row4[2]);
		$rescatado=preg_replace("/\+/","%2B",$rescatado);	


		printf ("
	$tdo %d </td>\n
	$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n
	$tdo <b>&nbsp;%s&nbsp;</b></td>\n
	$tdo &nbsp;<a href=\"pilot.php?hlname=%s\">%s</a>&nbsp;</td>\n ",($totalresc-$irc+1),$row4[1], $row4[1], $html_hlname, $rescatado, $row4[2]);
	}

?> 

</table>
</center>


<br><br>  


<?php 
include ("./dz_page_footer.php");
?>
