<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br/><br/><br/>


<?php
	$count=$_GET['count'];
  	$hlname=$_GET['hlname'];

	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");

	$query="select count(*) from badc_pilot_file where  hlname='$hlname' ";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
	$row = mysql_fetch_array($result, MYSQL_NUM);
	
	if (! $row[0]){
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
    <h3>&nbsp;&nbsp;<b><?php print "$html_hlname" ?></b> - Map air kills</h3>

 <table class=rndtable>
  <tr class=first>
    <td class="ltr70c">&nbsp;&nbsp;&nbsp;</td>
    <td class="ltr70c" align="center">Mission</td>
    <td class="ltr70c" align="center">Pilot</td>
    <td class="ltr70c" align="center">Plane</td>
    <td class="ltr70c" align="center">Downs to</td>
    <td class="ltr70c" align="center">in plane</td>
  </tr>

<?php

$tdo="<td class=\"ltr70c\">";
$tdor="<td class=\"ltr70c\" align=\"right\">";
$tdoc="<td class=\"ltr70c\" align=\"center\">";
$tdol="<td class=\"ltr70c\" align=\"left\">";


	$query="select count(*) from badc_air_event where hlkiller='$hlname' and campanya = \"$campanya\" and mapa =\"$mapa\" ";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);
	$totalk=$row[0];

	$query="select misnum,misrep,hlkiller,plane_killer,hlkilled,plane_killed,wasfriend from badc_air_event where hlkiller='$hlname' and campanya = \"$campanya\" and mapa =\"$mapa\" order by misnum DESC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

	$i=0;
	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
		$i++;

		if ($i%2) { printf("\n <tr>\n");}
		else      { printf("\n <tr class=odd>\n");}	

		if ($use_regex) {
			$row[2]=preg_replace("/</","&lt;",$row[2]);
			$row[2]=preg_replace("/>/","&gt;",$row[2]);
		}
		$hlkilled=$row[4];
		$row[4]=preg_replace("/</","&lt;",$row[4]);	
		$row[4]=preg_replace("/>/","&gt;",$row[4]);
		$hlkilled=preg_replace("/\+/","%2B",$hlkilled);	

		$wasfriend=$row[6];
		if (!$wasfriend){
		    printf ("$tdo %d </td>$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n$tdo <b>&nbsp;%s&nbsp;</b></td>\n$tdo &nbsp;%s&nbsp; </td>\n$tdo &nbsp;<a href=\"pilot.php?hlname=%s\">%s</a>&nbsp;</td>\n$tdo &nbsp;%s&nbsp; </td></tr>\n",($totalk-$i+1),$row[1], $row[1], $row[2], $row[3], $hlkilled, $row[4], $row[5]);
                }
		else {
		    printf ("$tdo %d </td>$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n$tdo <font color=\"red\"><b>&nbsp;%s&nbsp;</b></font></td>\n$tdo &nbsp;%s&nbsp; </td>\n$tdo &nbsp;<a href=\"pilot.php?hlname=%s\">%s</a>&nbsp;</td>\n$tdo<font color=\"red\">&nbsp;%s&nbsp;</font></td></tr>\n",($totalk-$i+1),$row[1], $row[1], $row[2], $row[3], $hlkilled, $row[4], $row[5]);
                }
	}
?> 

</table>
</center>


<br><br>  


<?php 
include ("./dz_page_footer.php");
?>
