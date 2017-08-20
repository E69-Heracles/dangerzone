<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<?php
	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");
        $now_epoch=date("U");
	$html_hlname="";
        $minutes=0;
	$seconds=0;

print "<br/><br/><center>\n";
print "<h3>Missions in Creation Stage</h3>\n";
print "</center>\n";

?>


<table class=rndtable_nohover cellspacing="2" cellpadding="2">  <!-- Main table -->
<tr>
    <td class="ltr70C"> <!-- Left Slot Start -->
        <table cellspacing="1" cellpadding=2> <!-- BW1 Table Start -->
	<col width="30"> <col width="140"> <col width="90">

<?php
        $query="select status, epoca from badc_host_slots where slot='BW1'";
   	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);
	if ($row[0] == 0  || ($row[1] < $now_epoch) ) { // el slot esta libre o expiro
	print "
	    <tr bgcolor =\"#999999\">
        <td class=\"ltr70C\" align=\"center\"><b>BW1</b></td>
     		<td class=\"ltr70C\"><b>Unused (BW&nbsp;#&nbsp;1&nbsp;1)</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: 00m 00s</td>
	    </tr>
	    <tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\"><a href=\"take_slot.php?slot=BW1\"><font size=\"-2\"color=\"#ffffff\">Host BW #1 1</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>\n";
	} 
	else { // host esta ocupado

            $query="select max_human, epoca, hlname, status from badc_host_slots where slot='BW1'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[2];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);
	    $expire_secs = ($row[1]-$now_epoch);
	    if ($expire_secs > 0) {
		$minutes = (int) ($expire_secs / 60);
		if ($minutes) {$expire_secs-=($minutes * 60);}
		$seconds = $expire_secs; // el resto aqui
	    }
	    else {
	    	$minutes =0;
	    	$seconds =0;
	    }
	    if ($minutes <10){$minutes="0".$minutes;}
	    if ($seconds <10){$seconds="0".$seconds;}

	    print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW1</b></td>
     		<td class=\"ltr70C\">BW&nbsp;#&nbsp;1&nbsp;1 Type: <b>$row[0] x $row[0]</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: ".$minutes."m ".$seconds."s</td>
	    </tr>";

	    print "
	    <tr bgcolor =\"#999999\">
    		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW1\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";
	    if ($row[3] == 2) { // mis ready 
	        $query="select epoca from badc_host_slots where slot='BW1RR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$red_solic=$row[0];
	        $query="select epoca from badc_host_slots where slot='BW1BR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$blue_solic=$row[0];

    		print "<td class=\"ltr70c\" align=\"center\"><a href=\"/mis_download.php?red_solic=$red_solic&amp;blue_solic=$blue_solic\"><font color=\"#00cc00\">download</font></a></td>\n</tr>";
 	    }
	    else {
    		print "\n                <td class=\"ltr70C\" align=\"center\">Waiting</td>\n            </tr>";
	    }

	    // miramos el request VVS

	    $query="select status, hlname from badc_host_slots where slot='BW1RR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // vvs req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW1RR\"><font size=\"-2\"color=\"#ffffff\">BW #1 1 VVS Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW1RR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }

	    // miramos el request LW

	    $query="select status, hlname from badc_host_slots where slot='BW1BR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // lw req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW1BR\"><font size=\"-2\"color=\"#ffffff\">BW #1 1 LW Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW1BR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }
	}

?>

        </table>           <!-- BW1 Table End -->
    </td><!-- Left Slot End -->

    <td>&nbsp;&nbsp;&nbsp;</td>

    <td class="ltr70c"> <!-- Center Slot Start -->
        <table  cellspacing="1" cellpadding=2> <!-- BW2 Table Start -->
	<col width="30"> <col width="140"> <col width="90">


