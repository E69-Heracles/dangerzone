<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br/><br/>
<?php

  	$slot=$_GET['slot'];
	if ($slot != "BW1"   && $slot != "BW2"   && $slot != "BW3"   &&
	    $slot != "BW1RR" && $slot != "BW2RR" && $slot != "BW3RR" &&
            $slot != "BW1BR" && $slot != "BW2BR" && $slot != "BW3BR" &&
	    $slot != "BW4"   && $slot != "BW5"   && $slot != "BW6"   &&			
	    $slot != "BW4RR" && $slot != "BW5RR" && $slot != "BW6RR" &&
            $slot != "BW4BR" && $slot != "BW5BR" && $slot != "BW6BR" ){
	    print "<font color=\"#ff0000\" size=\"+1\"> Error: Invalid Slot</font>";
	    print "<br><br><br><br>";
	    exit;
	}  

	list($hlname, $pwd) = split(' ', $_COOKIE["badc_user"]);

	mysql_connect("localhost", "$db_user","$db_upwd") or die ("Error - Could not connect: " . mysql_error()); 
	mysql_select_db("$database");

        $now_epoch=date("U");

        $query="select status, epoca from badc_host_slots where slot='$slot'";
   	$result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	$row = mysql_fetch_array($result, MYSQL_NUM);
	if ($row[0] != 0 && $row[1]> $now_epoch) { // el slot esta ocupado y no expiro
	    print "<font color=\"#ff0000\" size=\"+1\"> Error: Slot is in use</font>";
	    print "<br><br><br><br>";
	    exit;
	} 

        $ask="";	
	if ( ! ($slot == "BW1" || $slot == "BW2" || $slot == "BW3" || 
		$slot == "BW4" || $slot == "BW5" || $slot == "BW6" )) { // si no es host
	    if ($slot == "BW1RR" || $slot == "BW1BR" ) {
		$ask="BW1";
	    }
	    if ($slot == "BW2RR" || $slot == "BW2BR" ) {
		$ask="BW2";
	    }
	    if ($slot == "BW3RR" || $slot == "BW3BR" ) {
		$ask="BW3";
	    }
	    if ($slot == "BW4RR" || $slot == "BW4BR" ) {
		$ask="BW4";
	    }
	    if ($slot == "BW5RR" || $slot == "BW5BR" ) {
		$ask="BW5";
	    }
	    if ($slot == "BW6RR" || $slot == "BW6BR" ) {
		$ask="BW6";
	    }
            $query="select status, max_human, epoca from badc_host_slots where slot='$ask'";
   	    $result = mysql_query($query) or die ("Error - Query: $query" . mysql_error());
	    $row = mysql_fetch_array($result, MYSQL_NUM);
	    if ($row[0] == 0 || $row[2] < $now_epoch) { // el slot esta libre o expiro
	        print "<font color=\"#ff0000\" size=\"+1\"> Error: Cant set request without host</font>";
	        print "<br><br><br><br>";
	        exit;
	    }
	}

?>


<table ><tr><td>

<?php



	print "<FORM METHOD=\"POST\" ACTION=\"/cgi-bin/take_slot.pl\"> <br>\n";
	print "<table >\n";

	if ($slot == "BW1" || $slot == "BW2" || $slot == "BW3" ||
	    $slot == "BW4" || $slot == "BW5" || $slot == "BW6" ){ // si es host
	    print "
		<tr>
		    <td align=\"right\">
		   	<input type=\"hidden\" name=\"slot\" value=\"$slot\">
			Host Slot: </td>
		    <td><font color=\"#1177cc\"><b>$slot</b></font></td>
		</tr>\n";
	    print "
		<tr>
		    <td align=\"right\">Human Planes :</td>
		    <td> <select name=\"max_human\" size=\"1\">
	               <option value=\"4\">4x4</option>		    
	               <option value=\"6\">6x6</option>
	               <option value=\"8\">8x8</option>
	               <option value=\"10\">10x10</option>
	               <option value=\"12\">12x12</option>
	               <option value=\"14\">14x14</option>
	               <option value=\"16\">16x16</option>
	               <option value=\"18\">18x18</option>
	               </select>
		     </td>
		</tr>\n";
	}
	else {
	    print "
		<tr>
		   <td align=\"right\">
		   	<input type=\"hidden\" name=\"slot\" value=\"$slot\">
			<font color=\"#1177cc\"><b>$slot</b></font>:
		   </td>
		   <td>
			<input type=\"hidden\" name=\"max_human\" value=\"$row[1]\">
			Human Planes <b>$row[1]</b>
		   </td>
		</tr>\n";
	}

	print "<tr><td align=\"right\">Name: </td><td><input type=\"text\" size=\"20\" name=\"hlname\" value=\"$hlname\"></td></tr>\n";
	print "<tr><td align=\"right\">Password : </td><td><input type=\"password\" size=\"20\" name=\"pwd\" value=\"$pwd\"></td></tr>\n";
	print "<tr>&nbsp;<td></td><td> <input TYPE=\"SUBMIT\" VALUE=\"Send\"></td></tr>\n";
	print "</table></form>\n";
?>
</td></tr></table>


<?php 
include ("./dz_page_footer.php");
?>