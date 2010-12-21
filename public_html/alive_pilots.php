<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<?php

    $allow_images = $HTTP_COOKIE_VARS["badc_images"];

    $minmis=1; // default minmis
    $minmis_cmd=""; // default minmis_cmd
    $army=0;       // default army 0 = all
    $army_cmd="";   // def army_cmd

    if($HTTP_GET_VARS['minmis']) { $minmis=$HTTP_GET_VARS['minmis']; }
    if ($minmis<1) {$minmis=1;}
    if ($minmis){$minmis_cmd="and mis_steak >= $minmis";}

    if($HTTP_GET_VARS['army']) { $army=$HTTP_GET_VARS['army']; }
    if ($army<0 || $army>2) {$army=0;}
    if ($army){$army_cmd="and sqd_army = $army";}  //&amp;army=$army
	
    $key="mis_steak"; // default key
    if($HTTP_GET_VARS['key']) { $key=$HTTP_GET_VARS['key']; }
    if ( $key != "missions"  && $key != "akills"    && $key != "gkills" && 
         $key != "friend_ak" && $key != "friend_gk" && $key != "chutes" && $key != "pnt_steak" &&
         $key != "smoke"     && $key != "lights"    && $key != "hlname" && $key != "experience" &&
         $key != "kia_mia"   && $key != "ak_x_mis"  && $key != "gk_x_mis" && $key != "rescues" &&
         $key != "ak_x_kia"  && $key != "gk_x_kia"  && $key != "mis_steak" && $key != "a_steak" && $key != "g_steak" ) 
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


   
    $rev_order="ASC"; // default rev order
    if ($order == "ASC") {$rev_order="DESC";}
    print "<a href=\"alive_pilots.php?key=$key&amp;order=$rev_order&amp;minmis=$minmis&amp;army=$army&amp;offset=$offset\">Invert order</a>\n";
    print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";


   print "&nbsp; Min mis: [&nbsp;\n";
   print "<a href=\"alive_pilots.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=".($minmis-10)."&amp;offset=$offset\">-10</a>\n";
   print "&nbsp;&nbsp;<a href=\"alive_pilots.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=0&amp;offset=$offset\">clear</a>&nbsp;&nbsp;\n";
   print "<a href=\"alive_pilots.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=".($minmis+10)."&amp;offset=$offset\">+10</a>\n";
   print "&nbsp;]\n";

   print "&nbsp; Army: [&nbsp;\n";
   print "<a href=\"alive_pilots.php?key=$key&amp;order=$order&amp;army=0&amp;minmis=$minmis&amp;offset=$offset\">All</a>\n";
   print "<a href=\"alive_pilots.php?key=$key&amp;order=$order&amp;army=1&amp;minmis=$minmis&amp;offset=$offset\">Rus</a>\n";
   print "<a href=\"alive_pilots.php?key=$key&amp;order=$order&amp;army=2&amp;minmis=$minmis&amp;offset=$offset\">Ger</a>\n";
   print "&nbsp;]\n";

   print "<br>\n";

    mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
    mysql_select_db("$database");
    
    $query="select count(*) from badc_pilot_file where sqd_accepted='1' and mis_steak >'0' $minmis_cmd $army_cmd";
    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
    $row = mysql_fetch_array($result, MYSQL_NUM);

    $pg= ($row[0] / 20);
    
    print "<font size=\"-1\">\n";
    for ($k=0; $k<$pg ; $k++) {
	if ($k %10 ==0) { print "<br>";}
	if ( ($offset /20) != $k ) {
    		print "<a href=\"alive_pilots.php?key=$key&amp;order=$order&amp;army=$army&amp;minmis=".($minmis)."&amp;offset=".($k*20)."\">";
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


 <table class=rndtable>
  <tr class=first>
    <td class="ltr70c">Nr</td> 
    <td class="ltr70c">Army</td> 
    <td class="ltr70c"><a title="Sort by alphabetic Pilot name"
		href="alive_pilots.php?key=hlname&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Pilot</b></a></td>
    <td class="ltr70c"><a title="Sort by missions streak"
		href="alive_pilots.php?key=mis_steak&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Missions alive</b></a></td>

    <td class="ltr70c"><a title="Sort by total Air kills"
		href="alive_pilots.php?key=a_steak&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Air Kills</b></a></td>

    <td class="ltr70c"><a title="Sort by total Ground kills"
		href="alive_pilots.php?key=g_steak&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Ground kills</b></a></td>

    <td class="ltr70c"><b>Akill/Mis</b></td>

    <td class="ltr70c"><b>Gkill/Mis</b></td>

    <td class="ltr70c"><a title="Sort by pilot experience"
		href="alive_pilots.php?key=experience&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"><b>Experience</b></a></td>
    <td class="ltr70c"><a title="Sort by point steak"
		href="alive_pilots.php?key=pnt_steak&amp;offset=0&amp;order=
		<?php print "$order&amp;army=$army&amp;minmis=$minmis";?>"<b>Points</b></a></td>

  </tr>

<?php

    $query="select hlname,mis_steak,a_steak,g_steak,experience,pnt_steak,sqd_army from badc_pilot_file where sqd_accepted='1' and mis_steak >'0' $minmis_cmd $army_cmd order by $key $order limit $offset,20";
    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());


    $tdo="<td class=\"ltr70c\">";
    $tdor="<td class=\"ltr70c\" align=\"right\">";
    $tdoc="<td class=\"ltr70c\" align=\"center\">";
    $tdol="<td class=\"ltr70c\" align=\"left\">";

    while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
	$i++;

	if ($i%2) { printf("\n <tr>\n");}
		else { printf("\n <tr class=odd>\n");}	


	$html_hlname=$row[0];
	$html_hlname=preg_replace("/</","&lt;",$html_hlname);
	$html_hlname=preg_replace("/>/","&gt;",$html_hlname);	
	$row[0]=preg_replace("/\+/","%2B",$row[0]);	

	printf("$tdo %d</td>\n",($i+$offset));

	if ($row[6] == 0) {
		printf("$tdoc &nbsp; </td>\n");
	}
	if ($row[6] == 1) {
		printf("$tdoc <img src='images/urss.gif' alt=''></td>\n");
	}
	if ($row[6] == 2) {
		if ($allow_images) {
			printf ("$tdoc <img src='images/germ_ok.gif' alt=''></td>\n");
		}
		else {
			printf ("$tdoc <img src='images/germ.gif' alt=''></td>\n");
		}

	}
	
	printf("$tdo <a href=\"pilot.php?hlname=%s\">%s</a></td>\n$tdoc %s </td>\n$tdoc %s </td>\n$tdoc %s </td>\n",$row[0],$html_hlname,$row[1],$row[2],$row[3]);


	printf("$tdoc %.2f </td>\n$tdoc %.2f </td>\n",$row[2]/$row[1],$row[3]/$row[1]);

	printf("$tdoc %s </td>\n$tdoc %s </td>\n",$row[4],$row[5]);

    }

   print "</table>\n";

   $text_order="desc"; // default order
   if ($order == "ASC") {$text_order="asc";}
   print "<font size=\"-2\">";
   print " &nbsp;&nbsp;&nbsp; Order by <b>$key</b>, <b>$text_order</b>. &nbsp;&nbsp;&nbsp;\n";
   print " <font color=\"#cc0000\"> Displaying only pilots with at least <font size=\"+1\"><b>$minmis</b></font> missions.</font>\n";
   print "<br>Akills per mission  and GKills per mission represent current virtual life numbers.";
   print "</font>\n";
   
?> 

<br><br>
<div id="final">


<?php 
include ("./dz_page_footer.php");
?>