<?php
        $query="select status , epoca from badc_host_slots where slot='BW2'";
   	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);
	if ($row[0] == 0  || ($row[1] < $now_epoch) ) { // el slot esta libre o expiro
	print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW2</b></td>
     		<td class=\"ltr70C\"><b>Unused (BW&nbsp;#&nbsp;1&nbsp;2)</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: 00m 00s</td>
	    </tr>
	    <tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\"><a href=\"take_slot.php?slot=BW2\"><font size=\"-2\"color=\"#ffffff\">Host BW #1 2</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>\n";
	} 
	else { // host esta ocupado

            $query="select max_human, epoca, hlname, status from badc_host_slots where slot='BW2'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[2];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);
	    $expire_secs = ($row[1]-$now_epoch);
	    if ($expire_secs > 0) {
		$minutes = (int) ($expire_secs / 60);
		if ($minutes) {$expire_secs-=($minutes * 60);}
		$seconds = $expire_secs; // el resto aqui
	    }
	    else {
	    	$minutes =0;
	    	$seconds =0;
	    }
	    if ($minutes <10){$minutes="0".$minutes;}
	    if ($seconds <10){$seconds="0".$seconds;}

	    print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW2</b></td>
     		<td class=\"ltr70C\">BW&nbsp;#&nbsp;1&nbsp;2 Type: <b>$row[0] x $row[0]</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: ".$minutes."m ".$seconds."s</td>
	    </tr>";

	    print "
	    <tr bgcolor =\"#999999\">
    		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW2\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";
	    if ($row[3] == 2) { // mis ready 
		$query="select epoca from badc_host_slots where slot='BW2RR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$red_solic=$row[0];
	        $query="select epoca from badc_host_slots where slot='BW2BR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$blue_solic=$row[0];

    		print "<td class=\"ltr70c\" align=\"center\"><a href=\"/mis_download.php?red_solic=$red_solic&amp;blue_solic=$blue_solic\"><font color=\"#00cc00\">download</font></a></td>\n</tr>";
 	    }
	    else {
    		print "\n                <td class=\"ltr70C\" align=\"center\">Waiting</td>\n            </tr>";
	    }

	    // miramos el request VVS

	    $query="select status, hlname from badc_host_slots where slot='BW2RR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // vvs req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW2RR\"><font size=\"-2\"color=\"#ffffff\">BW #1 2 VVS Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW2RR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }

	    // miramos el request LW

	    $query="select status, hlname from badc_host_slots where slot='BW2BR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // lw req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW2BR\"><font size=\"-2\"color=\"#ffffff\">BW #1 2 LW Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW2BR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }
	}

?>

	</table>	<!-- BW2 Table End -->
    </td><!-- Center Slot End -->

    <td>&nbsp;&nbsp;&nbsp;</td>

    <td class="ltr70c"> <!-- Right Slot Start -->
        <table  cellspacing="1" cellpadding=2> <!-- BW3 Table Start -->
	<col width="30"> <col width="140"> <col width="90">


<?php
        $query="select status , epoca from badc_host_slots where slot='BW3'";
   	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);
	if ($row[0] == 0  || ($row[1] < $now_epoch) ) { // el slot esta libre o expiro
	print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW3</b></td>
     		<td class=\"ltr70C\"><b>Unused (BW&nbsp;#&nbsp;1&nbsp;3)</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: 00m 00s</td>
	    </tr>
	    <tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\"><a href=\"take_slot.php?slot=BW3\"><font size=\"-2\"color=\"#ffffff\">Host BW #1 3</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>\n";
	} 
	else { // host esta ocupado

            $query="select max_human, epoca, hlname, status from badc_host_slots where slot='BW3'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[2];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);
	    $expire_secs = ($row[1]-$now_epoch);
	    if ($expire_secs > 0) {
		$minutes = (int) ($expire_secs / 60);
		if ($minutes) {$expire_secs-=($minutes * 60);}
		$seconds = $expire_secs; // el resto aqui
	    }
	    else {
	    	$minutes =0;
	    	$seconds =0;
	    }
	    if ($minutes <10){$minutes="0".$minutes;}
	    if ($seconds <10){$seconds="0".$seconds;}

	    print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW3</b></td>
     		<td class=\"ltr70C\">BW&nbsp;#&nbsp;1&nbsp;3 Type: <b>$row[0] x $row[0]</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: ".$minutes."m ".$seconds."s</td>
	    </tr>";

	    print "
	    <tr bgcolor =\"#999999\">
    		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW3\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";
	    if ($row[3] == 2) { // mis ready 
		$query="select epoca from badc_host_slots where slot='BW3RR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$red_solic=$row[0];
	        $query="select epoca from badc_host_slots where slot='BW3BR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$blue_solic=$row[0];

    		print "<td class=\"ltr70c\" align=\"center\"><a href=\"/mis_download.php?red_solic=$red_solic&amp;blue_solic=$blue_solic\"><font color=\"#00cc00\">download</font></a></td>\n</tr>";
 	    }
	    else {
    		print "\n                <td class=\"ltr70C\" align=\"center\">Waiting</td>\n            </tr>";
	    }

	    // miramos el request VVS

	    $query="select status, hlname from badc_host_slots where slot='BW3RR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // vvs req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW3RR\"><font size=\"-2\"color=\"#ffffff\">BW #1 3 VVS Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW3RR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }

	    // miramos el request LW

	    $query="select status, hlname from badc_host_slots where slot='BW3BR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // lw req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW3BR\"><font size=\"-2\"color=\"#ffffff\">BW #1 3 LW Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW3BR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }
	}

