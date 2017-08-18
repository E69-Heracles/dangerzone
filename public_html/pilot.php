<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>


<?php

//	exit;  

  	$hlname=$_GET['hlname'];

	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");

	$query="select count(*) from badc_pilot_file where  hlname='$hlname' ";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
	$row = mysql_fetch_array($result, MYSQL_NUM);
	
	if (! $row[0]){

		$html_hlname=$hlname;
		$html_hlname=preg_replace("/</","&lt;",$html_hlname);
		$html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	        print "<br><br><center>";
		print "<FORM METHOD=\"GET\" ACTION=\"pilot.php\">\n<b>Search Name:</b> \n";
		print "<input type=\"text\" size=\"16\" name=\"hlname\" value=\"$hlname\">\n<input TYPE=\"SUBMIT\" VALUE=\"Buscar\">\n</form>\n";

		if( ! ($hlname == "") ){

			$hlname="%$hlname%";

			$query="select count(*) from badc_pilot_file where  hlname LIKE '$hlname'";
			$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
			$row = mysql_fetch_array($result, MYSQL_NUM);
			
			print "<br>Found $row[0] names matching: &nbsp;&nbsp;<i> $html_hlname </i> <br>\n";

			if($row[0]){
	                        print "<h3>Pilots correct registered</h3>";
				$pcount=$row[0];
				$i=0;
				$query="select hlname from badc_pilot_file where  hlname LIKE '$hlname' and sqd_accepted='1' and banned='0'";
				$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
		
				print "<br><table >\n";
				while ($row = mysql_fetch_array($result, MYSQL_NUM)) {	
					$i++;
					$html_hlname=$row[0];
					$html_hlname=preg_replace("/</","&lt;",$html_hlname);
					$html_hlname=preg_replace("/>/","&gt;",$html_hlname);
					$row[0]=preg_replace("/\+/","%2B",$row[0]);	
					printf("<tr><td>%d - </td><td><a href=\"pilot.php?hlname=%s\"><b>%s</b></a></td></tr>\n",$i,$row[0],$html_hlname);
				}
				print "</table>\n";
				if ($pcount>$i) {
	                        print "<h3>Pilots with incomplete registration</h3>";
			      $query="select hlname from badc_pilot_file where hlname LIKE '$hlname' and sqd_accepted='0' and banned='0'";
			      $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
				print "<table >\n";
				while ($row = mysql_fetch_array($result, MYSQL_NUM)) {	
			 		$i++;
					$html_hlname=$row[0];
					$html_hlname=preg_replace("/</","&lt;",$html_hlname);
					$html_hlname=preg_replace("/>/","&gt;",$html_hlname);
					$row[0]=preg_replace("/\+/","%2B",$row[0]);	
					printf("<tr><td>%d - </td><td><a href=\"pilot.php?hlname=%s\"><b>%s</b></a></td></tr>\n",$i,$row[0],$html_hlname);
				}
				print "</table>\n";
                              }
				if ($pcount>$i) {
	                        print "<h3>Banned Pilots</h3>";
			      $query="select hlname from badc_pilot_file where hlname LIKE '$hlname' and  banned='1'";
			      $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());	
				print "<table >\n";
				while ($row = mysql_fetch_array($result, MYSQL_NUM)) {	
			 		$i++;
					$html_hlname=$row[0];
					$html_hlname=preg_replace("/</","&lt;",$html_hlname);
					$html_hlname=preg_replace("/>/","&gt;",$html_hlname);
					$row[0]=preg_replace("/\+/","%2B",$row[0]);	
					printf("<tr><td>%d - </td><td><a href=\"pilot.php?hlname=%s\"><b>%s</b></a></td></tr>\n",$i,$row[0],$html_hlname);
				}
				print "</table>\n";
                              }
			}
		}

		print "<br><br><br>\n</center></div></body></html>";
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

	$query="select avatar,email,in_sqd_name,sqd_accepted,sqd_army,banned from badc_pilot_file where hlname='$hlname'";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);



	print "<br/><br/><center>\n";
	print "<table  border=\"0\">\n";

	print "<tr><td align=\"center\">\n";		

	$row[0]=preg_replace("/http:\/\//","",$row[0]); // remove http://
	if ($row[0] && $row[0] != "images/avatar.gif" ) {
		print "    <img src=\"http://$row[0]\" alt=\"imagen\">";
	}
	else {
		print "    &nbsp;";	
	}

