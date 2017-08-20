<?php 
include ("./block.php");
include ("./config.php");
?>


<?php

	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");


	$query2="select sum(blue_points), sum(red_points) from badc_mis_prog  where campanya=\"$campanya\" and mapa=\"$mapa\" and reported='1'";
	$result2 = mysql_query($query2) or die ("Error - Query: $query" . mysql_error());
	$row2 = mysql_fetch_array($result2, MYSQL_NUM);
	if ($row2[0] > 0) {$blue_points = $row2[0];}
	else $blue_points = 0;
	if ($row2[1] > 0) {$red_points = $row2[1];}
	else $red_points = 0;

	print "<table id=missions_icon class=rndtable>\n";
	print "<tr class=first><td colspan=8 align=center><h3>Puntuación de la Campaña</h3></td></tr>\n";	
	print "<tr class=first><td  align=center valign=middle><nowrap><img src=\"images/luftwaffe_logo.gif\" width=40 height=40/></td>";
	print "<td>&nbsp;&nbsp;</td><td><span class=section_header_txt>$blue_points</span></nowrap></td>";
	print "<td>&nbsp;&nbsp;</td><td  align=center valign=middle><img src=\"images/ws_logo.gif\" border=0 width=40 height=40/></td>";
	print "<td>&nbsp;&nbsp;</td><td><span class=section_header_txt>$red_points</span></nowrap></td>";	
	print "</tr>";
	print "</table>\n";	


	$query="select *  from badc_mis_prog where reported='1' and campanya=\"$campanya\" and mapa=\"$mapa\" order by misrep DESC limit 10";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());


print "<table id=last_missions class=modal_last_missions>\n";
print "<tr><td colspan=5 align=center><h3>Ultimas Misiones</h3></td></tr>\n";	
$tdo="<td class=\"ltr70c\">";
$tdoC="<td class=\"ltr70c\" align=\"center\">";
$tdoR="<td class=\"ltr70c\" bgcolor =\"#ffcccc\">";
$tdoB="<td class=\"ltr70c\" bgcolor =\"#ccccff\" >";
$tdk="</td>\n";

print "  <tr bgcolor=\"#ccccc0\">\n $tdo$tdk $tdoR VVS objetive $tdk $tdoR Points $tdk $tdoB LW objetive $tdk $tdoB Points $tdk</tr>\n";

$i=0;
$now_epoch=date("U");
$mis_time_display=10;
while ($row = mysql_fetch_array($result, MYSQL_NUM)) {

	$misnum=$row[2];
	$host=$row[3];

	$host=preg_replace("/</","&lt;",$host);
	$host=preg_replace("/>/","&gt;",$host);

	$red_tgt=$row[4];
	$blue_tgt=$row[5];
	$red_host=$row[6];
	$blue_host=$row[7];
	$reported=$row[8];
	$mis_rep=$row[9];
	$date=$row[10];
	$time=$row[11];
	$epoca=$row[12];
	$red_result=$row[13];
	$blue_result=$row[14];
	$coments=$row[15];
	$red_points=$row[16];
	$blue_points=$row[17];
	$side_won=$row[18];
	$human_req=$row[19];

	$secs= ($now_epoch - $epoca);
	$mins= $secs/60;
	if ($mins < $mis_time_display) {
	    $red_tgt="?????";
	    $blue_tgt="?????";
        }

	$i++;
	if ($i%2) { print "  <tr class=odd>\n";}
	else { print "  <tr>\n";}
	
	if ($side_won ==0){ $side_won="-";}
	if ($side_won ==1){ $side_won="<img src=\"images/urss.gif\" alt=\"\">";}
	if ($side_won ==2){ $side_won="<img src=\"images/germ_ok.gif\" alt=\"\">";}

	if ($red_result && $red_result != "capture" && $red_result != "fail" ) {$red_result .= "%";}
	if ($blue_result && $blue_result != "capture" && $blue_result != "fail" ) {$blue_result .= "%";}

	printf(" $tdoC <a href=\"$RELATIVE_DYNAMIC_REP/%s.html\">%s</a> $tdk $tdo %s [%s] $tdk $tdoC %s $tdk $tdo %s [%s] $tdk $tdoC %s $tdk", $row[9], $side_won, $red_tgt, $red_result, $red_points,  $blue_tgt, $blue_result, $blue_points );
       
} 
print "</table>\n";

?> 