?>


	</table>	<!-- BW3 Table End -->
    </td><!-- Right Slot End -->
</tr>
<tr><td><br/></td></tr>
	
<tr>
    <td class="ltr70c"> <!-- Left Slot Start -->
        <table  cellspacing="1" cellpadding=2> <!-- BW4 Table Start -->
	<col width="30"> <col width="140"> <col width="90">

<?php
        $query="select status, epoca from badc_host_slots where slot='BW4'";
   	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);
	if ($row[0] == 0  || ($row[1] < $now_epoch) ) { // el slot esta libre o expiro
	print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW4</b></td>
     		<td class=\"ltr70C\"><b>Unused (BW&nbsp;#&nbsp;2&nbsp;1)</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: 00m 00s</td>
	    </tr>
	    <tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\"><a href=\"take_slot.php?slot=BW4\"><font size=\"-2\"color=\"#ffffff\">Host BW #2 1</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>\n";
	} 
	else { // host esta ocupado

            $query="select max_human, epoca, hlname, status from badc_host_slots where slot='BW4'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[2];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);
	    $expire_secs = ($row[1]-$now_epoch);
	    if ($expire_secs > 0) {
		$minutes = (int) ($expire_secs / 60);
		if ($minutes) {$expire_secs-=($minutes * 60);}
		$seconds = $expire_secs; // el resto aqui
	    }
	    else {
	    	$minutes =0;
	    	$seconds =0;
	    }
	    if ($minutes <10){$minutes="0".$minutes;}
	    if ($seconds <10){$seconds="0".$seconds;}

	    print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW4</b></td>
     		<td class=\"ltr70C\">BW&nbsp;#&nbsp;2&nbsp;1 Type: <b>$row[0] x $row[0]</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: ".$minutes."m ".$seconds."s</td>
	    </tr>";

	    print "
	    <tr bgcolor =\"#999999\">
    		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW4\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";
	    if ($row[3] == 2) { // mis ready 
	        $query="select epoca from badc_host_slots where slot='BW4RR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$red_solic=$row[0];
	        $query="select epoca from badc_host_slots where slot='BW4BR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$blue_solic=$row[0];

    		print "<td class=\"ltr70c\" align=\"center\"><a href=\"/mis_download.php?red_solic=$red_solic&amp;blue_solic=$blue_solic\"><font color=\"#00cc00\">download</font></a></td>\n</tr>";
 	    }
	    else {
    		print "\n                <td class=\"ltr70C\" align=\"center\">Waiting</td>\n            </tr>";
	    }

	    // miramos el request VVS

	    $query="select status, hlname from badc_host_slots where slot='BW4RR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // vvs req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW4RR\"><font size=\"-2\"color=\"#ffffff\">BW #2 1 VVS Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW4RR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }

	    // miramos el request LW

	    $query="select status, hlname from badc_host_slots where slot='BW4BR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // lw req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW4BR\"><font size=\"-2\"color=\"#ffffff\">BW #2 1 LW Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW4BR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }
	}

