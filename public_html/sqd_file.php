<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<?php
	$allow_images = $_COOKIE["badc_images"];

	$sort="";
	$sort=$_GET['sort'];
	if ($sort == ""){$sort="missions";}

	$order="";
	$order=$_GET['order'];
	if ($order == ""){$order="DESC";}

	if ($order=="ASC") {$inv_ord="DESC";}
	else { $order=="DESC"; $inv_ord="ASC";}
	
  	$sqd=$_GET['sqd'];
	$html_sqd=$sqd;

	$use_regex=0;
	if (preg_match("/[<>]/",$sqd)){
 		$use_regex=1;
		$html_sqd=preg_replace("/</","&lt;",$html_sqd);
		$html_sqd=preg_replace("/>/","&gt;",$html_sqd);
	}



	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");

	$query="select count(*) from badc_sqd_file where  sqdname8='$sqd' ";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
	$row = mysql_fetch_array($result, MYSQL_NUM);
	
	if (! $row[0]){

		$html_hlname=$hlname;
		$html_hlname=preg_replace("/</","&lt;",$html_hlname);
		$html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	        print "<br><br><center>";
		print "<FORM METHOD=\"GET\" ACTION=\"sqd_file.php\">\n<b>Sqd Name:</b> \n";
		print "<input type=\"text\" size=\"16\" name=\"sqd\" value=\"$sqd\">\n<input TYPE=\"SUBMIT\" VALUE=\"Buscar\">\n</form>\n";

		if( ! ($sqd == "") ){

			$sqd="%$sqd%";

			$query="select count(*) from badc_sqd_file where  sqdname8 LIKE '$sqd' ";
			$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
			$row = mysql_fetch_array($result, MYSQL_NUM);
			
			print "<br>Found $row[0] squadrons matching: &nbsp;&nbsp;<i> $html_sqd </i> <br>\n";

			if($row[0]){
				$i=0;
				$query="select sqdname8 from badc_sqd_file where  sqdname8 LIKE '$sqd' ";
				$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
		
				print "<br><table >\n";
				while ($row = mysql_fetch_array($result, MYSQL_NUM)) {	
					$i++;
					$html_sqd=$row[0];
					$html_sqd=preg_replace("/</","&lt;",$html_sqd);
					$html_sqd=preg_replace("/>/","&gt;",$html_sqd);
					$row[0]=preg_replace("/\+/","%2B",$row[0]);	
					printf("<tr><td>%d - </td><td><a href=\"sqd_file.php?sqd=%s\"><b>%s</b></a></td></tr>\n",$i,$row[0],$html_sqd);
				}
				print "</table>\n";
			}
		}

		print "<br><br><br>\n</center></div></body></html>";
		exit(0);
	}

?>



	

<center>