print "</td><td width=50px></td><td>\n";		

	print "  <table class=rndtable_nohover>\n";
   	print "    <tr><td><b>$html_hlname</b></td>\n";
	print "       <td> <a href=\"mailto: $row[1]\"><img border=\"0\" src=\"images/e.gif\" alt=\"email\"></a></td></tr>\n";
   	
	$row[2]=preg_replace("/</","&lt;",$row[2]);
	$row[2]=preg_replace("/>/","&gt;",$row[2]);

    	if ( $row[2] != "NONE" ) {	
		print "     <tr><td><b>Squadron :</b></td><td> <a href=\"sqd_file.php?sqd=$row[2]\"><b>$row[2]</b></a>";
	}
	else {
		print "     <tr><td><b>Squadron :</b></td><td> <b>$row[2]</b>";
	}

	if ( $row[2] != "NONE" && $row[3] =="0" ) {print " (Req.)";}
        print "  </td></tr>\n";
	print "  <tr><td colspan=\"2\"><hr size=\"1\"></td></tr>\n";
	print "  </table>\n";
	print "</td></tr>\n";		

	print "</table>\n";
	print "</center>\n";

	if ( $row[5] == "1") { // pilot is banned
		print "<br><br><center>\n";
		print "<font color=\"red\"><b>Pilot banned.</b></font><br>\n";
		print "This pilot is banned from BW. Host has to not allow this player into games.<br>\n";
		print "</center><br><br><br>\n</div>\n</body>\n</html>";
		exit(0);
	}	

	if ( $row[2] == "NONE" && $hlname !="Mad") {
		print "<br><br><center>\n";
		print "<b> Pilot registered, but not joined a sqadron.</b><br>\n";
		print "After joining a squadron and been accepted, your stats will be aviable.<br>\n";
		print "</center><br><br><br>\n</div>\n</body>\n</html>";
		exit(0);
	}	
	if ($row[3] =="0" ) {
		print "<br><br><center>\n";
		print "<b>Pilot registered, but not yet accepted in  sqadron.</b><br>\n";
		print "After accepted, your stats will be aviable.<br> Ask Sqd CO/XO to accept your aplication.<br>\n";
		print "</center><br><br><br>\n</div>\n</body>\n</html>";
		exit(0);
	}	

        $army=$row[4];

$tanks=0;
if ($army==1) {
    $query="select count(*) from badc_grnd_event where objkilled regexp \".*Pz.*\" and hlkiller = \"$hlname\" and campanya = \"$campanya\" and mapa =\"$mapa\" ";
}
if ($army==2) {
    $query="select count(*) from badc_grnd_event where objkilled regexp \".*T34|.*T70M|.*BT7\" and hlkiller = \"$hlname\" and campanya = \"$campanya\" and mapa =\"$mapa\" ";
}

$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
$row = mysql_fetch_array($result, MYSQL_NUM);    
$tanks=$row[0];

$query="select fired, ahit, ghit, ahitwf, akillswf, akills,gkills, missions, chutes, smoke, lights, ftime, friend_ak, friend_gk, mis_steak, mis_steak_max, a_steak, a_steak_max, g_steak, g_steak_max, rescues, experience, fairplay, killed, captured, landed, disco, rank, medals, ban_hosting, ban_planing, points, pnt_steak, pnt_steak_max, fired, ahit, ghit  from badc_pilot_file WHERE hlname=\"$hlname\"";
  
$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
$row = mysql_fetch_array($result, MYSQL_NUM);    

$fired=$row[0];
$ahit=$row[1];
$ghit=$row[2];
$ahitwf=$row[3];
$akillswf=$row[4];
$akills=$row[5];
$gkills=$row[6];
$missions=$row[7];
$chutes=$row[8];
$smoke=$row[9];
$lights=$row[10];
$ftime=$row[11];
$friend_ak=$row[12];
$friend_gk=$row[13];
$mis_steak=$row[14];
$mis_steak_max=$row[15];
$a_steak=$row[16];
$a_steak_max=$row[17];
$g_steak=$row[18];
$g_steak_max=$row[19];
$rescues=$row[20];
$experience=$row[21];
$fairplay=$row[22];
$killed=$row[23];
$captured=$row[24];
$landed=$row[25];
$disco=$row[26];
$rank=$row[27];
$medals=$row[28];
$ban_hosting=$row[29];
$ban_planing=$row[30];
$points=$row[31];
$pnt_steak=$row[32];
$pnt_steak_max=$row[33];
$fired=$row[34];
$ahit=$row[35];
$ghit=$row[36];
?>

<br><br><br>

<center>

<table class=rndtable_nohover>

<?php 

$tdo="<td class=\"ltr70c\" bgcolor=\"#aacaca\">";
$tdor="<td align=\"right\" class=\"ltr70c\" bgcolor=\"#aacaca\">";
print "
  <tr>
  <td >
	<table  border=0>
	 <tr> <td colspan=\"2\" class=\"ltr70c\" align=\"center\" bgcolor=\"#cccccc\"> <b>Over all</b> </td></tr>
	 <tr> $tdo Total Missions</td> $tdor $missions</td> </tr>
	 <tr> $tdo Total Points</td>   $tdor $points</td> </tr>
	 <tr> $tdo Total Air Kills</td>   $tdor $akills</td> </tr>
	 <tr> $tdo Total Gnd Kills (tanks)</td>   $tdor $gkills ($tanks)</td> </tr>
";
	if ($missions) {
	    printf ("<tr> %s Points/Missions       </td> %s %.2f </td></tr>\n",$tdo,$tdor,($points/$missions));
	    printf ("<tr> %s Air Kills/Missions    </td> %s %.2f </td></tr>\n",$tdo,$tdor,($akills/$missions));
	    printf ("<tr> %s Ground Kills/Missions </td> %s %.2f </td></tr>\n",$tdo,$tdor,($gkills/$missions));
        }
	else {
	    print "
		 <tr> $tdo Points/Missions</td> $tdor -</td> </tr>
		 <tr> $tdo Air Kills/Missions</td>   $tdor -</td> </tr>
		 <tr> $tdo Ground Kills/Missions</td>   $tdor -</td> </tr>
		";
	}

	print " <tr> $tdo Kia + Mia </td>   $tdor ".($killed+$captured)."</td> </tr>";
	if ($killed || $captured) {
	    printf ("<tr> %s Points/V-live       </td> %s %.2f </td></tr>\n",$tdo,$tdor,($points/($killed+$captured)));
	    printf ("<tr> %s Air Kills/V-live    </td> %s %.2f </td></tr>\n",$tdo,$tdor,($akills/($killed+$captured)));
	    printf ("<tr> %s Ground Kills/V-live </td> %s %.2f </td></tr>\n",$tdo,$tdor,($gkills/($killed+$captured)));
	}
	else {
	    print "
	 	<tr> $tdo Points per V-live   </td>   $tdor -</td> </tr>
	 	<tr> $tdo Air Kills/V-live    </td>   $tdor -</td> </tr>
	 	<tr> $tdo Ground Kills/V-live </td>   $tdor -</td> </tr>
		";
	}

	print " <tr> $tdo Ftime</td>  $tdor $ftime Hrs</td> </tr>\n";