?>

        </table>           <!-- BW4 Table End -->
    </td><!-- Left Slot End -->

    <td>&nbsp;&nbsp;&nbsp;</td>

    <td class="ltr70c"> <!-- Center Slot Start -->
        <table  cellspacing="1" cellpadding=2> <!-- BW5 Table Start -->
	<col width="30"> <col width="140"> <col width="90">


<?php
        $query="select status , epoca from badc_host_slots where slot='BW5'";
   	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);
	if ($row[0] == 0  || ($row[1] < $now_epoch) ) { // el slot esta libre o expiro
	print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW5</b></td>
     		<td class=\"ltr70C\"><b>Unused (BW&nbsp;#&nbsp;2&nbsp;2)</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: 00m 00s</td>
	    </tr>
	    <tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\"><a href=\"take_slot.php?slot=BW5\"><font size=\"-2\"color=\"#ffffff\">Host BW #2 2</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>\n";
	} 
	else { // host esta ocupado

            $query="select max_human, epoca, hlname, status from badc_host_slots where slot='BW5'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[2];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);
	    $expire_secs = ($row[1]-$now_epoch);
	    if ($expire_secs > 0) {
		$minutes = (int) ($expire_secs / 60);
		if ($minutes) {$expire_secs-=($minutes * 60);}
		$seconds = $expire_secs; // el resto aqui
	    }
	    else {
	    	$minutes =0;
	    	$seconds =0;
	    }
	    if ($minutes <10){$minutes="0".$minutes;}
	    if ($seconds <10){$seconds="0".$seconds;}

	    print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW5</b></td>
     		<td class=\"ltr70C\">BW&nbsp;#&nbsp;2&nbsp;2 Type: <b>$row[0] x $row[0]</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: ".$minutes."m ".$seconds."s</td>
	    </tr>";

	    print "
	    <tr bgcolor =\"#999999\">
    		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW5\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";
	    if ($row[3] == 2) { // mis ready 
		$query="select epoca from badc_host_slots where slot='BW5RR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$red_solic=$row[0];
	        $query="select epoca from badc_host_slots where slot='BW5BR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$blue_solic=$row[0];

    		print "<td class=\"ltr70c\" align=\"center\"><a href=\"/mis_download.php?red_solic=$red_solic&amp;blue_solic=$blue_solic\"><font color=\"#00cc00\">download</font></a></td>\n</tr>";
 	    }
	    else {
    		print "\n                <td class=\"ltr70C\" align=\"center\">Waiting</td>\n            </tr>";
	    }

	    // miramos el request VVS

	    $query="select status, hlname from badc_host_slots where slot='BW5RR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // vvs req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW5RR\"><font size=\"-2\"color=\"#ffffff\">BW #2 2 VVS Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW5RR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }

	    // miramos el request LW

	    $query="select status, hlname from badc_host_slots where slot='BW5BR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // lw req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW5BR\"><font size=\"-2\"color=\"#ffffff\">BW #2 2 LW Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW5BR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }
	}

?>

	</table>	<!-- BW5 Table End -->
    </td><!-- Center Slot End -->

    <td>&nbsp;&nbsp;&nbsp;</td>

    <td class="ltr70c"> <!-- Right Slot Start -->
        <table  cellspacing="1" cellpadding=2> <!-- BW6 Table Start -->
	<col width="30"> <col width="140"> <col width="90">