<?php

	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$dataabse");

	$query="select coname,comail,xoname,xomail,sqdname,sqdweb,sqdlogo,sqd_army,totalpilot,totalmis,totalakill,totalgkill,totalvict,totalpoints,date_join from badc_sqd_file where sqdname8='$sqd'";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);

	print "<br/><br/><center>\n";
	print "    <table  border=\"0\"><tr><td>\n";

	$row[5]=preg_replace("/http:\/\//","",$row[5]); // remove http://
	$row[6]=preg_replace("/http:\/\//","",$row[6]); // remove http://

	if ($row[6]){ // if avatar defined
  		print "<a target=\"window\" href=\"http://$row[5]\">\n        <img border=\"0\"  alt=\"\" src=\"http://$row[6]\">\n        </a>\n";
	}
	else {
  		print "<a target=\"window\" href=\"http://$row[5]\">$row[5]</a>\n";
	}
	print "</td>\n";
	print "<td width=50px></td>\n";
	print "<td valign=middle align=center>\n";
	print "<b>$row[4]</b><br/><br/>\n";
			
	print "    <table class=rndtable_nohover border=\"0\">\n";	

	if ($row[7]==1){ 
		print "      <tr><td><img src=\"images/sov_sqd.gif\" alt=\"\"></td>\n";}
	if ($row[7]==2){ 
		if ($allow_images) {
			print "      <tr><td><img src=\"images/ger_sqd_ok.gif\" alt=\"\"></td>\n";
		}
		else {
			print "      <tr><td><img src=\"images/ger_sqd.gif\" alt=\"\"></td>\n";
		}
	}

	print "  <td>\n\n";		

	$html_hlname=$row[0];
	$html_hlname=preg_replace("/</","&lt;",$html_hlname);
	$html_hlname=preg_replace("/>/","&gt;",$html_hlname);	

	print "  <table  border=\"0\">\n";
	print "    <tr><td>Co: <b>$html_hlname</b> </td><td><a href=\"mailto: $row[1]\"><img border=\"0\" src=\"images/e.gif\" alt=\"\"></a></td></tr>\n";

	if ($row[2] != ""){
	$html_hlname=$row[2];
	$html_hlname=preg_replace("/</","&lt;",$html_hlname);
	$html_hlname=preg_replace("/>/","&gt;",$html_hlname);	
	print "    <tr><td>Xo: <b>$html_hlname</b> </td><td><a href=\"mailto: $row[3] \"><img border=\"0\"src=\"images/e.gif\" alt=\"\"></a></td></tr>\n";}
	print "    <tr><td colspan=\"2\"><hr size=\"1\"></td></tr>\n";
	print "    </table>\n";

	print "  </td></tr>\n\n";		
	print "</table>\n";
	print "</td></tr></table>\n";
	print "</center>\n";



   	print "<h3>$html_sqd</h3>\n";

	

 
    $order="DESC"; // defalut order
    if($_GET['order']) {$order=$_GET['order'];}
    if ( $order != "ASC" && $order != "DESC") {print "Error: Unknow order: $order"; die;}

    $minmis=0; // default minmis
    $minmis_cmd=""; // default minmis_cmd

    $key="points"; // default key
    if($_GET['key']) { $key=$_GET['key']; }
    if ( $key != "missions"  && $key != "akills"    && $key != "gkills" && 
         $key != "friend_ak" && $key != "friend_gk" && $key != "chutes" &&
         $key != "smoke"     && $key != "lights"    && $key != "hlname" && $key != "points" &&
         $key != "kia_mia"   && $key != "ak_x_mis"  && $key != "gk_x_mis" && $key != "rescues" &&
         $key != "ak_x_kia"  && $key != "gk_x_kia"  && $key != "rank"     && $key != "pnt_steak_max" && 
         $key != "mis_steak_max" && $key != "a_steak_max" && $key != "g_steak_max" && $key != "experience") 
	{print "Error: Unknow key: $key"; die;}


