<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<?php

    $allow_images = $HTTP_COOKIE_VARS["badc_images"];

    $minmis=0; // default minmis
    $minmis_cmd=""; // default minmis_cmd
    $army=0;       // default army 0 = all
    $army_cmd="";   // def army_cmd

    if($HTTP_GET_VARS['minmis']) { $minmis=$HTTP_GET_VARS['minmis']; }
    if ($minmis<0) {$minmis=0;}
    if ($minmis){$minmis_cmd="and totalmis >= $minmis";}

    if($HTTP_GET_VARS['army']) { $army=$HTTP_GET_VARS['army']; }
    if ($army<0 || $army>2) {$army=0;}
    if ($army){$army_cmd="and sqd_army = $army";}  //&amp;army=$army

    $key="totalpoints"; // default key
    if($HTTP_GET_VARS['key']) { $key=$HTTP_GET_VARS['key']; }
    if ( $key != "totalpilot" && $key != "totalmis"  && $key != "totalakill"   && $key != "totalgkill" 
	&& $key != "totalvict" && $key != "totalpoints" && $key != "totalkiamia" && $key != "ak_x_mis" 
	&& $key != "gk_x_mis"  && $key != "points_x_mis" && $key != "kia_x_mis" && $key != "sqdname8" ) 
	{print "Error: Unknow key: $key"; die;}	

    $offset=0; // default offset
    if($HTTP_GET_VARS['offset']) { $offset=$HTTP_GET_VARS['offset']; }
    if (preg_match("/[^-0-9]/",$offset)){print "Error: Unknow offset: $offset"; die;}
    if ($offset<0) {$offset=0;}
 
    $order="DESC"; // defalut order
    if($HTTP_GET_VARS['order']) {$order=$HTTP_GET_VARS['order'];}
    if ( $order != "ASC" && $order != "DESC") {print "Error: Unknow order: $order"; die;}

    print "<br>\n";
    print "<center>\n";

   print "<FORM METHOD=\"GET\" ACTION=\"find_sqd.php\">\n<b> Search Sqd 
   Name:</b> \n"; print "<input type=\"text\" size=\"16\" name=\"hlname\" 
   value=\"$hlname\">\n<input TYPE=\"SUBMIT\" VALUE=\"Find\">\n</form>\n";


   
    $rev_order="ASC"; // default rev order
    if ($order == "ASC") {$rev_order="DESC";}
    print "<a href=\"./all_sqds.php?key=$key&amp;order=$rev_order&amp;minmis=$minmis&amp;army=$army&amp;offset=$offset\">Invert order</a>\n";
    print "&nbsp;&nbsp;\n";


   print "&nbsp; Min mis: [&nbsp;\n";
   print "<a href=\"./all_sqds.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=".($minmis-10)."&amp;offset=$offset\">-10</a>\n";
   print "&nbsp;&nbsp;<a href=\"./all_sqds.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=0&amp;offset=$offset\">clear</a>&nbsp;&nbsp;\n";
   print "<a href=\"./all_sqds.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=".($minmis+10)."&amp;offset=$offset\">+10</a>\n";
   print "&nbsp;]\n";

   print "&nbsp; Army: [&nbsp;\n";
   print "<a href=\"./all_sqds.php?key=$key&amp;order=$order&amp;army=0&amp;minmis=$minmis&amp;offset=$offset\">All</a>\n";
   print "<a href=\"./all_sqds.php?key=$key&amp;order=$order&amp;army=1&amp;minmis=$minmis&amp;offset=$offset\">Rus</a>\n";
   print "<a href=\"./all_sqds.php?key=$key&amp;order=$order&amp;army=2&amp;minmis=$minmis&amp;offset=$offset\">Ger</a>\n";
   print "&nbsp;]\n";


   print "<br>\n";

    mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
    mysql_select_db("$database");

    $query="select count(*) from badc_sqd_file where sqdname8 <> \"NONE\" $minmis_cmd $army_cmd";
    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
    $row = mysql_fetch_array($result, MYSQL_NUM);

    $pg= ($row[0] / 20);
    
    print "<font size=\"-1\">\n";
    for ($k=0; $k<$pg ; $k++) {
	if ($k %20 ==0) { print "<br>";}
	if ( ($offset /20) != $k ) {
    		print "<a href=\"./all_sqds.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=".($minmis)."&amp;offset=".($k*20)."\">";
		if ($k<9) { print "0";}
		print ($k+1)."</a>&nbsp;\n";
	}
	else {
		print "<b>[";
		if ($k<9) { print "0";}
		print ($k+1)."]</b>\n";
	}

    }
    print "</font>\n";
   print "<br>\n</center>\n";



?>