<?php
        $query="select status , epoca from badc_host_slots where slot='BW6'";
   	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);
	if ($row[0] == 0  || ($row[1] < $now_epoch) ) { // el slot esta libre o expiro
	print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW6</b></td>
     		<td class=\"ltr70C\"><b>Unused (BW&nbsp;#&nbsp;2&nbsp;3)</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: 00m 00s</td>
	    </tr>
	    <tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\"><a href=\"take_slot.php?slot=BW6\"><font size=\"-2\"color=\"#ffffff\">Host BW #2 3</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>
	    <tr bgcolor=\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td class=\"ltr70C\">&nbsp;</td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	    </tr>\n";
	} 
	else { // host esta ocupado

            $query="select max_human, epoca, hlname, status from badc_host_slots where slot='BW6'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[2];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);
	    $expire_secs = ($row[1]-$now_epoch);
	    if ($expire_secs > 0) {
		$minutes = (int) ($expire_secs / 60);
		if ($minutes) {$expire_secs-=($minutes * 60);}
		$seconds = $expire_secs; // el resto aqui
	    }
	    else {
	    	$minutes =0;
	    	$seconds =0;
	    }
	    if ($minutes <10){$minutes="0".$minutes;}
	    if ($seconds <10){$seconds="0".$seconds;}

	    print "
	    <tr bgcolor =\"#999999\">
                <td class=\"ltr70C\" align=\"center\"><b>BW6</b></td>
     		<td class=\"ltr70C\">BW&nbsp;#&nbsp;2&nbsp;3 Type: <b>$row[0] x $row[0]</b></td>
    		<td class=\"ltr70C\" align=\"center\">Ex: ".$minutes."m ".$seconds."s</td>
	    </tr>";

	    print "
	    <tr bgcolor =\"#999999\">
    		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW6\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";
	    if ($row[3] == 2) { // mis ready 
		$query="select epoca from badc_host_slots where slot='BW6RR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$red_solic=$row[0];
	        $query="select epoca from badc_host_slots where slot='BW6BR'";
   	        $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	        $row = mysql_fetch_array($result, MYSQL_NUM);
		$blue_solic=$row[0];

    		print "<td class=\"ltr70c\" align=\"center\"><a href=\"/mis_download.php?red_solic=$red_solic&amp;blue_solic=$blue_solic\"><font color=\"#00cc00\">download</font></a></td>\n</tr>";
 	    }
	    else {
    		print "\n                <td class=\"ltr70C\" align=\"center\">Waiting</td>\n            </tr>";
	    }

	    // miramos el request VVS

	    $query="select status, hlname from badc_host_slots where slot='BW6RR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // vvs req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW6RR\"><font size=\"-2\"color=\"#ffffff\">BW #2 3 VVS Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW6RR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }

	    // miramos el request LW

	    $query="select status, hlname from badc_host_slots where slot='BW6BR'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
            $html_hlname=$row[1];
	    $html_hlname=preg_replace("/</","&lt;",$html_hlname);
	    $html_hlname=preg_replace("/>/","&gt;",$html_hlname);

	    if ($row[0] == 0) { // lw req libre
	        print"
		<tr bgcolor =\"#999999\">
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
    		<td><a href=\"take_slot.php?slot=BW6BR\"><font size=\"-2\"color=\"#ffffff\">BW #2 3 LW Request</font></a></td>
    		<td class=\"ltr70C\" align=\"center\">&nbsp;</td>
	        </tr>";
	    }
	    else { // ocupado
		print "
		<tr bgcolor =\"#999999\">
		<td align=\"center\"><a href=\"/cgi-bin/leave_slot.pl?slot=BW6BR\"><font color=\"red\" size=\"-2\">del</font></a></td>
    		<td class=\"ltr70C\">$html_hlname</td>";

	    	if ($row[0] == 1) { // vvs req waiting
                	print "		<td class=\"ltr70C\" align=\"center\">Building</td>\n	        </tr>";
		}
	    	if ($row[0] == 2) { // vvs req ready
                	print "		<td class=\"ltr70C\" align=\"center\">Ready</td>\n	        </tr>";
		}

	    }
	}

?>


	</table>	<!-- BW6 Table End -->
    </td><!-- Right Slot End -->
</tr>
</table> <!-- END Main table slots BW4 BW5 BW6-->
<br>