print  "<table class=rndtable>\n";
print  "  <tr class=first>\n";
print  "  <td class=\"ltr70c\">Nr</td>\n"; 
print  "  <td class=\"ltr70c\"><a title=\"Sort by alphabetic Pilot name\"href=\"./sqd_file.php?sqd=$sqd&amp;key=hlname&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Pilot</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by points\" href=\"./sqd_file.php?sqd=$sqd&amp;key=points&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Points</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by total missions\" href=\"./sqd_file.php?sqd=$sqd&amp;key=missions&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Mis</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by total Rescues\" href=\"./sqd_file.php?sqd=$sqd&amp;key=rescues&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Resc</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by total Kia +Mia\" href=\"./sqd_file.php?sqd=$sqd&amp;key=kia_mia&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Kia+Mia</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by total Air kills\" href=\"./sqd_file.php?sqd=$sqd&amp;key=akills&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>AirK</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by total Ground kills\" href=\"./sqd_file.php?sqd=$sqd&amp;key=gkills&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>GndK</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by Air kills per mission\" href=\"./sqd_file.php?sqd=$sqd&amp;key=ak_x_mis&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Akill/Mis</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by Ground kills per mission\" href=\"./sqd_file.php?sqd=$sqd&amp;key=gk_x_mis&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Gkill/Mis</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by airkills per kia. Total kills in case never kia/mia\" href=\"./sqd_file.php?sqd=$sqd&amp;key=ak_x_kia&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Akill/Kia</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by ground kills per kia. Total kills in case never kia/mia\" href=\"./sqd_file.php?sqd=$sqd&amp;key=gk_x_kia&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Gkill/Kia</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by MAX mission streak.\" href=\"./sqd_file.php?sqd=$sqd&amp;key=mis_steak_max&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>MMS</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by MAX Airkils streak.\" href=\"./sqd_file.php?sqd=$sqd&amp;key=a_steak_max&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>MAS</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by MAX gorund kill streak\" href=\"./sqd_file.php?sqd=$sqd&amp;key=g_steak_max&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>MGS</b></a></td>
    <td class=\"ltr70c\"><a title=\"Sort by Experience\" href=\"./sqd_file.php?sqd=$sqd&amp;key=experience&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Exp</b></a></td>
    <td class=\"ltr70c\" align=\"center\"><a title=\"Sort by Rank\" href=\"./sqd_file.php?sqd=$sqd&amp;key=rank&amp;order=$order&amp;army=$army&amp;minmis=$minmis\"><b>Rank</b></a></td>
  </tr>\n";




    $query="select hlname,missions,kia_mia,akills,gkills,ak_x_mis,gk_x_mis,ak_x_kia,gk_x_kia,friend_ak,friend_gk,chutes,smoke,lights,rescues,sqd_army,points,rank,mis_steak_max,a_steak_max,g_steak_max,experience from badc_pilot_file where in_sqd_name='$sqd' and sqd_accepted='1'$minmis_cmd order by $key $order ";
    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());


    $tdo="<td class=\"ltr70c\">";
    $tdor="<td class=\"ltr70c\" align=\"right\">";
    $tdoc="<td class=\"ltr70c\" align=\"center\">";
    $tdol="<td class=\"ltr70c\" align=\"left\">";

    while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
	$i++;

	if ($i%2) { printf("\n<tr>\n");}
		else { printf("\n<tr class=odd>\n");}	


	$html_hlname=$row[0];
	$html_hlname=preg_replace("/</","&lt;",$html_hlname);
	$html_hlname=preg_replace("/>/","&gt;",$html_hlname);	
	$row[0]=preg_replace("/\+/","%2B",$row[0]);	


	printf("$tdo %d</td>\n",$i);


	printf("$tdo <a href=\"./pilot.php?hlname=%s\">%s</a></td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %.2f </td>\n$tdoc %.2f</td>",$row[0],$html_hlname,$row[16],$row[1],$row[14],$row[2],$row[3],$row[4],$row[5],$row[6]);

	printf("$tdoc %.2f </td>\n$tdoc %.2f </td>\n",$row[7],$row[8]);

	printf("$tdoc %d </td>\n$tdoc %d </td>\n$tdoc %d </td>\n$tdoc %s </td>\n",$row[18],$row[19],$row[20],$row[21]);

	$rank=$row[17];

if ($row[15] == 1) {
	if ($rank == 0) { print "$tdol Krasnoarmeyets</td> </tr>\n"; }
	if ($rank == 1) { print "$tdol Serzhant</td> </tr>\n"; }
	if ($rank == 2) { print "$tdol Leytenant</td> </tr>\n"; }
	if ($rank == 3) { print "$tdol Starshiy Leitenant</td> </tr>\n"; }
	if ($rank == 4) { print "$tdol Kapitan</td> </tr>\n"; }
	if ($rank == 5) { print "$tdol Mayor</td> </tr>\n"; }
	if ($rank == 6) { print "$tdol Podpolkovnik </td> </tr>\n"; }
	if ($rank == 7) { print "$tdol Polkovnik</td> </tr>\n"; }
	}
