#!/usr/bin/perl

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();

$|=1; # hot output

# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------

my @red_tgt_used=();
my @blue_tgt_used=();

# Limit upload size
$cgi_lib::maxdata = 512; 
$cgi_lib::maxdata = 512; 

&ReadParse(%in); # Read data

$slot=$in{'slot'};             # <td><input type="hidden" name="slot" value="BW1"> 
$max_human=$in{'max_human'};   # <select name=\"max_human\" O <input type=\"hidden\" name=\"max_human\" value=\"8\">
$hlname=$in{'hlname'};         # <td>Name: <input type="TEXT" name="hlname" size="20" value=""> </td>
$pwd=$in{'pwd'};               # <td>Password: <input type="password" name="pwd" size="20" value=""></td>
$army="0";

if ($max_human > 16) {
    $max_plane = 16;
}
else {
    $max_plane = $max_human;
}

$max_bd = 4;

if ($slot !~ m/BW[123456]([B|R]R)?/) {
		print &PrintHeader;
    print &print_start_html();
    print "<font color=\"red\" size=\"+1\"> Error: Invalid or Unknow Slot. </font><br>\n";
    print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
    print &print_end_html();
    exit(0);
}

my @row;
my $dbh;
my $sth;

# db connect
$dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");

if (! $dbh) { 
		print &PrintHeader;
    print &print_start_html();
    print "Can't connect to DB\n";
    print &print_end_html();
    die "$0: Can't connect to DB\n";
}

#  "clean DB"  for expired request
my $now_epoch=time;
my $half_hour=$now_epoch-1800; # to denny attacks in progress
my @bw_slots = ("BW1","BW2","BW3","BW4","BW5","BW6");

foreach my $look (@bw_slots) {
    $sth = $dbh->prepare("SELECT epoca FROM $host_slots_tbl WHERE slot=?");
    $sth->execute($look);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] < $now_epoch) { # if expired
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=0,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"$look\"");
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=1,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$look."RR\"");
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=2,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$look."BR\"");
    }
}

$hlname=~ s/^ *//g;
$hlname=~ s/ *$//g;

if ($hlname  =~ m/ / || $hlname eq "" ) {
		print &PrintHeader;
    print &print_start_html();
    print "<font color=\"red\" size=\"+1\">ERROR:</font>  Null name. <br>\n";
    
    print &print_end_html();
    exit(0);
}
if ($pwd eq "") {
		print &PrintHeader;
    print &print_start_html();
    print "<font color=\"red\" size=\"+1\">ERROR:</font> Null password.<br>\n";
    
    print &print_end_html();
    exit(0);
}


#verify pwd and if he is member of a squadron
$sth = $dbh->prepare("SELECT password,sqd_army,sqd_accepted, ban_hosting, ban_planing  FROM $pilot_file_tbl WHERE hlname=?");
$sth->execute($hlname);
@row = $sth->fetchrow_array;
$sth->finish;
if ($row[0] ne $pwd) {
		print &PrintHeader;
    print &print_start_html();
    print "<font color=\"red\" size=\"+1\"> Error: Name or password not valid </font><br>\n";
    print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
    print &print_end_html();
    exit(0);
}

if ($row[1] == 0 || $row[2] == 0) {
		print &PrintHeader;
    print &print_start_html();
    print "<font color=\"red\" size=\"+1\"> Error: You have belong to a squadron to host/plan missions.</font><br>\n";
    print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
    
    print &print_end_html();
    exit(0);
}

#set cookie user and pwd
print "Set-Cookie: ";
print "badc_user=". $hlname." ".$pwd."; expires=".$cookie_expire."; path=/\n";
print &PrintHeader;
print &print_start_html();

$ban_hosting=$row[3];
$ban_planing=$row[4];

$army=$row[1];
my $expire=$now_epoch + $expire_seconds; # set expire time

