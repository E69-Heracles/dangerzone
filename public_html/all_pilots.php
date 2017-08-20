<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<?php

    $allow_images = $_COOKIE["badc_images"];

    $minmis=1; // default minmis
    $minmis_cmd=""; // default minmis_cmd
    $army=0;       // default army 0 = all
    $army_cmd="";   // def army_cmd

    if($_GET['minmis']) { $minmis=$_GET['minmis']; }
    if ($minmis<0) {$minmis=0;}
    if ($minmis){$minmis_cmd="and missions >= $minmis";}

    if($_GET['army']) { $army=$_GET['army']; }
    if ($army<0 || $army>2) {$army=0;}
    if ($army){$army_cmd="and sqd_army = $army";}  //&amp;army=$army

    $key="points"; // default key
    if($_GET['key']) { $key=$_GET['key']; }
    if ( $key != "missions"  && $key != "akills"    && $key != "gkills" && 
         $key != "friend_ak" && $key != "friend_gk" && $key != "chutes" &&
         $key != "smoke"     && $key != "lights"    && $key != "hlname" && $key != "points" &&
         $key != "kia_mia"   && $key != "ak_x_mis"  && $key != "gk_x_mis" && $key != "rescues" &&
         $key != "ak_x_kia"  && $key != "gk_x_kia"  && $key != "rank"     && $key != "pnt_steak_max" && 
         $key != "mis_steak_max" && $key != "a_steak_max" && $key != "g_steak_max") 
	{print "Error: Unknow key: $key"; die;}

    $offset=0; // default offset
    if($_GET['offset']) { $offset=$_GET['offset']; }
    if (preg_match("/[^-0-9]/",$offset)){print "Error: Unknow offset: $offset"; die;}
    if ($offset<0) {$offset=0;}
 
    $order="DESC"; // defalut order
    if($_GET['order']) {$order=$_GET['order'];}
    if ( $order != "ASC" && $order != "DESC") {print "Error: Unknow order: $order"; die;}

    print "<br>\n";
    print "<center>\n";

   print "<FORM METHOD=\"GET\" ACTION=\"pilot.php\">\n<b> Search Name:</b> \n";
   print "<input type=\"text\" size=\"16\" name=\"hlname\" value=\"$hlname\">\n<input TYPE=\"SUBMIT\" VALUE=\"Find\">\n</form>\n";


   
    $rev_order="ASC"; // default rev order
    if ($order == "ASC") {$rev_order="DESC";}
    print "<a href=\"./all_pilots.php?key=$key&amp;order=$rev_order&amp;minmis=$minmis&amp;army=$army&amp;offset=$offset\">Invert order</a>\n";
    print "&nbsp;&nbsp;\n";


   print "&nbsp; Min mis: [&nbsp;\n";
   print "<a href=\"./all_pilots.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=".($minmis-10)."&amp;offset=$offset\">-10</a>\n";
   print "&nbsp;&nbsp;<a href=\"./all_pilots.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=1&amp;offset=$offset\">clear</a>&nbsp;&nbsp;\n";
   print "<a href=\"./all_pilots.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=".($minmis+10)."&amp;offset=$offset\">+10</a>\n";
   print "&nbsp;]\n";

   print "&nbsp; Army: [&nbsp;\n";
   print "<a href=\"./all_pilots.php?key=$key&amp;order=$order&amp;army=0&amp;minmis=$minmis&amp;offset=$offset\">All</a>\n";
   print "<a href=\"./all_pilots.php?key=$key&amp;order=$order&amp;army=1&amp;minmis=$minmis&amp;offset=$offset\">Rus</a>\n";
   print "<a href=\"./all_pilots.php?key=$key&amp;order=$order&amp;army=2&amp;minmis=$minmis&amp;offset=$offset\">Ger</a>\n";
   print "&nbsp;]\n";


   print "<br>\n";

    mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
    mysql_select_db("$database");

    $query="select count(*) from badc_pilot_file where sqd_accepted='1' $minmis_cmd $army_cmd";
    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
    $row = mysql_fetch_array($result, MYSQL_NUM);

    $pg= ($row[0] / 20);
    
    print "<font size=\"-1\">\n";
    for ($k=0; $k<$pg ; $k++) {
	if ($k %20 ==0) { print "<br>";}
	if ( ($offset /20) != $k ) {
    		print "<a href=\"./all_pilots.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=".($minmis)."&amp;offset=".($k*20)."\">";
		if ($k<9) { print "0";}
		if ($k<99) { print "0";}
		print ($k+1)."</a>&nbsp;\n";
	}
	else {
		print "<b>[</b>";
		if ($k<9) { print "0";}
		if ($k<99) { print "0";}
		print ($k+1)."<b>]</b>\n";
	}

    }
    print "</font>\n";
   print "<br>\n</center>\n";