if ($row[15] == 2) {
	if ($rank == 0) { print "$tdol Flieger</td> </tr>\n"; }
	if ($rank == 1) { print "$tdol Feldbewel</td> </tr>\n"; }
	if ($rank == 2) { print "$tdol Leutnant</td> </tr>\n"; }
	if ($rank == 3) { print "$tdol Oberleutnant</td> </tr>\n"; }
	if ($rank == 4) { print "$tdol Hauptmann</td> </tr>\n"; }
	if ($rank == 5) { print "$tdol Major</td> </tr>\n"; }
	if ($rank == 6) { print "$tdol Oberstleutnant</td> </tr>\n"; }
	if ($rank == 7) { print "$tdol Oberst</td> </tr>\n"; }
	}     


    }

   print "</table>\n";

   $text_order="desc"; // default order
   if ($order == "ASC") {$text_order="asc";}
   print "<font size=\"-2\">";
   print " &nbsp;&nbsp;&nbsp; Order by <b>$key</b>, <b>$text_order</b>. &nbsp;&nbsp;&nbsp;\n";
   print " <font color=\"#cc0000\"> Displaying only pilots with at least <font size=\"+1\"><b>$minmis</b></font> missions.</font>\n";
   print "</font>\n";

?> 


<?php



	//Incorporación pendiente


	$query="select count(*) from badc_pilot_file where in_sqd_name='$sqd' and sqd_accepted='0'";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);

	if ($row[0]>0) {

	       $query="select hlname,missions,akills,gkills,experience,points from badc_pilot_file where in_sqd_name='$sqd' and sqd_accepted='0' order by $sort $order";
		$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
		$i=0; // pilot counter 

		print "<br><br><br><h3>Pending incorporations:</h3><br>\n";
	
		$tdoc="<td align=\"center\" bgcolor=\"#dddddd\" class=ltr70c>&nbsp;";
		$tdoc2="<td align=\"center\" bgcolor=\"#cccccc\" class=ltr70c>&nbsp;";
		$tdor="<td align=\"right\" bgcolor=\"#cccccc\" class=ltr70c>&nbsp;";
		$tdo="<td bgcolor=\"#cccccc\" class=ltr70c>&nbsp;";
		$space_5="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		$space_10="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		print "<table  border=\"0\" class=rndtable_nohover>";
		print "<tr class=first>\n";
		print "$tdoc2<a title=\"Invert order\" href=\"sqd_file.php?sqd=$sqd&amp;sort=$sort&amp;order=$inv_ord\">^</a>&nbsp;</td>\n";
		print "$tdo $space_5 <a href=\"sqd_file.php?sqd=$sqd&amp;sort=hlname&amp;order=$order\">Name</a> $space_10 </td>\n";
		print "$tdoc <a href=\"sqd_file.php?sqd=$sqd&amp;sort=missions&amp;order=$order\">Missions</a> &nbsp;</td>\n";
		print "$tdoc <a href=\"sqd_file.php?sqd=$sqd&amp;sort=akills&amp;order=$order\">A-Kills</a> &nbsp;</td>\n";
		print "$tdoc <a href=\"sqd_file.php?sqd=$sqd&amp;sort=gkills&amp;order=$order\">G-Kills</a> &nbsp;</td>\n";
		print "$tdoc <a href=\"sqd_file.php?sqd=$sqd&amp;sort=experience&amp;order=$orders\">Experience</a> &nbsp;</td>\n";
		print "$tdoc <a href=\"sqd_file.php?sqd=$sqd&amp;sort=points&amp;order=$order\">Points</a> &nbsp;</td>\n";
		print "</tr>\n";	

		while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
			$i++;
			$html_hlname=$row[0];
			$html_hlname=preg_replace("/</","&lt;",$html_hlname);
			$html_hlname=preg_replace("/>/","&gt;",$html_hlname);	
			$row[0]=preg_replace("/\+/","%2B",$row[0]);	
			printf("<tr>$tdor%s</td>$tdo<a href=\"pilot.php?hlname=%s\">%s</a></td>$tdoc%s</td>$tdoc%s</td>$tdoc%s</td>$tdoc%s</td>$tdoc%s</td></tr>\n",$i,$row[0],$html_hlname,$row[1],$row[2],$row[3],$row[4],$row[5]);
    		}	
		print "</table>";
	}

?> 

<br>
<br>

<div id="final">
   
<?php 
include ("./dz_page_footer.php");
?>