if ($army == 1) {
	if ($rank == 0) { print "<tr> $tdo Rank</td> $tdor <b>Krasnoarmeyets</b></td> </tr>\n"; }
	if ($rank == 1) { print "<tr> $tdo Rank</td> $tdor <b>Serzhant</b></td> </tr>\n"; }
	if ($rank == 2) { print "<tr> $tdo Rank</td> $tdor <b>Leytenant</b></td> </tr>\n"; }
	if ($rank == 3) { print "<tr> $tdo Rank</td> $tdor <b>Starshiy Leitenant</b></td> </tr>\n"; }
	if ($rank == 4) { print "<tr> $tdo Rank</td> $tdor <b>Kapitan</b></td> </tr>\n"; }
	if ($rank == 5) { print "<tr> $tdo Rank</td> $tdor <b>Mayor</b></td> </tr>\n"; }
	if ($rank == 6) { print "<tr> $tdo Rank</td> $tdor <b>Podpolkovnik</b></td> </tr>\n"; }
	if ($rank == 7) { print "<tr> $tdo Rank</td> $tdor <b>Polkovnik</b></td> </tr>\n"; }
}
if ($army==2) {
	if ($rank == 0) { print "<tr> $tdo Rank</td> $tdor <b>Flieger</b></td> </tr>\n"; }
	if ($rank == 1) { print "<tr> $tdo Rank</td> $tdor <b>Feldbewel</b></td> </tr>\n"; }
	if ($rank == 2) { print "<tr> $tdo Rank</td> $tdor <b>Leutnant</b></td> </tr>\n"; }
	if ($rank == 3) { print "<tr> $tdo Rank</td> $tdor <b>Oberleutnant</b></td> </tr>\n"; }
	if ($rank == 4) { print "<tr> $tdo Rank</td> $tdor <b>Hauptmann</b></td> </tr>\n"; }
	if ($rank == 5) { print "<tr> $tdo Rank</td> $tdor <b>Major</b></td> </tr>\n"; }
	if ($rank == 6) { print "<tr> $tdo Rank</td> $tdor <b>Oberstleutnant</b></td> </tr>\n"; }
	if ($rank == 7) { print "<tr> $tdo Rank</td> $tdor <b>Oberst</b></td> </tr>\n"; }
}


print "
	</table>	
  </td>
  <td>
	<table  border=0>
	 <tr> <td colspan=\"2\" class=\"ltr70c\" align=\"center\" bgcolor=\"#cccccc\"> <b>Current V-live</b> </td></tr>
";
	$img="";
	if ($mis_steak && $mis_steak==$mis_steak_max){$img="<img src=\"images/arrow_up.gif\" alt=\"\" >";}	
	print " <tr> $tdo Current Missions</td> $tdor $mis_steak $img </td> </tr>";

	$img="";
	if ($pnt_steak && $pnt_steak==$pnt_steak_max){$img="<img src=\"images/arrow_up.gif\" alt=\"\" >";}	
	print "  <tr> $tdo Current Points</td>   $tdor $pnt_steak $img </td> </tr>";

	$img="";
	if ($a_steak && $a_steak==$a_steak_max){$img="<img src=\"images/arrow_up.gif\" alt=\"\" >";}	
	print "  <tr> $tdo Current Air Kills</td>   $tdor $a_steak $img </td> </tr>";

	$img="";
	if ($g_steak && $g_steak==$g_steak_max){$img="<img src=\"images/arrow_up.gif\" alt=\"\" >";}	
	print "  <tr> $tdo Current Ground Kills</td>   $tdor $g_steak $img </td> </tr>";

	if ($mis_steak) {
	    printf ("<tr> %s Points/Missions       </td> %s %.2f </td></tr>\n",$tdo,$tdor,($pnt_steak/$mis_steak));
	    printf ("<tr> %s Air Kills/Missions    </td> %s %.2f </td></tr>\n",$tdo,$tdor,(  $a_steak/$mis_steak));
	    printf ("<tr> %s Ground Kills/Missions </td> %s %.2f </td></tr>\n",$tdo,$tdor,(  $g_steak/$mis_steak));
        }
	else {
	    print "
		 <tr> $tdo Points/Missions      </td>   $tdor -</td> </tr>
		 <tr> $tdo Air Kills/Missions   </td>   $tdor -</td> </tr>
		 <tr> $tdo Ground Kills/Missions</td>   $tdor -</td> </tr>
		";
	}

print "
	 <tr> <td colspan=\"2\" class=\"ltr70c\" align=\"center\" bgcolor=\"#cccccc\"> <b>Other Info</b> </td></tr>
	 <tr> $tdo Fairplay Index </td> $tdor $fairplay</td> </tr>	
	 <tr> $tdo Current Experience</td> $tdor $experience</td> </tr>
