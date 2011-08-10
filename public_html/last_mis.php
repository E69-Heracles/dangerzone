<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>


<?php

// parametros de date :
//d Day of the month, 2 digits with leading zeros 
//m Numeric representation of a month, with leading zeros 
//Y A full numeric representation of a year, 4 digits 

$today_d=date("j");
$today_m=date("n");
$today_y=date("Y");

$y = $today_y;  // y por defecto
$m = $today_m;  // m por defecto
$d = $today_d ; // d por defecto

if($HTTP_GET_VARS['d']) { $d=$HTTP_GET_VARS['d']; }	
if($HTTP_GET_VARS['m']) { $m=$HTTP_GET_VARS['m']; }	
if($HTTP_GET_VARS['y']) { $y=$HTTP_GET_VARS['y']; }	

print "<center><font size=\"+1\" color=\"red\">\n";
if ($y <1970) { print "Year must be >= 1970\n"; exit;}
if ($y >2038) { print "Year must be < 2038\n"; exit;}
if ($m >12) { print "invalid month\n"; exit;}
if ($d >31) { print "invalid day\n"; exit;}
if ( $d==31 && ($m == 4 || $m == 6 || $m == 9 || $m == 11 )) { print "invalid day\n"; exit;}
if ( $d>29 && $m == 2) { print "invalid day\n"; exit;}
if ( $d>28 && $m == 2 && ($y%4) ) { print "invalid day\n"; exit;}
print "</font></center>\n";

$next_y=$y;
$next_m=$m;
$next_d=$d + 1;
if ($next_d == 32) {$next_d =1; $next_m+=1;}
if ($next_d == 31) { 
    if ( $next_m == 4 || $next_m == 6 || $next_m == 9 || $next_m == 11 ) {
	$next_d =1; 
	$next_m+=1;
    }
}
if ($next_d == 30 && $m ==2) { 
	$next_d =1; 
	$next_m+=1;
}
if ($next_d == 29 && $m == 2 && ($y % 4) ) { 
	$next_d =1; 
	$next_m+=1;
}

if ($next_m == 13) {$next_m =1; $next_y+=1;}

$prev_y=$y;
$prev_m=$m;
$prev_d=$d -1;
if ($prev_d == 0) {
    $prev_m-=1;
    if ( $prev_m == 2) {
	 if ( $y%4) { $prev_d =28; }
	 else { $prev_d =29; }
    }
    else if ($prev_m == 4 || $prev_m == 6 || $prev_m == 9 || $prev_m == 11 ) {
    	$prev_d =30;
    }
    else {$prev_d =31;}
}
if ($prev_m == 0) {
    $prev_m=12;
    $prev_y-=1;
}


    $dia = $y . "-" . $m . "-" . $d ; // next dia

	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");

	$query="select *  from badc_mis_prog where date='$dia' and reported='1' and campanya=\"$campanya\" and mapa=\"$mapa\" order by misrep ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());



print "<br>\n";
print "<center>\n";

print "<a href=\"last_mis.php?y=$prev_y&amp;m=$prev_m&amp;d=$prev_d\">Prev</a>\n";
print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
print "<a href=\"last_mis.php\">Today</a>\n";
print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
print "<a href=\"last_mis.php?y=$next_y&amp;m=$next_m&amp;d=$next_d\">Next</a>\n";
print "<br>\n";
print "<br><br>\n";

print "<h3>Date $dia Missions</h3>\n";
print "</center>\n";



print "<center>\n";

if ($y == 2004 && ( $m < 7 || ($m==7 && $d<17) )  ) {
	print "For older missions: please check ";
	print "<a href=\"all_last_mis.php\">this page</a>";
	print "</center><br><br></div></body></html>\n";
	exit;
}

print "<table  class=rndtable>\n";