<?php
$filename = "$path_to_cgi_bin/_gen.lock";
$filename2 = "$path_to_cgi_bin/_gen.stop";
if (file_exists($filename)|| file_exists($filename2)) {
    print "Generator Status: <b><font color=\"red\">Down</font></b>&nbsp;&nbsp;&nbsp;&nbsp;";
} else {
    print "Generator Status: <b><font color=\"green\">Up</font></b>&nbsp;&nbsp;&nbsp;&nbsp;";
}

$filename = "$path_to_cgi_bin/_par.lock";
$filename2 = "$path_to_cgi_bin/_par.stop";
if (file_exists($filename) || file_exists($filename2)) {
    print "Parser Status: <b><font color=\"red\">Down</font></b><br>\n";
} else {
    print "Parser Status: <b><font color=\"green\">Up</font></b><br>\n";
}
?>

</center>
<br>



<?php

//	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
//	mysql_select_db("$database");

	$now_epoch=date("U");
	$five_hours_back=$now_epoch - 18000;
	$query="select * from badc_mis_prog where reported = 0 and epoca > $five_hours_back and campanya=\"$campanya\" and mapa=\"$mapa\" order by misnum ASC limit 50";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());

print "<center>\n";
print "<h3>Mission in progress</h3>\n";
print "</center>\n";



print "<center>\n";
print "<table  class=rndtable>\n";


$tdo="<td class=\"ltr70c\">&nbsp;";
$tdk="&nbsp;</td>\n";

print "  <tr bgcolor=\"#ccccc0\">\n    $tdo Nr. $tdk    $tdo Mission $tdk    $tdo Date $tdk    $tdo Time $tdk    $tdo Host $tdk    $tdo VVS attack $tdk $tdo VVS reqest $tdk   $tdo LW attack  $tdk $tdo LW request $tdk    $tdo Status $tdk    </tr>\n";


$i=0;
$now_epoch=date("U");
$mis_time_display=5;
while ($row = mysql_fetch_array($result, MYSQL_NUM)) {

	$misnum=$row[2];
	$host=$row[3];

	$host=preg_replace("/</","&lt;",$host);
	$host=preg_replace("/>/","&gt;",$host);

	$red_tgt=$row[4];
	$blue_tgt=$row[5];

	$red_host=$row[6];
	$red_host=preg_replace("/</","&lt;",$red_host);
	$red_host=preg_replace("/>/","&gt;",$red_host);

	$blue_host=$row[7];
	$blue_host=preg_replace("/</","&lt;",$blue_host);
	$blue_host=preg_replace("/>/","&gt;",$blue_host);

	$reported=$row[8];
	$mis_rep=$row[9];
	$date=$row[10];
	$time=$row[11];
	$epoca=$row[12];

	$total_secs= ($now_epoch - $epoca);
	$days=0;
	$hours=0;
	$minutes=0;
	$seconds=0;

	$days =  (int) ($total_secs / (60*60*24));
	if ($days) {$total_secs-=($days * 60*60*24);}
	$hours = (int) ($total_secs / (60*60));
	if ($hours) {$total_secs-=($hours * 60*60);}
	$minutes = (int) ($total_secs / 60);
	if ($minutes) {$total_secs-=($minutes * 60);}
	$seconds = $total_secs; // el resto aqui


	if ($day==0 && $hours==0 && $minutes < $mis_time_display) {
	    $red_tgt="?????";
	    $blue_tgt="?????";
        }

	if ( $days==0 && $hours < 3) {
	    $i++;
	    if ($i%2) { print "  <tr bgcolor=\"#dddddd\">\n";}
	    else { print "  <tr bgcolor=\"#cbcbcb\">\n";}

	    printf("    $tdo %d $tdk    $tdo %s $tdk    $tdo %s $tdk    $tdo %s $tdk     $tdo %s $tdk    $tdo %s $tdk $tdo %s $tdk $tdo %s $tdk  $tdo %s $tdk", $i, $row[2], $row[10], $row[11], $host, $red_tgt, $red_host, $blue_tgt, $blue_host);

	    if ($minutes <10){$minutes="0".$minutes;}
	    if ($seconds <10){$seconds="0".$seconds;}
	    print " $tdo " . $hours ."h " . $minutes ."m ". $seconds ."s $tdk </tr>\n";
       }
} 