?>


<center>



 <table class=rndtable><tr class=first>
    <td class="ltr70c">Nr</td> 
    <td class="ltr70c">Army</td> 
    <td class="ltr70c"><a title="Sort by alphabetic Pilot name"
		href="./all_pilots.php?key=hlname&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Pilot</b></a></td>
    <td class="ltr70c"><a title="Sort by points"
		href="./all_pilots.php?key=points&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Points</b></a></td>
    <td class="ltr70c"><a title="Sort by total missions"
		href="./all_pilots.php?key=missions&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Missions</b></a></td>
    <td class="ltr70c"><a title="Sort by total Rescues"
		href="./all_pilots.php?key=rescues&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Resc</b></a></td>
    <td class="ltr70c"><a title="Sort by total Kia +Mia"
		href="./all_pilots.php?key=kia_mia&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Kia+Mia</b></a></td>
    <td class="ltr70c"><a title="Sort by total Air kills"
		href="./all_pilots.php?key=akills&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>AirK</b></a></td>
    <td class="ltr70c"><a title="Sort by total Ground kills"
		href="./all_pilots.php?key=gkills&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>GndK</b></a></td>
    <td class="ltr70c"><a title="Sort by Air kills per mission"
		href="./all_pilots.php?key=ak_x_mis&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Akill/Mis</b></a></td>
    <td class="ltr70c"><a title="Sort by Ground kills per mission"
		href="./all_pilots.php?key=gk_x_mis&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Gkill/Mis</b></a></td>
    <td class="ltr70c"><a title="Sort by airkills per kia. Total kills in case never kia/mia" 
		href="./all_pilots.php?key=ak_x_kia&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Akill/Kia</b></a></td>
    <td class="ltr70c"><a title="Sort by ground kills per kia. Total kills in case never kia/mia" 
		href="./all_pilots.php?key=gk_x_kia&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Gkill/Kia</b></a></td>
    <td class="ltr70c"><a title="Sort by MAX mission streak." 
		href="./all_pilots.php?key=mis_steak_max&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>MMS</b></a></td>
    <td class="ltr70c"><a title="Sort by MAX Airkils streak." 
		href="./all_pilots.php?key=a_steak_max&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>MAS</b></a></td>
    <td class="ltr70c"><a title="Sort by MAX gorund kill streak" 
		href="./all_pilots.php?key=g_steak_max&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>MGS</b></a></td>
    <td class="ltr70c" align="center"><a title="Sort by Rank" 
		href="./all_pilots.php?key=rank&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Rank</b></a></td>
  </tr>

<?php


    $query="select hlname,missions,kia_mia,akills,gkills,ak_x_mis,gk_x_mis,ak_x_kia,gk_x_kia,friend_ak,friend_gk,chutes,smoke,lights,rescues,sqd_army,points,rank,mis_steak_max,a_steak_max,g_steak_max from badc_pilot_file where sqd_accepted='1' $minmis_cmd $army_cmd order by $key $order limit $offset,20";
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


	printf("$tdo %d</td>\n",($i+$offset));

	if ($row[15] == 0) {
		printf("$tdoc &nbsp; </td>\n");
	}
	if ($row[15] == 1) {
		printf("$tdoc <img src='images/urss.gif' alt=''></td>\n");
	}
	if ($row[15] == 2) {
		if ($allow_images) {
			printf("$tdoc <img src='images/germ_ok.gif' alt=''></td>\n");
		}
		else {
			printf("$tdoc <img src='images/germ.gif' alt=''></td>\n");
		}
	}
	

	printf("$tdo <a href=\"./pilot.php?hlname=%s\">%s</a></td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %.2f </td>\n$tdoc %.2f</td>",$row[0],$html_hlname,$row[16],$row[1],$row[14],$row[2],$row[3],$row[4],$row[5],$row[6]);

	printf("$tdoc %.2f </td>\n$tdoc %.2f </td>\n",$row[7],$row[8]);

	printf("$tdoc %d </td>\n$tdoc %d </td>\n$tdoc %d </td>\n",$row[18],$row[19],$row[20]);

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

<br><br>
<div id="final">


  
<?php 
include ("./dz_page_footer.php");
?>