";
	 if ($ban_hosting) { print "<tr> $tdo Allow Host</td> $tdor  No</td> </tr>\n"; }
	 else             { print "<tr> $tdo Allow Host</td> $tdor Yes</td> </tr>\n"; }
	 if ($ban_planing) { print "<tr> $tdo Allow Plan</td> $tdor <a title=\"View planning status\"href=\"vote_planning.php?hlname=$hlname\">No</a></td> </tr>\n"; }
	 else             { print "<tr> $tdo Allow Plan</td> $tdor <a title=\"View planning status\"href=\"vote_planning.php?hlname=$hlname\">Yes</a></td> </tr>\n"; }

	$pad="";
	if ($medals<1000){$pad.="0";}
	if ($medals<100) {$pad.="0";}
	if ($medals<10)  {$pad.="0";}
	$medals= $pad.$medals;

print "
	 <tr> $tdo Medals</td> $tdor <a title=\"View pilot medals\" href=\"medals.php?hlname=$hlname\">Show</a></td></tr>

	</table>	
</td>
<td>
	<table  border=0>
	 <tr> <td colspan=\"2\" class=\"ltr70c\" align=\"center\" bgcolor=\"#cccccc\"> <b>Best runs</b> </td> </tr>
	 <tr> $tdo Max Missions</td> $tdor $mis_steak_max 
<font size=\"-3\">[<a title=\"plot all missions\" href=\"/cgi-bin/plot1.pl?hlname=$hlname\">/`v'</a>]&nbsp;&nbsp;[<a title=\"plot last 100 missions\" href=\"/cgi-bin/plot1_L100.pl?hlname=$hlname\">/`v'</a>]</font></td></tr>
	 <tr> $tdo Max Points</td>   $tdor $pnt_steak_max <font size=\"-3\">[<a title=\"plot\" href=\"/cgi-bin/plot4.pl?hlname=$hlname\">/`v'</a>]</font></td></tr>
	 <tr> $tdo Max Air Kills</td>  $tdor $a_steak_max <font size=\"-3\">[<a title=\"plot\" href=\"/cgi-bin/plot2.pl?hlname=$hlname\">/`v'</a>]</font></td></tr>
	 <tr> $tdo Max Ground Kills</td>   $tdor $g_steak_max <font size=\"-3\">[<a title=\"plot\" href=\"/cgi-bin/plot3.pl?hlname=$hlname\">/`v'</a>]</font></td></tr>
	 <tr> <td colspan=\"2\" class=\"ltr70c\" align=\"center\" bgcolor=\"#cccccc\"> <b>Other Numbers</b> </td></tr>
	 <tr> $tdo Friend Air Kills</td>   $tdor $friend_ak</td> </tr>
	 <tr> $tdo Friend Ground Kills</td>   $tdor $friend_gk</td> </tr>
	 <tr> $tdo Chute Kills</td>   $tdor $chutes</td> </tr>
	 <tr> $tdo Smoke Taps</td>   $tdor $smoke</td> </tr>
	 <tr> $tdo Landing Lights</td>   $tdor $lights</td> </tr>
";
	if ($fired){
        	printf ("<tr> %s Avg gun Ahit %%</td> %s %.2f %%</td></tr>\n",$tdo,$tdor,($ahit/$fired*100));
        	printf ("<tr> %s Avg gun Ghit %%</td> %s %.2f %%</td></tr>\n",$tdo,$tdor,($ghit/$fired*100));
	}
	else {
	    	print " <tr> $tdo Avg gun Ahit %</td> $tdor -</td> </tr>\n";
	    	print " <tr> $tdo Avg gun Ghit %</td> $tdor -</td> </tr>\n";
	}
print "
	<tr class=first><td> Total <a title=\"View all\"href=\"show_rescues.php?hlname=$hlname\">Rescues</a></td>   $tdor $rescues</td> </tr>	
	</table>	

</td>
</tr>
</table>
";
?>

</center>

<center>
<br><br>
    <h3> Last Missions</h3>
 <table  class=rndtable>


<?php
    print "<tr class=first><td class=\"ltr70c\">"; 
    if ($order=="ASC"){
	print "<a title=\"invert order\" href=\"pilot.php?hlname=$hlname&amp;order=DESC\">Mission</a>";
	if ($count=="ALL"){
	    print "&nbsp;&nbsp;&nbsp;<a title=\"less\" href=\"pilot.php?hlname=$hlname&amp;order=ASC\"><img src=\"images/less.gif\"  alt=\"\" border=\"0\"></a>&nbsp;&nbsp;";
	}
	else {
	    print "&nbsp;&nbsp;<a title=\"more\" href=\"pilot.php?hlname=$hlname&amp;order=ASC&amp;count=ALL\"><img src=\"images/more.gif\"  alt=\"\" border=\"0\"></a>&nbsp;&nbsp;";}
	}
    else {
	print "<a title=\"invert order\" href=\"pilot.php?hlname=$hlname&amp;order=ASC\">Mission</a>"; 
	if ($count=="ALL"){
	    print "&nbsp;&nbsp;&nbsp;<a title=\"less\" href=\"pilot.php?hlname=$hlname&amp;order=DESC\"><img src=\"images/less.gif\"  alt=\"\" border=\"0\"></a>&nbsp;&nbsp;";
	}
	else {
	    print "&nbsp;&nbsp;<a title=\"more\" href=\"pilot.php?hlname=$hlname&amp;order=DESC&amp;count=ALL\"><img src=\"images/more.gif\"  alt=\"\" border=\"0\"></a>&nbsp;&nbsp;";}
    }
    print "</td>";