if ($slot =~ m/BW[123456]$/) {  # if he is host (game-host)
    if ($ban_hosting) {
	print "<font color=\"red\" size=\"+1\"> Error: You do not have Hosting rights </font><br>\n";
	print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
	print &print_end_html();
	exit(0);
    }

    my $new_slot="Not Set"; # slot name where to be moved
    if ($max_human<=8 && $slot eq "BW1"){  # is small mission on BW1
	$new_slot="BW2";
	# verify that slot is empty
	$sth = $dbh->prepare("SELECT status, epoca FROM $host_slots_tbl WHERE slot=?");
	$sth->execute($new_slot);
	@row = $sth->fetchrow_array;
	$sth->finish;
	if ( $row[0] == 0 || $row[1]<$now_epoch ) { # si BW2 esta (libre o expiro)
	    $slot=$new_slot;
	}
	else {     
	    $new_slot="BW3";
	    $sth = $dbh->prepare("SELECT status, epoca FROM $host_slots_tbl WHERE slot=?");
	    $sth->execute($new_slot);
	    @row = $sth->fetchrow_array;
	    $sth->finish;
	    if ( $row[0] == 0 || $row[1]<$now_epoch ) { # si BW3 esta (libre o expiro)
		$slot=$new_slot;
	    }
	    else { $new_slot="Not Set";} # BW2 and BW3 both used, not moved
	}
    }
    if ($max_human<=8 && $slot eq "BW4"){  # is small mission on BW4
	$new_slot="BW5";
	# verify that slot is empty
	$sth = $dbh->prepare("SELECT status, epoca FROM $host_slots_tbl WHERE slot=?");
	$sth->execute($new_slot);
	@row = $sth->fetchrow_array;
	$sth->finish;
	if ( $row[0] == 0 || $row[1]<$now_epoch ) { # si BW2 esta (libre o expiro)
	    $slot=$new_slot;
	}
	else {     
	    $new_slot="BW6";
	    $sth = $dbh->prepare("SELECT status, epoca FROM $host_slots_tbl WHERE slot=?");
	    $sth->execute($new_slot);
	    @row = $sth->fetchrow_array;
	    $sth->finish;
	    if ( $row[0] == 0 || $row[1]<$now_epoch ) { # si BW3 esta (libre o expiro)
		$slot=$new_slot;
	    }
	    else { $new_slot="Not Set";} # BW5 and BW6 both used, not moved
	}
    }

    if ($new_slot ne "Not Set"){ # print changed information
	print "<br><br>Your mission is <b> $max_human x $max_human </b> and $new_slot is free.<br>\n";
	print "Please leave BW1 and BW4 slots in HL for bigger missions.\n";
	print "Your request moved to <font color=\"red\" size=\"+1\">  $new_slot </font><br>\n";
    }

    # verify that slot is empty
    $sth = $dbh->prepare("SELECT status, epoca FROM $host_slots_tbl WHERE slot=?");
    $sth->execute($slot);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ( ! ($row[0] == 0 || $row[1]<$now_epoch ) ) { # si NO esta (libre o expiro)
	print "<font color=\"red\" size=\"+1\"> Error: That slot is taken </font><br>\n";
	print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
	print &print_end_html();
	exit(0);
    }

    # check if he is in other host slots (avoid multiple GAME hosting)
    foreach my $look (@bw_slots) {
	if ($look ne $slot) { # if is other slot
	    $sth = $dbh->prepare("SELECT hlname FROM $host_slots_tbl WHERE slot=?");
	    $sth->execute($look);
	    @row = $sth->fetchrow_array;
	    $sth->finish;
	    if ($row[0] eq $hlname) { 
		print "<font color=\"red\" size=\"+1\"> Error: You already hosting in $look </font><br>\n";
		print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
		print &print_end_html();
		exit(0);
	    }
	}
    }
    
    # update DB data 
    $dbh->do("UPDATE $host_slots_tbl SET status = 1, hlname = '$hlname', epoca = $expire, date = '', time = '', max_human = $max_human WHERE slot=\"$slot\"");
    # clean old requests
    $dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=1,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$slot."RR\"");
    $dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=2,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$slot."BR\"");

    print "<font color=\"green\" size=\"+1\"> Host $slot accepted </font><br>\n";

}
if ($slot =~ m/BW[123456][B|R]R$/) { # if he is in a request slot
    if ($ban_planing) {
	print "<font color=\"red\" size=\"+1\"> Error: You do not have Planing rights </font><br>\n";
	print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
	print &print_end_html();
	exit(0);
    }

    # verify empty slot and pilot army
    $sth = $dbh->prepare("SELECT status, army, hlname  FROM $host_slots_tbl WHERE slot=?"); 
    $sth->execute($slot);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ( $hlname ne $row[2] && $row[0] != 0 ) { # if he is not owner and if is not empty
	print "<font color=\"red\" size=\"+1\"> Error: That slot is taken </font><br>\n";
	print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
	print &print_end_html();
	exit(0);
    }
    if ( $hlname ne $super_user && $row[1] != $army) { # if is  NOT in same army (unless is the super_user)
	if ($army==1){
	    print "<font color=\"red\" size=\"+1\"> Error: VVS pilots can not make LW requests</font><br>\n";
	}
	if ($army==2){
	    print "<font color=\"red\" size=\"+1\"> Error: LW pilots can not make VVS requests</font><br>\n";
	}
	print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
	print &print_end_html();
	exit(0);
    }

    # update values (status waiting)
    $dbh->do("UPDATE $host_slots_tbl SET status = 1, hlname = '$hlname', epoca = $expire, date = '', time = '', max_human = $max_human WHERE slot=\"$slot\"");

    #print html head + start of  FORM with correct human planes settings

    # If it is VVS, print VVS head and options
    if ($slot =~ m/BW[123456]RR/) {
	print <<VVS_Head1
<br>

<!-- selectPlanes() is based on Vladimir Geshanov Jscript form elements Select 2D -->
<!-- Visit his Web Site:  http://hotarea.com -->
<!-- Modification: JG10r_Dutertre . Regex test & other specifc customizations. -->

<script type="text/javascript">

var arrayData = new Array(); 

VVS_Head1
    ; # Emacs related

	my $entry=0;
	my $vvs_plane="";
	foreach $vvs_plane (@VVS_SUM_PLANES) {
	    print "arrayData[$entry]	= \'SUM-|$vvs_plane|\'\n";
	    $entry++;
	}
	foreach $vvs_plane (@VVS_BA_PLANES) {
	    print "arrayData[$entry]	= \'aerodromo-|$vvs_plane|\'\n";
	    $entry++;
	}

    print <<VVS_Head2

function selectPlanes( name ) { 

    myString = new String(name)
    if(! myString.match(/----/) &&  // ---- SELECT ...
       ! myString.match(/SUM-/) &&
       ! myString.match(/aerodromo-/) &&
       ! myString.match(/sector-/)) {
            myString = new String("aerodromo-") // es una ciudad, cambiamos a aerodromo que es lo mismo
    }

    select = document.genopts.bomb_attk_type; 
    string= ""; 
    select.options.length = 0;
    if ( myString.match(/sector-/)) {
            select.options[0] = new Option( "Army Tanks");
    }
    else {
        select.options[0] = new Option( "----");
    }
    count=1;

    for( i = 0; i < arrayData.length; i++ ) { 
        string = arrayData[i].split( "|" );
        myRE = new RegExp(string[0])
        if( myString.match(myRE,"i")){
            select.options[count++] = new Option( string[1] ); 
        } 
    } 
  
    if( myString.match(/sector-/) || 
        myString.match(/----/) ){
            document.genopts.bomb_attk_nbr.value=0;
	    document.genopts.bomb_attk_nbr.disabled=1;
	    document.genopts.bomb_attk_ai.checked=1;
	    document.genopts.bomb_attk_ai.disabled=1;
    }
    else if (myString.match(/SUM-/)) {
            document.genopts.bomb_attk_nbr.value="";
	    document.genopts.bomb_attk_nbr.disabled=0;
	    document.genopts.bomb_attk_ai.disabled=0;
	    if ( document.genopts.bomb_attk_ai.checked==1){
	        alert ("Warning: Ai flag for attack group cleared.  ");
		document.genopts.bomb_attk_ai.checked=0;
	    }
    }
    else {
           document.genopts.bomb_attk_nbr.value="";
	   document.genopts.bomb_attk_nbr.disabled=0;
	    document.genopts.bomb_attk_ai.disabled=0;
	    if ( document.genopts.bomb_attk_ai.checked==1){
	        alert ("Warning: Ai flag for attack group cleared.  ");
		document.genopts.bomb_attk_ai.checked=0;
	    }
    }

    // Set which option from subcategory is to be selected and focus
    select.options.selectedIndex = 0; 
    select.focus(); 
} 

function Look_only_AI ( name , select ) { 
//    selec debe rcibir alguno de estos 2:
//    select = document.genopts.bomb_attk_ai; 
//    select = document.genopts.bomb_def_ai; 


    myString = new String(name)
    if( 
VVS_Head2
	; # Emacs related	

	foreach $vvs_plane (@VVS_AI_PLANES) {
	    print "myString.match(/$vvs_plane/) || \n";
	}
	# myString.match(/R-10/) ||

	print <<VVS_Head3

        myString.match(/Army Tanks/) ){
        select.checked=1;
        select.disabled=1;
    }
    else {
        if ( select.disabled==1 && select.checked==1 ){
	    if (select == document.genopts.bomb_attk_ai) {
	        alert ("Warning: Ai flag for attack group cleared.  ");
	    }
	    else {
	        alert ("Warning: Ai flag for defend bombers cleared.  ");
	    }
	    select.checked=0;
        }
        select.disabled=0;
   }

   if (select == document.genopts.bomb_attk_ai) {
       document.genopts.bomb_attk_nbr.value="";
       document.genopts.bomb_attk_nbr.focus();
   }
   else {
       document.genopts.bomb_def_nbr.value="";
       document.genopts.bomb_def_nbr.focus();
   }


}

function setnumbers(BA,BAai,EBA,EBAai,BD,BDai,EBD,EBDai) {

//    if (BA>6 ) { BA=6; document.genopts.bomb_attk_nbr.value=BA; } 
//    if (EBA>8) {EBA=8; document.genopts.fig_attk_nbr.value=EBA; } 
//   if (BD>8 ) { BD=8; document.genopts.bomb_def_nbr.value=BD; } 
//    if (EBD>8) {EBD=8; document.genopts.fig_def_nbr.value=EBD; } 
    if (BA<0 ) { BA=0; document.genopts.bomb_attk_nbr.value=BA; } 
    if (EBA<0) {EBA=0; document.genopts.fig_attk_nbr.value=EBA; } 
    if (BD<0 ) { BD=0; document.genopts.bomb_def_nbr.value=BD; } 
    if (EBD<0) {EBD=0; document.genopts.fig_def_nbr.value=EBD; } 

    total_hum = 0;
    total_ai  = 0;
      if (BAai ==1) {total_ai-=BA;}
      else {total_hum-=BA;}
//      if (BDai ==1) {total_ai-=BD;}
//      else {total_hum-=BD;}
      if (EBAai ==1) {total_ai-=EBA;}
      else {total_hum-=EBA;}
      if (EBDai ==1) {total_ai-=EBD;}
      else {total_hum-=EBD;}

    document.genopts.total_hum.value= -total_hum;
    document.genopts.total_ai.value= -total_ai;
    if ( -total_ai >  document.genopts.max_ai.value) { document.genopts.total_ai.style.background = "#cc0000";}
    else { document.genopts.total_ai.style.background = "#00cc00";}
    if ( -total_hum !=  document.genopts.max_human.value ) { 
        document.genopts.total_hum.style.background = "#cc0000";}
    else { document.genopts.total_hum.style.background = "#00cc00";}
    
    myString = new String(document.genopts.target.value);
    if( myString.match(/SUA-/)) {
        document.genopts.bomb_attk_nbr.value="";
        document.genopts.bomb_attk_nbr.disabled=0;
        document.genopts.bomb_attk_ai.checked=0;                
        document.genopts.bomb_attk_ai.disabled=1;
    }
//    else if( myString.match(/sector-/) || 
//        myString.match(/----/) ){
//            document.genopts.bomb_attk_nbr.value=0;
//	    document.genopts.bomb_attk_nbr.disabled=1;
//	    document.genopts.bomb_attk_ai.checked=1;
//	    document.genopts.bomb_attk_ai.disabled=1;
//    }
    else if (myString.match(/SUM-/)) {
        document.genopts.bomb_attk_nbr.value="";
	document.genopts.bomb_attk_nbr.disabled=0;
	document.genopts.bomb_attk_ai.disabled=0;
    }
    else {
           document.genopts.bomb_attk_nbr.value="";
	   document.genopts.bomb_attk_nbr.disabled=0;
           document.genopts.bomb_attk_ai.disabled=0;
    }    
    
}


function Check(){
    if (document.genopts.max_ai.value < document.genopts.total_ai.value ){
        alert ("Error: too much AI planes.");
        return false;
    }

    if (document.genopts.max_human.value != document.genopts.total_hum.value ){
        alert ("Error: incorrect Human planes.");
        return false;
    }

    myString = new String(document.genopts.target.value);
    if ( document.genopts.bomb_attk_nbr.value == 0){
	if ( ! myString.match(/sector-/) ){
	    alert ("Error: Attack group cant be 0.");
	    return false;
	}
    }
    
    if ( myString.match(/sector-/) ) {
        if ( document.genopts.bomb_attk_nbr.value > 3) {
	    alert ("Error: Los AT no pueden superar 3.");
	    return false;        
        }
    }

    if (document.genopts.total_hum.value < 4 ){
        alert ("Error: Human planes must be 4 at least.");
        return false;
    }

    if (document.genopts.hlname.value == ""){
        alert("Enter your name.");
	return false;
    }
    if (document.genopts.pwd.value == ""){
	alert("Enter your password.");
	return false;
    }

    document.genopts.bomb_attk_nbr.disabled=0;
    document.genopts.bomb_attk_ai.disabled=0;
    document.genopts.bomb_def_nbr.disabled=0;
    document.genopts.bomb_def_ai.disabled=0;
}

</script>

Genera la petición roja para <u><font size="+3"><b>$max_human</b></font></u> pilotos [ CAZAS + BOMBERS ]
<br>



<FORM NAME="genopts" METHOD="POST" ACTION="/cgi-bin/gen_opts_31.pl" onSubmit="return Check()"><br>
<input type="hidden" name="army" value="R">
<input type="hidden" name="max_human" value="$max_human">
<input type="hidden" name="max_ai" value="6">
<input type="hidden" name="slot" value="$slot">


<table border="1" cellspacing="0" cellpadding="0">
  <tr bgcolor="#ccccc0" >
    <td align="right"><b>Objetivo:</b></td>
    <td><select name="target" size="1" style="width:180;" 
        onChange="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                             bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">
        <option value="Select Target">---- SELECT TARGET ----</option>
VVS_Head3
    ; # Emacs related


	$sth = $dbh->prepare("SELECT red_tgt FROM $mis_prog WHERE reported = 0 and epoca > ? and campanya=\"$CAMPANYA\" and mapa=\"$MAP_NAME_LONG\"");
	$sth->execute($half_hour);
	while (@row = $sth->fetchrow_array){
	    push (@red_tgt_used,$row[0]);
	}
	$sth->finish;
	open(OPR,"Options_R.txt");
	while(<OPR>){
	    my $option=$_;
	    my $ok=1;
	    foreach my $used (@red_tgt_used){
		if ($option =~ m/$used/){
		    $ok=0;
		    # print "this tgt is under attack: ".$option."\n";
		    last; # foreach
		}
	    }
	    if ($ok){
		print $option;
	    }
	}
	close(OPR);
	print <<VVS_Head4
	</select> </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>

  <tr bgcolor="#dddddd" >
    <td align="right">Grupo de ataque (<b>BA/SUM/AT</b>) :</td>
    <td align="right">Máximo núm. AT = 3</td>
        <td><select name="bomb_attk_nbr" size="1" style="width:36;"
    onChange="setnumbers(bomb_attk_nbr.options[selectedIndex].value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                       bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">
	<option selected value="0">0</option>
VVS_Head4
    ; # Emacs related
        my $my_max_bomber = 0;                
	if ($max_human <= 4) { $my_max_bomber = 1; }
        if ($max_human > 4 && $max_human <=6) {$my_max_bomber = 3; }
        if ($max_human > 6 && $max_human <=8) {$my_max_bomber = 4; }
        if ($max_human >8) {$my_max_bomber = 6; }        
        for ($my_i = 1; $my_i <= $my_max_bomber; $my_i++){
                print "<option value=\"$my_i\">$my_i</option>";
        }
        print "</select> </td>";
	print <<VVS_Head5
    <td><input type="checkbox" name="bomb_attk_ai"
    onClick="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                        bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">AI</td>
  </tr>
  <tr bgcolor="#dddddd" >
    <td align="right">&nbsp;Cazas de ataque (<b>EBA/ESU/ET</b>) :</td>
    <td align="right">&nbsp;</td>
    <td><select name="fig_attk_nbr" size="1" style="width:36;"
    onChange="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.options[selectedIndex]value,fig_attk_ai.checked,
                       bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">
	<option selected value="0">0</option>
VVS_Head5
    ; # Emacs related
        for ($my_i = 1; $my_i <= $max_plane; $my_i++){
                print "<option value=\"$my_i\">$my_i</option>";
        }
        print "</select> </td>";
	print <<VVS_Head6
    <td><input type="checkbox" disabled name="fig_attk_ai"
    onClick="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                        bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">AI</td>
  </tr>

  <input type="hidden" name="bomb_def_type" value="----">
  <input type="hidden" name="bomb_attk_type" value="----">  

  <tr bgcolor="#cbcbcb">
    <td align="right">Grupo de defensa (<b>BD</b>) :</td>
    <td>&nbsp;</td>
    <td><select name="bomb_def_nbr" size="1" style="width:36;"
    onChange="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                       bomb_def_nbr.options[selectedIndex].value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">
	<option selected value="0">0</option>
VVS_Head6
    ; # Emacs related
        for ($my_i = 1; $my_i <= $max_bd; $my_i++){
                print "<option value=\"$my_i\">$my_i</option>";
        }
        print "</select> </td>";
	print <<VVS_Head7
    <td><input type="checkbox" name="bomb_def_ai"
    onClick="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                        bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">AI</td>
  </tr>

  <tr bgcolor="#cbcbcb">
    <td align="right">Cazas de defensa (<b>INT/EBD</b>) :</td>
    <td>&nbsp;</td>
    <td><select name="fig_def_nbr" size="1" style="width:36;"
    onChange="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                       bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.options[selectedIndex].value,fig_def_ai.checked);">
	<option selected value="0">0</option>
VVS_Head7
    ; # Emacs related
        for ($my_i = 1; $my_i <= $max_plane; $my_i++){
                print "<option value=\"$my_i\">$my_i</option>";
        }
        print "</select> </td>";
	print <<VVS_Head8
    <td><input type="checkbox" disabled name="fig_def_ai"
    onClick="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                        bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">AI</td>
  </tr>


  <tr bgcolor="#ccccc0">
    <td colspan="2" align="center">Total de aviones: &nbsp;&nbsp;&nbsp;&nbsp;  Humanos / IA </td>
    <td><input type="text" disabled name="total_hum" size="2" value=0></td>
    <td><input type="text" disabled name="total_ai" size="2" value=0></td>
  </tr>


</table>
<br>
<table border="1" cellspacing="0" cellpadding="0">
  <tr>
    <td>Nombre: <input type="TEXT" name="hlname" size="20" value="$hlname"> </td>
    <td>Clave: <input type="password" name="pwd" size="20" value="$pwd"></td>
    <td><input TYPE="SUBMIT" VALUE="Send"></td>
  </tr>
</table>
</FORM>

<pre>

</pre>

VVS_Head8
    ; # Emacs related


	print "<table border=\"0\"><col width=\"750\">\n";
	print "<tr><td class=\"post\"><font size=\"+1\" color=\"#880000\"><b>Attacks in progress</b></font> --- Non selectable till reach 30 minutes progress</td></tr>\n";
	print "<tr><td class=\"post\">\n";
	foreach my $used (@red_tgt_used){
	    print "$used<br>\n";
	}
	print "<br>---<br>\n";
	print "</td></tr></table><pre>\n\n\n</pre>\n";

	open(VVSREC,"$CGI_BIN_PATH/tmp/vvsrec.txt");
	while(<VVSREC>){
	    print
	}
	close(VVSREC);

	open(STA,"Status.txt");
	while(<STA>){
	    print
	}
	close(STA);

	open(IMAP,"<$IMAP_DATA");
	while(<IMAP>){
	    print
	}
	close(IMAP);
    }

    # If it is LW, print head and LW options
    if ($slot =~ m/BW[123456]BR/) {
	print <<LW_Head1
<br>

<!-- selectPlanes() is Based on Vladimir Geshanov Jscript form elements Select 2D -->
<!-- Visit his Web Site:  http://hotarea.com -->
<!-- Modification: JG10r_Dutertre . Regex test & other specifc customizations. -->

<script type="text/javascript">

var arrayData = new Array(); 

LW_Head1
    ; # Emacs related

	my $entry=0;
	my $lw_plane="";
	foreach $lw_plane (@LW_SUM_PLANES) {
	    print "arrayData[$entry]	= \'SUM-|$lw_plane|\'\n";
	    $entry++;
	}
	foreach $lw_plane (@LW_BA_PLANES) {
	    print "arrayData[$entry]	= \'aerodromo-|$lw_plane|\'\n";
	    $entry++;
	}

	print <<LW_Head2

function selectPlanes( name ) { 

    myString = new String(name)
    if(! myString.match(/----/) &&  // ---- SELECT ...
       ! myString.match(/SUM-/) &&
       ! myString.match(/aerodromo-/) &&
       ! myString.match(/sector-/)) {
            myString = new String("aerodromo-") // es una ciudad, cambiamos a aerodromo que es lo mismo
    }

    select = document.genopts.bomb_attk_type; 
    string= ""; 
    select.options.length = 0;
    if ( myString.match(/sector-/)) {
            select.options[0] = new Option( "Army Tanks");
    }
    else {
        select.options[0] = new Option( "----");
    }
    count=1;

    for( i = 0; i < arrayData.length; i++ ) { 
        string = arrayData[i].split( "|" );
        myRE = new RegExp(string[0])
        if( myString.match(myRE,"i")){
            select.options[count++] = new Option( string[1] ); 
        } 
    } 
  
    if( myString.match(/sector-/) || 
        myString.match(/----/) ){
            document.genopts.bomb_attk_nbr.value=0;
	    document.genopts.bomb_attk_nbr.disabled=1;
	    document.genopts.bomb_attk_ai.checked=1;
	    document.genopts.bomb_attk_ai.disabled=1;
    }
    else if (myString.match(/SUM-/)) {
            document.genopts.bomb_attk_nbr.value="";
	    document.genopts.bomb_attk_nbr.disabled=0;
	    document.genopts.bomb_attk_ai.disabled=0;
	    if ( document.genopts.bomb_attk_ai.checked==1){
	        alert ("Warning: Ai flag for attack group cleared.  ");
		document.genopts.bomb_attk_ai.checked=0;
	    }            
    }
    else {
           document.genopts.bomb_attk_nbr.value="";
	   document.genopts.bomb_attk_nbr.disabled=0;
           document.genopts.bomb_attk_ai.disabled=0;
	    if ( document.genopts.bomb_attk_ai.checked==1){
	        alert ("Warning: Ai flag for attack group cleared.  ");
		document.genopts.bomb_attk_ai.checked=0;
	    }           
    }

    // Set which option from subcategory is to be selected and focus
    select.options.selectedIndex = 0; 
    select.focus(); 
} 

function Look_only_AI ( name , select ) { 
//    selec debe rcibir alguno de estos 2:
//    select = document.genopts.bomb_attk_ai; 
//    select = document.genopts.bomb_def_ai; 


    myString = new String(name)
    if( 

LW_Head2
	; # Emacs related	

	foreach $lw_plane (@LW_AI_PLANES) {
	    print "myString.match(/$lw_plane/) || \n";
	}
	# myString.match(/JU-88A4/) ||


	print <<LW_Head3

        myString.match(/Army Tanks/) ){
        select.checked=1;
        select.disabled=1;
    }
    else {
        if ( select.disabled==1 && select.checked==1 ){
	    if (select == document.genopts.bomb_attk_ai) {
	        alert ("Warning: Ai flag for attack group cleared.  ");
	    }
	    else {
	        alert ("Warning: Ai flag for defend bombers cleared.  ");
	    }
	    select.checked=0;
        }
        select.disabled=0;
   }

   if (select == document.genopts.bomb_attk_ai) {
       document.genopts.bomb_attk_nbr.value="";
       document.genopts.bomb_attk_nbr.focus();
   }
   else {
       document.genopts.bomb_def_nbr.value="";
       document.genopts.bomb_def_nbr.focus();
   }


}

function setnumbers(BA,BAai,EBA,EBAai,BD,BDai,EBD,EBDai) {

//    if (BA>6 ) { BA=6; document.genopts.bomb_attk_nbr.value=BA; } 
//    if (EBA>8) {EBA=8; document.genopts.fig_attk_nbr.value=EBA; } 
//    if (BD>8 ) { BD=8; document.genopts.bomb_def_nbr.value=BD; } 
//    if (EBD>8) {EBD=8; document.genopts.fig_def_nbr.value=EBD; } 
    if (BA<0 ) { BA=0; document.genopts.bomb_attk_nbr.value=BA; } 
    if (EBA<0) {EBA=0; document.genopts.fig_attk_nbr.value=EBA; } 
    if (BD<0 ) { BD=0; document.genopts.bomb_def_nbr.value=BD; } 
    if (EBD<0) {EBD=0; document.genopts.fig_def_nbr.value=EBD; } 

    total_hum = 0;
    total_ai  = 0;
      if (BAai ==1) {total_ai-=BA;}
      else {total_hum-=BA;}
//      if (BDai ==1) {total_ai-=BD;}
//      else {total_hum-=BD;}
      if (EBAai ==1) {total_ai-=EBA;}
      else {total_hum-=EBA;}
      if (EBDai ==1) {total_ai-=EBD;}
      else {total_hum-=EBD;}

    document.genopts.total_hum.value= -total_hum;
    document.genopts.total_ai.value= -total_ai;
    if ( -total_ai >  document.genopts.max_ai.value) { document.genopts.total_ai.style.background = "#cc0000";}
    else { document.genopts.total_ai.style.background = "#00cc00";}
    if ( -total_hum !=  document.genopts.max_human.value ) { 
        document.genopts.total_hum.style.background = "#cc0000";}
    else { document.genopts.total_hum.style.background = "#00cc00";}
    
    myString = new String(document.genopts.target.value);
    if( myString.match(/SUA-/)) {
        document.genopts.bomb_attk_nbr.value="";
        document.genopts.bomb_attk_nbr.disabled=0;
        document.genopts.bomb_attk_ai.checked=0;        
        document.genopts.bomb_attk_ai.disabled=1;
    }
//    else if( myString.match(/sector-/) || 
//        myString.match(/----/) ){
//            document.genopts.bomb_attk_nbr.value=0;
//	    document.genopts.bomb_attk_nbr.disabled=1;
//	    document.genopts.bomb_attk_ai.checked=1;
//	    document.genopts.bomb_attk_ai.disabled=1;
//    }
    else if (myString.match(/SUM-/)) {
        document.genopts.bomb_attk_nbr.value="";
	document.genopts.bomb_attk_nbr.disabled=0;
	document.genopts.bomb_attk_ai.disabled=0;
    }
    else {
        document.genopts.bomb_attk_nbr.value="";
	document.genopts.bomb_attk_nbr.disabled=0;
        document.genopts.bomb_attk_ai.disabled=0;

    }    
}

function Check(){
    if (document.genopts.max_ai.value < document.genopts.total_ai.value ){
        alert ("Error: too much AI planes.");
        return false;
    }

    if (document.genopts.max_human.value != document.genopts.total_hum.value ){
        alert ("Error: incorrect Human planes.");
        return false;
    }

    myString = new String(document.genopts.target.value);
    if ( document.genopts.bomb_attk_nbr.value == 0){
	if ( ! myString.match(/sector-/) ){
	    alert ("Error: Attack group cant be 0.");
	    return false;
	}
    }
    
    if ( myString.match(/sector-/) ) {
        if ( document.genopts.bomb_attk_nbr.value > 3) {
	    alert ("Error: Los AT no pueden superar 3.");
	    return false;        
        }
    }

    if (document.genopts.total_hum.value < 4 ){
        alert ("Error: Human planes must be 4 at least.");
        return false;
    }

    if (document.genopts.hlname.value == ""){
        alert("Enter your name.");
	return false;
    }
    if (document.genopts.pwd.value == ""){
	alert("Enter your password.");
	return false;
    }

    document.genopts.bomb_attk_nbr.disabled=0;
    document.genopts.bomb_attk_ai.disabled=0;
    document.genopts.bomb_def_nbr.disabled=0;
    document.genopts.bomb_def_ai.disabled=0;

}

</script>

Genera la petición azul para <u><font size="+3"><b>$max_human</b></font></u> pilotos [ CAZAS + BOMBERS ]
<br>



<FORM NAME="genopts" METHOD="POST" ACTION="/cgi-bin/gen_opts_31.pl" onSubmit="return Check()"><br>
<input type="hidden" name="army" value="B">
<input type="hidden" name="max_human" value="$max_human">
<input type="hidden" name="max_ai" value="6">
<input type="hidden" name="slot" value="$slot">


<table border="1" cellspacing="0" cellpadding="0">
  <tr bgcolor="#ccccc0" >
    <td align="right"><b>Objetivo:</b></td>
    <td><select name="target" size="1" style="width:180;" 
        onChange="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                             bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">
        <option value="Select Target">---- SELECT TARGET ----</option>
LW_Head3
    ; # Emacs related

	$sth = $dbh->prepare("SELECT blue_tgt FROM $mis_prog WHERE reported = 0 and epoca > ? and campanya=\"$CAMPANYA\" and mapa=\"$MAP_NAME_LONG\"");
	$sth->execute($half_hour);
	while (@row = $sth->fetchrow_array){
	    push (@blue_tgt_used,$row[0]);
	}
	$sth->finish;
	
	open(OPB,"Options_B.txt");
	while(<OPB>){
	    my $option=$_;
	    my $ok=1;
	    foreach my $used (@blue_tgt_used){
		if ($option =~ m/$used/){
		    $ok=0;
		    # print "this tgt is under attack: ".$option."\n";
		    last; # foreach
		}
	    }
	    if ($ok){
		print $option."\n";
	    }
	}
	close(OPB);

	print <<LW_Head4
	</select> </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>

  <tr bgcolor="#dddddd" >
    <td align="right">Grupo de ataque (<b>BA/SUM/AT</b>) :</td>
    <td align="right">Máximo núm. AT = 3</td>
        
        <td><select name="bomb_attk_nbr" size="1" style="width:36;"
    onChange="setnumbers(bomb_attk_nbr.options[selectedIndex].value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                       bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">
	<option selected value="0">0</option>
LW_Head4
    ; # Emacs related
        my $my_max_bomber = 0;                
	if ($max_human <= 4) { $my_max_bomber = 1; }
        if ($max_human > 4 && $max_human <=6) {$my_max_bomber = 3; }
        if ($max_human > 6 && $max_human <=8) {$my_max_bomber = 4; }
        if ($max_human >8) {$my_max_bomber = 6; }        
        for ($my_i = 1; $my_i <= $my_max_bomber; $my_i++){
                print "<option value=\"$my_i\">$my_i</option>";
        }
        print "</select> </td>";
	print <<LW_Head5                        
    <td><input type="checkbox" name="bomb_attk_ai"
    onClick="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                        bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">AI</td>
  </tr>
  <tr bgcolor="#dddddd" >
    <td align="right">&nbsp;Cazas escoltando grupo de ataque (<b>EBA/ESU/ET</b>) :</td>
    <td align="right">&nbsp;</td>
    <td><select name="fig_attk_nbr" size="1" style="width:36;"
    onChange="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.options[selectedIndex]value,fig_attk_ai.checked,
                       bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">
	<option selected value="0">0</option>
LW_Head5
    ; # Emacs related
        for ($my_i = 1; $my_i <= $max_plane; $my_i++){
                print "<option value=\"$my_i\">$my_i</option>";
        }
        print "</select> </td>";
	print <<LW_Head6
    <td><input type="checkbox" disabled name="fig_attk_ai"
    onClick="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                        bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">AI</td>
  </tr>

  <input type="hidden" name="bomb_def_type" value="----">
  <input type="hidden" name="bomb_attk_type" value="----">  

  <tr bgcolor="#cbcbcb">
    <td align="right">Grupo de defensa (<b>BD</b>) :</td>
    <td>&nbsp;</td>
    <td><select name="bomb_def_nbr" size="1" style="width:36;"
    onChange="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                       bomb_def_nbr.options[selectedIndex].value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">
	<option selected value="0">0</option>
LW_Head6
    ; # Emacs related
        for ($my_i = 1; $my_i <= $max_bd; $my_i++){
                print "<option value=\"$my_i\">$my_i</option>";
        }
        print "</select> </td>";
	print <<LW_Head7
    <td><input type="checkbox" name="bomb_def_ai"
    onClick="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                        bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">AI</td>
  </tr>

  <tr bgcolor="#cbcbcb">
    <td align="right">Cazas de defensa (<b>INT/EBD</b>) :</td>
    <td>&nbsp;</td>
    <td><select name="fig_def_nbr" size="1" style="width:36;"
    onChange="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                       bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.options[selectedIndex].value,fig_def_ai.checked);">
	<option selected value="0">0</option>
LW_Head7
    ; # Emacs related
        for ($my_i = 1; $my_i <= $max_plane; $my_i++){
                print "<option value=\"$my_i\">$my_i</option>";
        }
        print "</select> </td>";
	print <<LW_Head8
    <td><input type="checkbox" disabled name="fig_def_ai"
    onClick="setnumbers(bomb_attk_nbr.value,bomb_attk_ai.checked,fig_attk_nbr.value,fig_attk_ai.checked,
                        bomb_def_nbr.value ,bomb_def_ai.checked ,fig_def_nbr.value,fig_def_ai.checked);">AI</td>
  </tr>


  <tr bgcolor="#ccccc0">
    <td colspan="2" align="center">Total de aviones: &nbsp;&nbsp;&nbsp;&nbsp;  Humanos / IA </td>
    <td><input type="text" disabled name="total_hum" size="2" value=0></td>
    <td><input type="text" disabled name="total_ai" size="2" value=0></td>
  </tr>


</table>
<br>
<table border="1" cellspacing="0" cellpadding="0">
  <tr>
    <td>Nombre: <input type="TEXT" name="hlname" size="20" value="$hlname"> </td>
    <td>Clave: <input type="password" name="pwd" size="20" value="$pwd"></td>
    <td><input TYPE="SUBMIT" VALUE="Send"></td>
  </tr>
</table>
</FORM>

<pre>

</pre>

LW_Head8
    ; # Emacs related


	print "<table border=\"0\"><col width=\"750\">\n";
	print "<tr><td class=\"post\"><font size=\"+1\" color=\"#880000\"><b>Attacks in progress</b></font> --- Non selectable till reach 30 minutes progress</td></tr>\n";

	print "<tr><td class=\"post\">\n";
	foreach my $used (@blue_tgt_used){
	    print "$used<br>\n";
	}
	print "<br>---<br>\n";
	print "</td></tr></table><pre>\n\n\n</pre>\n";


	open(LWREC,"$CGI_BIN_PATH/tmp/lwrec.txt");
	while(<LWREC>){
	    print
	}
	close(LWREC);


	open(STA,"Status.txt");
	while(<STA>){
	    print
	}
	close(STA);

	open(IMAP,"<$IMAP_DATA");
	while(<IMAP>){
	    print
	}
	close(IMAP);
    }
}

print "<br><br><a href=\"/create.php\">Return to Generation page</a><br>\n";
print &print_end_html();
exit(0);


# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;

$pilot_file_tbl=$pilot_file_tbl;
$expire_seconds=$expire_seconds;
$super_user=$super_user;
$cookie_expire=$cookie_expire;

@VVS_SUM_PLANES=@VVS_SUM_PLANES;
@VVS_BA_PLANES=@VVS_BA_PLANES;
@VVS_AI_PLANES=@VVS_AI_PLANES;
@LW_SUM_PLANES=@LW_SUM_PLANES;
@LW_BA_PLANES=@LW_BA_PLANES;
@LW_AI_PLANES=@LW_AI_PLANES;