<center>

 <table class=rndtable><tr class=first>
    <td class="ltr70c">Nr</td> 
    <td class="ltr70c">Army</td> 
    <td class="ltr70c"><a title="Sort by alphabetic prefix"
		href="./all_sqds.php?key=sqdname8&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Prefix</b></a></td>
    <td class="ltr70c"><a title="Sort by pilot numbers"
		href="./all_sqds.php?key=totalpilot&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Pilots</b></a></td>
    <td class="ltr70c"><a title="Sort by total points"
		href="./all_sqds.php?key=totalpoints&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Points</b></a></td>
    <td class="ltr70c"><a title="Sort by total missions"
		href="./all_sqds.php?key=totalmis&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Missions</b></a></td>
    <td class="ltr70c"><a title="Sort by total Air kills"
		href="./all_sqds.php?key=totalakill&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>AirK</b></a></td>
    <td class="ltr70c"><a title="Sort by total Ground kills"
		href="./all_sqds.php?key=totalgkill&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>GndK</b></a></td>
    <td class="ltr70c"><a title="Sort by total Kia +Mia"
		href="./all_sqds.php?key=totalkiamia&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Kia+Mia</b></a></td>
    <td class="ltr70c"><a title="Sort by Air kills per mission"
		href="./all_sqds.php?key=ak_x_mis&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Akill/Mis</b></a></td>
    <td class="ltr70c"><a title="Sort by Ground kills per mission"
		href="./all_sqds.php?key=gk_x_mis&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Gkill/Mis</b></a></td>
    <td class="ltr70c"><a title="Sort by points per mission. Total kills in case never kia/mia" 
		href="./all_sqds.php?key=points_x_mis&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Points/Mis</b></a></td>
    <td class="ltr70c"><a title="Sort by Kia+Mia / Mis" 
		href="./all_sqds.php?key=kia_x_mis&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Kia+Mia/Mis</b></a></td>
  </tr>

<?php


    $query="select sqdname8,totalpilot,totalpoints,totalmis,totalakill,totalgkill,totalkiamia,ak_x_mis,gk_x_mis,points_x_mis,kia_x_mis, sqd_army from badc_sqd_file where sqdname8 <> \"NONE\" $minmis_cmd $army_cmd order by $key $order limit $offset,20";
    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());


    $tdo="<td class=\"ltr70c\">";
    $tdor="<td class=\"ltr70c\" align=\"right\">";
    $tdoc="<td class=\"ltr70c\" align=\"center\">";
    $tdol="<td class=\"ltr70c\" align=\"left\">";

    while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
	$i++;

	if ($i%2) { printf("\n <tr>\n");}
		else { printf("\n <tr class=odd>\n");}	


	$sqdname8=$row[0];
	$sqdname8=preg_replace("/</","&lt;",$sqdname8);
	$sqdname8=preg_replace("/>/","&gt;",$sqdname8);	
	$row[0]=preg_replace("/\+/","%2B",$row[0]);	


	printf("$tdoc %d</td>\n",($i+$offset));

	if ($row[11] == 0) {
		printf("$tdoc &nbsp; </td>\n");
	}
	if ($row[11] == 1) {
		printf("$tdoc <img src='images/urss.gif' alt=''></td>\n");
	}
	if ($row[11] == 2) {
		if ($allow_images) {
			printf ("$tdoc <img src='images/germ_ok.gif' alt=''></td>\n");
		}
		else {
			printf ("$tdoc <img src='images/germ.gif' alt=''></td>\n");
		}

	}
	

	printf("
$tdo <a href=\"./sqd_file.php?sqd=%s\">%s</a></td>\n
$tdoc %s </td>\n
$tdoc %s </td>\n
$tdoc %s </td>\n
$tdoc %s </td>\n
$tdoc %s </td>\n
$tdoc %s </td>\n
$tdoc %.2f </td>\n
$tdoc %.2f </td>\n
$tdoc %.2f </td>\n
$tdoc %.2f </td>\n
",
$row[0], $sqdname8,
$row[1],
$row[2],
$row[3],
$row[4],
$row[5],
$row[6],
$row[7],
$row[8],
$row[9],
$row[10]
);

    }

   print "</table>\n";

   $text_order="desc"; // default order
   if ($order == "ASC") {$text_order="asc";}
   print "<font size=\"-2\">";
   print " &nbsp;&nbsp;&nbsp; Order by <b>$key</b>, <b>$text_order</b>. &nbsp;&nbsp;&nbsp;\n";
   print " <font color=\"#cc0000\"> Displaying only pilots with at least <font size=\"+1\"><b>$minmis</b></font> missions.</font>\n";
   print "</font>\n";

?> 

<br><br>
<div id="final">


<?php 
include ("./dz_page_footer.php");
?>