?>
    <td class="ltr70c">Plane</td>
    <td class="ltr70c">Task</td>
    <td class="ltr70c">Points</td>
    <td class="ltr70c">F-time</td>
    <td class="ltr70c">A-Kills</td>
    <td class="ltr70c">G-kills</td>
    <td class="ltr70c ">F-AK</td>
    <td class="ltr70c ">F-GK</td>
    <td class="ltr70c ">Chu</td>
    <td class="ltr70c">Smk</td>
    <td class="ltr70c">Lig</td>
    <td class="ltr70c">
        <td class="ltr70c" align="right">Fire</td>
        <td class="ltr70c" align="right">Ahit</td>
        <td class="ltr70c" align="right">Ghit</td>
        <td class="ltr70c" align="center">|</td>
        <td class="ltr70c" align="right"><b>A%</b></td>
        <td class="ltr70c" align="right"><b>G%</b></td>
		
    <td class="ltr70c">State</td>
  </tr>
<?php 

$tdo="<td class=\"ltr70c\">";
$tdor="<td class=\"ltr70c\" align=\"right\">";
$tdoc="<td class=\"ltr70c\" align=\"center\">";
$tdol="<td class=\"ltr70c\" align=\"left\">";
$tdoR="<td class=\"ltr70c\" align=\"right\">";
$tdoC="<td class=\"ltr70c\" align=\"center\">";
$tdoL="<td class=\"ltr70c\" align=\"left\">";
$smtb="\n";

mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
mysql_select_db("$database");


//$hlname=$_POST['hlname'];

$query="select * from badc_pilot_mis where hlname='$hlname' and campanya = \"$campanya\" and mapname =\"$mapa\" order by misrep DESC";
if ($order=="ASC"){
    $query="select * from badc_pilot_mis where hlname='$hlname' and campanya = \"$campanya\" and mapname =\"$mapa\" order by misrep ASC";
}

$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

$i=0; // counter = missions 
$tfired=0;
$tahit=0;
$tahitwf=0;
$tghit=0;
$ttime=0;
$takills=0;
$takillswf=0;
$tgkills=0;
$tsmoke=0;
$tlights=0;

while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
	$i++;

	$tfired+=$row[11];
	$tahit+=$row[12];
	$tghit+=$row[13];
	$ttime+=$row[3];
	$takills+=$row[4];
	if ($row[10] && $row[4]){
		$takillswf+=$row[4];
		$tahitwf+=$row[12];
	}
	$tgkills+=$row[5];
	$tsmoke+=$row[9];
	$tlights+=$row[10];

	$limit=8;
	if ($count=="ALL"){$limit=10000;}

	if ($i<=$limit){
		if ($i%2) { printf("\n <tr>\n");}
		else { printf("\n <tr class=odd>\n");}	

		if ($use_regex) {
			$row[0]=preg_replace("/</","&lt;",$row[0]);
			$row[0]=preg_replace("/>/","&gt;",$row[0]);
		}

		printf(" $tdo &nbsp;<a href=\"/rep/%s\">%s</a>&nbsp;</td>\n $tdo &nbsp;%s&nbsp; </td>\n $tdo &nbsp;%s&nbsp; </td>\n $tdoc %s </td>\n $tdoc %s </td>\n $tdoc %s </td>\n $tdoc %s </td>\n $tdoc %s </td>\n $tdoc %s </td> $tdoc %s </td> $tdoc %s </td>\n $tdoc %s </td>\n $tdo \n   $smtb   $tdor %s </td>\n   $tdor %s </td>\n   $tdor %s </td>\n   $tdoc|</td>\n   $tdor %s </td>\n   $tdor %s </td>\n   </td>\n $tdo &nbsp;%s&nbsp; </td></tr>\n", 
	$row[18], $row[18], $row[1], $row[28], $row[29], $row[3], $row[4], $row[5], $row[6],$row[7],$row[8], $row[9], $row[10], $row[11], $row[12], $row[13], $row[14], $row[15], $row[16]);
	}
} 

        print "</table>\n";



?>

</center>

<center>

<table  border="0">
<tr>

<td valign="top">

<br><br>
  <center>
    <h3>Last Air kills</h3>

 <table class=rndtable>
  <tr class=first>
    <td class="ltr70c" align="center">Mission</td>
    <td class="ltr70c" align="center">Your Plane</td>
    <td class="ltr70c" align="center">Downs to</td>
    <td class="ltr70c" align="center">In plane</td>
  </tr>

<?php