if ($y == 2004 && ( $m < 8 || ($m==8 && $d<31) )  ) {

$tdo="<td class=\"ltr70c\">&nbsp;";
$tdk="&nbsp;</td>\n";

print "  <tr bgcolor=\"#ccccc0\">\n $tdo Nr. $tdk  $tdo Mission $tdk  $tdo Date $tdk  $tdo Time $tdk  $tdo Host $tdk  $tdo VVS attack $tdk  $tdo LW attack $tdk  $tdo Status $tdk  </tr>\n";

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

	$secs= ($now_epoch - $epoca);
	$mins= $secs/60;
	if ($mins < $mis_time_display) {
	    $red_tgt="?????";
	    $blue_tgt="?????";
        }

	$i++;
	if ($i%2) { print "  <tr bgcolor=\"#dddddd\">\n";}
	else { print "  <tr bgcolor=\"#cbcbcb\">\n";}

	printf("    $tdo %d $tdk    $tdo %s $tdk    $tdo %s $tdk    $tdo %s $tdk     $tdo %s $tdk    $tdo %s $tdk    $tdo %s $tdk", $i, $row[2], $row[10], $row[11], $host, $red_tgt, $blue_tgt);

	if ($row[8] == 1) {  // is reported
	    printf("    $tdo  <a href=\"/rep/%s.html\">%s.html</a>$tdk  </tr>\n", $row[9], $row[9]);
	}
	else {
	    printf  ("    %s &nbsp;In progress: %.2d Minutes $tdk  </tr>\n",$tdo,$mins);
	}
       
}

}
else { 

$tdo="<td class=\"ltr70c\">&nbsp;";
$tdoC="<td class=\"ltr70c\" align=\"center\">&nbsp;";
$tdoR="<td class=\"ltr70c\" bgcolor =\"#ffcccc\">&nbsp;";
$tdoB="<td class=\"ltr70c\" bgcolor =\"#ccccff\" >&nbsp;";
$tdk="&nbsp;</td>\n";

print "  <tr bgcolor=\"#ccccc0\">\n $tdo Nr. $tdk  $tdo Mission $tdk $tdo Host $tdk  $tdo Won $tdk $tdoR VVS objetive $tdk $tdoR Result $tdk $tdoR Points $tdk $tdoB LW objetive $tdk $tdoB Result $tdk $tdoB Points $tdk $tdo Notes $tdk $tdo Report $tdk </tr>\n";

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

	if ($red_result && $red_result != "capture" && $red_result != "fail" ) {$red_result .= " %";}
	if ($blue_result && $blue_result != "capture" && $blue_result != "fail" ) {$blue_result .= " %";}


	if ($coments == "") {$coments="0";}
	if ($coments == "0") {
		$coments="<a title=\" $coments notes\" href=\"/rep/" . $mis_rep . ".html#reports\"><img border=\"0\" src=\"images/coments_0.gif\" alt=\"\"></a>"; }
	else {

		if ($coments =="1" || $coments =="2" ) {	
			$coments="<a title=\"$coments notes\" href=\"/rep/" . $mis_rep . ".html#reports\"><img border=\"0\" src=\"images/coments_1.gif\" alt=\"$coments notes\"></a>";
}		else {	
			$coments="<a title=\"$coments notes\" href=\"/rep/" . $mis_rep . ".html#reports\"><img border=\"0\" src=\"images/coments_3.gif\" alt=\"$coments notes\"></a>";
		}
	}


	printf("    $tdo %d $tdk  $tdo %s $tdk $tdo %s $tdk $tdoC %s $tdk $tdo %s $tdk $tdoC %s $tdk $tdoC %s $tdk $tdo %s $tdk $tdoC %s $tdk $tdoC %s $tdk $tdoC %s $tdk ", $i, $misnum, $host, $side_won, $red_tgt, $red_result, $red_points,  $blue_tgt, $blue_result, $blue_points, $coments);

	if ($row[8] == 1) {  // is reported
	    printf("    $tdo  <a href=\"/rep/%s.html\">%s.html</a>$tdk  </tr>\n", $row[9], $row[9]);
	}
	else {
	    printf  ("    %s &nbsp;In progress: %.2d Minutes $tdk  </tr>\n",$tdo,$mins);
	}
       
} 

}


print "</table>\n";
print "</center>\n";
?> 

<?php 
include ("./dz_page_footer.php");
?>