print "</table>\n";
Print "<br><br><font size=\"-2\">Target names are only displayed after  $mis_time_display minutes progress.</font><br>";
Print "<font size=\"-2\">Mission are displayerd if progress is less than 3 hours.</font><br>";
print "</center>\n";
?> 


<br>
<br>


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

if($_GET['d']) { $d=$_GET['d']; }	
if($_GET['m']) { $m=$_GET['m']; }	
if($_GET['y']) { $y=$_GET['y']; }	

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

//	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
//	mysql_select_db("$database");

	$query="select *  from badc_mis_prog where date='$dia' and reported='1' and campanya=\"$campanya\" and mapa=\"$mapa\" order by misrep ASC";
	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());


print "<center>\n";
print "<h3>Reported Missions</h3>\n";
print "</center>\n";

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



$tdo="<td class=\"ltr70c\">&nbsp;";
$tdoC="<td class=\"ltr70c\" align=\"center\">&nbsp;";
$tdoR="<td class=\"ltr70c\" bgcolor =\"#ffcccc\">&nbsp;";
$tdoB="<td class=\"ltr70c\" bgcolor =\"#ccccff\" >&nbsp;";
$tdk="&nbsp;</td>\n";

print "  <tr bgcolor=\"#ccccc0\">\n $tdo Nr. $tdk  $tdo Mission $tdk $tdo Host $tdk  $tdo Won $tdk $tdoR VVS objetive $tdk $tdoR Result $tdk $tdoR Points $tdk $tdoB LW objetive $tdk $tdoB Result $tdk $tdoB Points $tdk $tdo Notes $tdk $tdo Report $tdk </tr>\n";

$i=0;
$now_epoch=date("U");
$mis_time_display=5;
while ($row = mysql_fetch_array($result, MYSQL_NUM)) {

	$misnum=$row[2];
	$host=$row[3];

	$host=preg_replace("/</","&lt;",$host);
	$host=preg_replace("/>/","&gt;",$host);

	$red_tgt=$row[4];
	$blue_tgt=$row[5];

	$red_host=$row[6];
	$red_host=preg_replace("/</","&lt;",$red_host);
	$red_host=preg_replace("/>/","&gt;",$red_host);

	$blue_host=$row[7];
	$blue_host=preg_replace("/</","&lt;",$blue_host);
	$blue_host=preg_replace("/>/","&gt;",$blue_host);

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
	if ($i%2) { print "  <tr bgcolor=\"#dddddd\">\n";}
	else { print "  <tr bgcolor=\"#cbcbcb\">\n";}
	
	if ($side_won ==0){ $side_won="-";}
	if ($side_won ==1){ $side_won="<img src=\"/images/red_dot.gif\" alt=\"\">";}
	if ($side_won ==2){ $side_won="<img src=\"/images/blue_dot.gif\" alt=\"\">";}

	if ($red_result && $red_result != "capture" && $red_result != "fail" ) {$red_result .= " %";}
	if ($blue_result && $blue_result != "capture" && $blue_result != "fail" ) {$blue_result .= " %";}


	if ($coments == "") {$coments="0";}
	if ($coments == "0") {
		$coments="<a title=\"$coments notes\" href=\"/rep/" . $mis_rep . ".html#reports\"><img border=\"0\" src=\"/images/coments_0.gif\" alt=\"$coments notes\"></a>"; }
	else {
		if ($coments =="1" || $coments =="2" ) {	
		$coments="<a title=\"$coments notes\" href=\"/rep/" . $mis_rep . ".html#reports\"><img border=\"0\" src=\"/images/coments_1.gif\" alt=\"$coments notes\"></a>";
}
		else {	
		$coments="<a title=\"$coments notes\" href=\"/rep/" . $mis_rep . ".html#reports\"><img border=\"0\" src=\"/images/coments_3.gif\" alt=\"$coments notes\"></a>";
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

print "</table>\n";
?> 
<br>
<a href="mapa.html">View Front Map</a>
<br> 

<?php 
include ("./dz_page_footer.php");
?>