$tdo="<td class=\"ltr70c\">";
$tdor="<td class=\"ltr70c\" align=\"right\">";
$tdoc="<td class=\"ltr70c\" align=\"center\">";
$tdol="<td class=\"ltr70c\" align=\"left\">";
$tdoRED="<td class=\"ltr70c \">";

	$query="select misnum,misrep,hlkiller,plane_killer,hlkilled,plane_killed,wasfriend from badc_air_event where hlkiller='$hlname' and campanya = \"$campanya\" and mapa =\"$mapa\" order by misrep DESC limit 5";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());


	$iak=0;
	while ($row2 = mysql_fetch_array($result, MYSQL_NUM)) {
	$iak++;

		if ($iak%2) { printf("\n<tr>\n");}
		else      { printf("\n<tr class=odd>\n");}	

		if ($use_regex) {
			$row2[2]=preg_replace("/</","&lt;",$row[2]);
			$row2[2]=preg_replace("/>/","&gt;",$row[2]);
		}
		$hlkilled=$row2[4];
		$row2[4]=preg_replace("/</","&lt;",$row2[4]);	
		$row2[4]=preg_replace("/>/","&gt;",$row2[4]);
		$hlkilled=preg_replace("/\+/","%2B",$hlkilled);	

                $wasfriend=$row2[6];
		if (!$wasfriend){
			printf ("$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n$tdo &nbsp;%s&nbsp;</td>\n$tdo &nbsp;<a href=\"/pilot.php?hlname=%s\">%s</a>&nbsp;</td>\n$tdo &nbsp;%s&nbsp;</td></tr>\n",$row2[1], $row2[1], $row2[3], $hlkilled, $row2[4], $row2[5]);
		}
		else {
			printf ("$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n$tdo &nbsp;%s&nbsp;</td>\n $tdo &nbsp;<a href=\"/pilot.php?hlname=%s\">%s</a>&nbsp;</td>\n$tdoRED&nbsp;%s&nbsp; </td></tr>\n",$row2[1], $row2[1], $row2[3], $hlkilled, $row2[4], $row2[5]);
		}

	}

		print "<tr class=first><td align=\"center\" colspan=\"5\"><a href=\"show_akills.php?hlname=$hlname\">View All</a></td></tr>";
?> 

</table></center>


</td>
<td width=20px></td> 
<td valign="top">

<center>
<br><br>
    <h3>Last Ground Kills</h3>

 <table class=rndtable>
  <tr class=first>
    <td class="ltr70c" align="center">Mission</td>
    <td class="ltr70c" align="center">In PLane</td>
    <td class="ltr70c" align="center">Object killed</td>
  </tr>

<?php

$tdo="<td class=\"ltr70c\">";
$tdor="<td class=\"ltr70c\" align=\"right\">";
$tdoc="<td class=\"ltr70c\" align=\"center\">";
$tdol="<td class=\"ltr70c\" align=\"left\">";
$tdoRED="<td class=\"ltr70c \">";

	$query="select misnum,misrep,hlkiller,plane_killer,objkilled,wasfriend from badc_grnd_event where hlkiller='$hlname' and campanya = \"$campanya\" and mapa =\"$mapa\"  order by misrep DESC limit 5";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

	$igk=0;
	while ($row3 = mysql_fetch_array($result, MYSQL_NUM)) {
	$igk++;
		if ($igk%2) { printf("\n <tr>\n");}
		else      { printf("\n <tr class=odd>\n");}	

		if ($use_regex) {
			$row3[2]=preg_replace("/</","&lt;",$row3[2]);
			$row3[2]=preg_replace("/>/","&gt;",$row3[2]);
		}
		$wasfriend=$row3[5];
		if (!$wasfriend){
			printf ("
				$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n
				$tdo &nbsp;%s&nbsp; </td>\n
				$tdo &nbsp;%s&nbsp;</td>\n
				</tr>\n",$row3[1], $row3[1], $row3[3], $row3[4]);
		}
		else {
			printf ("
				$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n
				$tdo &nbsp;%s&nbsp; </td>\n
				$tdoRED &nbsp;%s&nbsp;</td>\n
				</tr>\n",$row3[1], $row3[1], $row3[3], $row3[4]);
		}
	}

		print "<tr class=first><td align=\"center\" colspan=\"5\"><a href=\"show_gkills.php?hlname=$hlname\">View All</a></td></tr>";
?> 

</table></center>

</td>
</tr> </table>

<br><br><br>


<center>

<table  border="0">
<tr>

<td valign="top">

  <center>
    <h3>Last downs</h3>

 <table class=rndtable>
  <tr class=first>
    <td class="ltr70c" align="center">Mission</td>
    <td class="ltr70c" align="center">Your Plane</td>
    <td class="ltr70c" align="center">Down by</td>
    <td class="ltr70c" align="center">In plane</td>
  </tr>

<?php

$tdo="<td class=\"ltr70c\">";
$tdor="<td class=\"ltr70c\" align=\"right\">";
$tdoc="<td class=\"ltr70c\" align=\"center\">";
$tdol="<td class=\"ltr70c\" align=\"left\">";
$tdoRED="<td class=\"ltr70c \">";

	$query="select misnum,misrep,hlkilled,plane_killed,hlkiller,plane_killer,wasfriend from badc_air_event where hlkilled='$hlname' and campanya = \"$campanya\" and mapa =\"$mapa\" order by misrep DESC limit 5";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());


	$iak=0;
	while ($row2 = mysql_fetch_array($result, MYSQL_NUM)) {
	$iak++;

		if ($iak%2) { printf("\n <tr>\n");}
		else      { printf("\n <tr class=odd>\n");}	

		if ($use_regex) {
			$row2[2]=preg_replace("/</","&lt;",$row[2]);
			$row2[2]=preg_replace("/>/","&gt;",$row[2]);
		}
		$hlkilled=$row2[4];
		$row2[4]=preg_replace("/</","&lt;",$row2[4]);	
		$row2[4]=preg_replace("/>/","&gt;",$row2[4]);
		$hlkilled=preg_replace("/\+/","%2B",$hlkilled);	

                $wasfriend=$row2[6];
		if (!$wasfriend){
		    printf ("$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n$tdo &nbsp;%s&nbsp;</td>\n $tdo &nbsp;<a href=\"/pilot.php?hlname=%s\">%s</a>&nbsp;</td>\n$tdo &nbsp;%s&nbsp; </td></tr>\n",$row2[1], $row2[1], $row2[3], $hlkilled, $row2[4], $row2[5]);
		}
		else {
		    printf ("$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n$tdo &nbsp;%s&nbsp;</td>\n $tdo &nbsp;<a href=\"/pilot.php?hlname=%s\">%s</a>&nbsp;</td>\n$tdoRED &nbsp;%s&nbsp;</td></tr>\n",$row2[1], $row2[1], $row2[3], $hlkilled, $row2[4], $row2[5]);
		}
	}

		print "<tr class=first><td align=\"center\" colspan=\"5\"><a href=\"show_downs.php?hlname=$hlname\">View All</a></td></tr>";
?> 

</table></center>


</td>
<td width=20px></td> 
<td valign="top">

<center>
    <h3>Last rescues</h3>

 <table  class=rndtable>
  <tr class=first>
    <td class="ltr70c" align="center">Mission</td>
    <td class="ltr70c" align="center">Rescue to</td>
  </tr>

<?php

$tdo="<td class=\"ltr70c\">";
$tdor="<td class=\"ltr70c\" align=\"right\">";
$tdoc="<td class=\"ltr70c\" align=\"center\">";
$tdol="<td class=\"ltr70c\" align=\"left\">";


	$query="select misrep,rescatado from badc_rescues where rescatador='$hlname' and campanya = \"$campanya\" and mapa =\"$mapa\" order by misrep DESC limit 5";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

	$igk=0;
	while ($row3 = mysql_fetch_array($result, MYSQL_NUM)) {
	$igk++;
		if ($igk%2) { printf("\n <tr>\n");}
		else      { printf("\n <tr class=odd>\n");}	

		if ($use_regex) {
			$row3[2]=preg_replace("/</","&lt;",$row3[2]);
			$row3[2]=preg_replace("/>/","&gt;",$row3[2]);
		}
		printf ("
	$tdo &nbsp; <a href=\"/rep/%s\">%s</a>&nbsp;</td>\n
	$tdo %s &nbsp;</td>\n
	</tr>\n",$row3[0], $row3[0], $row3[1]);
	}

		print "<tr class=first><td align=\"center\" colspan=\"5\"><a href=\"show_rescues.php?hlname=$hlname\">View All</a></td></tr>";
?> 

</table></center>

</td>
</tr> </table>


<center><br/><br/><br/>
<table border ="0">
<tr>

<?php


	print " <td> <center><h3>Planes used: </h3></center></td>\n";
	print " <td width=20px></td>\n";	
	print " <td> <center><h3>Weapons used: </h3> </center></td><tr>\n<td  valign=\"top\">\n";	

	// @Heracles20110808
	// Calculamos todas las misiones de la campaña.
	$query="select count(*) from badc_pilot_mis WHERE hlname=\"$hlname\"";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);
	$i=$row[0];

	// aircraft used
	$query="select plane,count(*) from badc_pilot_mis WHERE hlname=\"$hlname\" GROUP BY plane ORDER BY plane ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

	$tdo="<td class=\"ltr70c\">";
	print "<table class=rndtable_nohover>\n";
	print "<col width=\"15\"> <col width=\"28\"> <col width=\"28\"> <col width=\"200\">\n";
	print "<tr><td>&nbsp;</td>$tdoC N</td>$tdoC %</td>$tdo Plot</td></tr>\n";
	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {	
	    printf("<tr><td align=right> %s</td>$tdo <center>%d</center></td>$tdo %02.0f%%</td>",$row[0],$row[1],($row[1]*100/$i));
	    $color="r";
	    if (($row[1]*100/$i)>10){$color="y";}
	    if (($row[1]*100/$i)>20){$color="b";}
	    if (($row[1]*100/$i)>30){$color="g";}
	    printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[1]*200/$i));
	}
print"</table>\n </td><td></td><td  valign=\"top\">\n";
	// weapons used
	$query="select weapons,count(*) from badc_pilot_mis WHERE hlname=\"$hlname\" GROUP BY weapons ORDER BY weapons ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());


	$tdo="<td class=\"ltr70c\">";
	print "<table class=rndtable_nohover>\n";
	print "<col width=\"15\"> <col width=\"28\"> <col width=\"28\"> <col width=\"200\">\n";
	print "<tr><td>&nbsp;</td>$tdoC N</td>$tdoC %</td>$tdo Plot</td></tr>\n";
	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {	
	    $row[0]=preg_replace("/\'/","",$row[0]);
	    printf("<tr><td align=right> %s</td>$tdo <center>%d</center></td>$tdo %02.0f%%</td>",$row[0],$row[1],($row[1]*100/$i));
	    $color="r";
	    if (($row[1]*100/$i)>10){$color="y";}
	    if (($row[1]*100/$i)>20){$color="b";}
	    if (($row[1]*100/$i)>30){$color="g";}
	    printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[1]*200/$i));
	}
	print"</table>\n</td></tr>\n";

	print "<tr><td colspan=3><br/><br/></td>\n";	

	print "<tr><td valign=\"top\"> <center><h3>Fuel Loads: </h3></center></td>\n";
	print "<td width=20px></td>\n";
	print " <td> <center><h3>Status : </h3> </center></td><tr>\n<td  valign=\"top\">\n";	

	// fuel loads
	$query="select fuel,count(*) from badc_pilot_mis WHERE hlname=\"$hlname\" GROUP BY fuel ORDER BY fuel ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

	$tdo="<td class=\"ltr70c\">";
	print "<table  class=rndtable_nohover>\n";
	print "<col width=\"15\"> <col width=\"28\"> <col width=\"28\"> <col width=\"200\">\n";
	print "<tr><td>&nbsp;</td>$tdoC N</td>$tdoC %</td>$tdo Plot</td></tr>\n";
	while ($row = mysql_fetch_array($result, MYSQL_NUM)) {	
	    printf("<tr><td align=right> %s</td>$tdo <center>%d</center></td>$tdo %02.0f%%</td>",$row[0],$row[1],($row[1]*100/$i));
	    $color="r";
	    if (($row[1]*100/$i)>15){$color="y";}
	    if (($row[1]*100/$i)>30){$color="b";}
	    if (($row[1]*100/$i)>45){$color="g";}
	    printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[1]*200/$i));
	}
print"</table>\n</td><td></td><td  valign=\"top\">\n";
    // Staus
    $query="select missions,landed,crash,killed,captured,bailed,in_flight,disco from badc_pilot_file WHERE hlname=\"$hlname\"";
    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
    $row = mysql_fetch_array($result, MYSQL_NUM);    
    
    $tdo="<td class=\"ltr70c\">";
    print "<table class=rndtable_nohover>\n";
	print "<col width=\"15\"> <col width=\"28\"> <col width=\"28\"> <col width=\"200\">\n";
	print "<tr><td>&nbsp;</td>$tdoC N</td>$tdoC %</td>$tdo Plot</td></tr>\n";

    if ($row[0]){

    printf("<tr><td align=right> Landed</td>$tdo <center>%d</center></td>$tdoC %02.0f%%</td>",$row[1],($row[1]*100/$i));
    if ($row[1]){
    	$color="r";
	if (($row[1]*100/$i)>15){$color="y";}
	if (($row[1]*100/$i)>30){$color="b";}
	if (($row[1]*100/$i)>45){$color="g";}
    	printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[1]*200/$i));
    }
    else {print "$tdo &nbsp;</td></tr>\n";}

    printf("<tr><td align=right> Crashed</td>$tdo <center>%d</center></td>$tdoC %02.0f%%</td>",$row[2],($row[2]*100/$i));
    if ($row[2]){
    	$color="r";	
	if (($row[2]*100/$i)>15){$color="y";}
	if (($row[2]*100/$i)>30){$color="b";}
	if (($row[2]*100/$i)>45){$color="g";}
    	printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[2]*200/$i));
    }
    else {print "$tdo &nbsp;</td></tr>\n";}

    printf("<tr><td align=right> Kia</td>$tdo <center>%d</center></td>$tdoC %02.0f%%</td>",$row[3],($row[3]*100/$i));
    if ($row[3]){
    	$color="r";
	if (($row[3]*100/$i)>15){$color="y";}
	if (($row[3]*100/$i)>30){$color="b";}
	if (($row[3]*100/$i)>45){$color="g";}
    	printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[3]*200/$i));
    }
    else {print "$tdo &nbsp;</td></tr>\n";}

    printf("<tr><td align=right> Captured</td>$tdo <center>%d</center></td>$tdoC %02.0f%%</td>",$row[4],($row[4]*100/$i));
    if ($row[4]){
    	$color="r";
	if (($row[4]*100/$i)>15){$color="y";}
	if (($row[4]*100/$i)>30){$color="b";}
	if (($row[4]*100/$i)>45){$color="g";}
    	printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[4]*200/$i));
    }
    else {print "$tdo &nbsp;</td></tr>\n";}

    printf("<tr><td align=right> Bailed</td>$tdo <center>%d</center></td>$tdoC %02.0f%%</td>",$row[5],($row[5]*100/$i));
    if ($row[5]){
    	$color="r";
	if (($row[5]*100/$i)>15){$color="y";}
	if (($row[5]*100/$i)>30){$color="b";}
	if (($row[5]*100/$i)>45){$color="g";}
    	printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[5]*200/$i));
    }
    else {print "$tdo &nbsp;</td></tr>\n";}

    printf("<tr><td align=right> In Flight</td>$tdo <center>%d</center></td>$tdoC %02.0f%%</td>",$row[6],($row[6]*100/$i));
    if ($row[6]){
    	$color="r";
	if (($row[6]*100/$i)>15){$color="y";}
	if (($row[6]*100/$i)>30){$color="b";}
	if (($row[6]*100/$i)>45){$color="g";}
    	printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[6]*200/$i));
    }
    else {print "$tdo &nbsp;</td></tr>\n";}

    printf("<tr><td align=right> Disco</td>$tdo <center>%d</center></td>$tdoC %02.0f%%</td>",$row[7],($row[7]*100/$i));
    if ($row[7]){
      	$color="r";
	if (($row[7]*100/$i)>15){$color="y";}
	if (($row[7]*100/$i)>30){$color="b";}
	if (($row[7]*100/$i)>45){$color="g";}
      printf("$tdo <img src=\"images/$color.png\" height=\"7\" width=\"%.0f\" alt=\"\"></td></tr>\n",($row[7]*200/$i));
    }
    else {print "$tdo &nbsp;</td></tr>\n";}

   $total=$row[1]+$row[2]+$row[3]+$row[4]+$row[5]+$row[6]+$row[7];
    printf("<tr><td align=right> Total</td>$tdo %d</td>$tdoC %02.0f%%</td>",$total,($total*100/$i));
    print "$tdo &nbsp;</td></tr>\n";
    }
    print"</table>\n</td></tr>";

?> 
</table>
</center>


<?php 
include ("./dz_page_footer.php");
?>


