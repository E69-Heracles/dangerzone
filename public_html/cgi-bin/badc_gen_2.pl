#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use IO::Handle;   # because autoflush
use DBI();
$|=1; # hot output

# db stuff global declaration
@row=();
$dbh="";
$sth="";

#function declartion and prototypes 
sub sum_array(@);
sub dec_2_hex($);
sub enc_unicode($);
sub distance ($$$$);
sub aviable_af(); 
sub check_targets_places();
sub set_attacks_types();
sub get_sqdname($);
sub get_flight($$$$);
sub build_grplsts(); 
sub find_close_obj_area($$);
sub get_mission_nbr();
sub print_header();
sub print_grplst();
sub no_enemy_af_close($$$);
sub fighters_wp($$$$);
sub bombers_wp ($$$$);
sub add_test_runways();
sub obj_id_airfields();
sub poblate_airfield($);
sub find_tank_wp($$$);
sub add_tanks();
sub add_tank_static();
sub add_tank_biulding();
sub calc_aaa_city(@);
sub poblate_city($$$$); 
sub static_on_city();
sub static_aaa_on_sum_city();
sub static_on_afields();
sub print_briefing();
sub print_fm();
sub select_random_tagets();
sub print_details();
sub printdebug($);


sub printdebug($) {
    my $log = shift (@_);
    if ($DZDEBUG) {
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " " . $log . "\n";	
    }
}

## @Heracles@20110101@
## Calcula el sumatorio de los valores de un array.
## Parametro: @array
sub sum_array(@) {
    my $count = 0;
    
    foreach (@_) {
	$count += $_;
    }
    
    return $count;
}

#enter decimal ascii value (0~255) retun 2 digit  hex
sub dec_2_hex($){
    my @hexdigit=("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F");
    my $dec=shift @_;
    my $left  = $hexdigit[$dec >>4];
    my $right = $hexdigit[$dec & 0xF];
    return($left.$right);
}

# encode text as used on FB representation, some kind of unicode
sub enc_unicode($){
    my $text = shift @_;
    if ($unix_cgi){
	my @data=(split(//,$text));
	@data=map(dec_2_hex(ord),@data);
	$data[0]="\\u00".$data[0];
	$text= join("\\u00",@data);
	$text =~ s/\\u005C\\u006E/\\n/g;
    }
    return($text);
}

# distance
sub distance ($$$$) {
    my ($x1,$y1,$x2,$y2)=@_;
    return (sqrt(($x1-$x2)**2+($y1-$y2)**2));
}

# cheks if there is at least one airfield operative for each army.
# return 1 if both army has at least one operative AF
sub aviable_af(){
    seek GEO_OBJ, 0, 0;
    my $red=0;
    my $blue=0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^AF[0-9]{2},[^,]+,[^,]+,[^,]+,.*,([^,]+):([12])/){ # any airfield of any army
	    if ($1 <80 && $2==1) {$red++;} 
	    if ($1 <80 && $2==2) {$blue++;} 
	    if ($red && $blue){last;} 
	}
    }
    if ($red==0)  { 
	print "$big_red Error: </font> Can't find a operative airfield for red army.<br>\n";
	print "$big_red Germans WON?<br>\n";
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " Can't find a operative airfield for red army.\n";
	return(0);
    }
    if ($blue==0) { 
	print "$big_red Error: </font> Can't find a operative airfield for blue army.<br>\n";
	print "$big_red Soviets WON?<br>\n";
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " Can't find a operative airfield for blue army.\n";
	return(0);
    }
    return(1);
}


# checks that targets are on enemy side, exept SUM mission 
# at same time we determine target corrdinates
sub check_targets_places() {
    my $red_ok=0;
    my $blue_ok=0;
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^([^,]+),$red_target,([^,]+),([^,]+),.*:([0-3])/){
	    if ( ($4==2 && !$RED_SUM) || ($4==1 && $RED_SUM)) {
		$red_ok=1;
		$red_tgt_code=$1;
		$red_tgtcx=$2;
		$red_tgtcy=$3;
	    }
	    else {
		if ($4==3) {
		    print " Red attack place is on an unatacable zone<br>\n";
		    unlink $gen_lock;
		    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: Red attack place is on an unatacable zone\n\n";
		    exit(0);

		}
		if ($4==1 && !$RED_SUM) {
		    print " Red attack place can't be on friendly zone\n";
		    unlink $gen_lock;
		    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Red attack place can't be on friendly zone\n\n";
		    exit(0);
		}
		if ($4==0) {
		    print " Red attack place is on UNKNOW zone\n";
		    unlink $gen_lock;
		    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Red attack place is on UNKNOW zone\n\n";
		    exit(0);

		}
		if ($RED_SUM && $4 !=1) {
		    print " Red must suply friend zone\n";
		    unlink $gen_lock;
		    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Red must suply friend zone\n\n";
		    exit(0);
		}
	    }
	}
	if ($_ =~ m/^([^,]+),$blue_target,([^,]+),([^,]+),.*:([0-3])/) {
	    if ( ($4==1 && !$BLUE_SUM) || ($4==2 && $BLUE_SUM)) {
		$blue_ok=1;
		$blue_tgt_code=$1;
		$blue_tgtcx=$2;
		$blue_tgtcy=$3;
	    }
	    else {
		if ($4==3) {
		    print " Blue attack place is on an unatacable zone\n";
		    unlink $gen_lock;
		    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Blue attack place is on an unatacable zone\n\n";
		    exit(0);
		}
		if ($4==2 && !$BLUE_SUM) {
		    print " Blue attack place can't be on friendly zone\n";
		    unlink $gen_lock;
		    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: Blue attack place can't be on friendly zone\n\n";
		    exit(0);
		}
		if ($4==0) {
		    print " Blue attack place is on UNKNOW zone\n";
		    unlink $gen_lock;
		    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Blue attack place is on UNKNOW zone\n\n";
		    exit(0);
		}
		if ($BLUE_SUM && $4 !=2) {
		    print " Blue must suply friend zone\n";
		    unlink $gen_lock;
		    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Blue must suply friend zone\n\n";
		    exit(0);
		}
	    }
	}
	if ($red_ok && $blue_ok){ # Now, we have to look if attack place is a city, if yes, select a close zone to city
	    my $i=0;
	    if ($red_tgt_code =~ m/^CT[0-9]{2}/) {
		seek GEO_OBJ, 0, 0;
		while(<GEO_OBJ>) { #INT-NAME,EXT-NEM,cx,cy,reserv,tipo,zonas,dam,radsup:0
		    if ($_ =~ m/^$red_tgt_code,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),/){
			my $j=int(rand($1))+1;
			for ($i=0; $i<$j; $i++) {
			    $_=readline(GEO_OBJ);
			}
			$_ =~ m/^[^:]+:([^,]+),([^,]+),/;
			$red_tgtcx=$1;
			$red_tgtcy=$2;
			last;
		    }
		}
	    }
	    if ($blue_tgt_code =~ m/^CT[0-9]{2}/) {
		seek GEO_OBJ, 0, 0;
		while(<GEO_OBJ>) { #INT-NAME,EXT-NEM,cx,cy,reserv,tipo,zonas,dam,radsup:0
		    if ($_ =~ m/^$blue_tgt_code,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),/){
			my $j=int(rand($1))+1;
			for ($i=0; $i<$j; $i++) {
			    $_=readline(GEO_OBJ);
			}
			$_ =~ m/^[^:]+:([^,]+),([^,]+)/; 
			$blue_tgtcx=$1;
			$blue_tgtcy=$2;
			last;
		    }
		}
	    }
	    last;
	}
    }
    if ($red_ok==0) { 
	print " $big_red Error: </font>  Red target not found - cmd line, or data files error\n";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Red target not found - cmd line, or data files error\n\n";
	exit(0);
    }
    if ($blue_ok==0) { 
	print "$big_red Error: </font> Blue target not found - cmd line, or data files error\n";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Blue target not found - cmd line, or data files error\n\n";
	exit(0);
    }
}


#determine types of attack and set type of bombing (BA, BD)
sub set_attacks_types() {
    my $dist;
    my $near;
    if ($red_target =~ m/^sector-.*/) { # if it is a sector
	$near=500000; # big distance to start (500 km)
	seek FRONT,0,0;
	while(<FRONT>) {
	    if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) 1/){ # seach for close front marquer friendly 
		$dist= distance($red_tgtcx,$red_tgtcy,$1,$2);
		if ($dist < $near) {
		    $near=$dist;
		    if ($dist<10000) {last;}
		}
	    }
	}
	if ($near<17000) { # only if distance( enemy sector,close friend front marker) is less than 17 km is tactic.
	    $RED_ATTK_TACTIC=1;
	    $red_bomb_attk=0;
	    $blue_bomb_defend=1;
	}
	else { # maybe a problem on templates
	    $RED_ATTK_TACTIC=0;
	    $red_bomb_attk=1;
	    $blue_bomb_defend=0;
	    print "$big_red Error: </font> Red request Tactical sector, but not in range of <17km!:".($dist/1000)."\n"; 
	    unlink $gen_lock;
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Red request Tactical sector, but not in range of <17km!:".($near/1000)."\n\n"; 
	    exit(0);
	}
    }
    if ($RED_SUM) { # if it is a suply...
	$RED_ATTK_TACTIC=0;
	$red_bomb_attk=1;
	$blue_bomb_defend=0;
	if ($red_bom_attk_planes ==0) {
	    print "$big_red Error: </font>  Red request Suply but suply planes == 0 \n";
	    unlink $gen_lock;
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Red request Suply but suply planes == 0 \n\n";
	    exit(0);
	}
    }
    if (!$RED_SUM && !$RED_ATTK_TACTIC) { # if target is a city or airfield
	$RED_ATTK_TACTIC=0;
	$RED_SUM=0;
	$red_bomb_attk=1;
	$blue_bomb_defend=0;
	if ($red_bom_attk_planes ==0) {
	    print "$big_red Error: </font>  Red request strategic attack  but bomber planes == 0 \n";
	    unlink $gen_lock;
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Red request strategic attack  but bomber planes == 0 \n\n";
	    exit(0);
	}
    }

    # now all the same, but for blue
    if ($blue_target =~ m/^sector-.*/) { # is a sector? 
	$near=500000; # big distance to start (500 km)
	seek FRONT,0,0;
	while(<FRONT>) {
	    if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) 2/){
		$dist= distance($blue_tgtcx,$blue_tgtcy,$1,$2);
		if ($dist < $near) {
		    $near=$dist;
		    if ($dist<10000) {last;}
		}
	    }
	}
	if ($near<17000) {
	    $BLUE_ATTK_TACTIC=1;
	    $blue_bomb_attk=0;
	    $red_bomb_defend=1;
	}
	else {
	    $BLUE_ATTK_TACTIC=0;
	    $blue_bomb_attk=1;
	    $red_bomb_defend=0;
	    print "ERROR: Blue request Tactical sector, but not in range of <17km!:".($near/1000)."\n";
	    unlink $gen_lock;
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Blue request Tactical sector, but not in range of <17km!:".($near/1000)."\n\n";
	    exit(0);
	}
    }
    if ($BLUE_SUM) { # if it is a suply
	$BLUE_ATTK_TACTIC=0;
	$blue_bomb_attk=1;
	$red_bomb_defend=0;
	if ($blue_bom_attk_planes ==0) {
	    print "$big_red Error: </font>  Blue request suply  but suply planes == 0 \n";
	    unlink $gen_lock;
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Blue request suply  but suply planes == 0\n\n";
	    exit(0);
	}
    }
    if ( !$BLUE_SUM && !$BLUE_ATTK_TACTIC ){ # target is a city or an airfield
	$BLUE_ATTK_TACTIC=0;
	$BLUE_SUM=0;
	$blue_bomb_attk=1;
	$red_bomb_defend=0;
	if ($blue_bom_attk_planes ==0) {
	    print "$big_red Error: </font>  Blue request strategic attack but bomber planes == 0 \n";
	    unlink $gen_lock;
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Blue request strategic attack but bomber planes == 0\n\n";
	    exit(0);
	}
    }
}

#this return a squad name. for example, request "gerfig" and return can be "III_JG27"
# request a sqadn name for sviet bomber "rusbom" and return can be "34BAP"
# names of squadrons are in XX_aircraft.data, so is possible to have diferent names for each map
sub get_sqdname($){
    my $request= shift @_;
    my $sqdname="SQDNAME_NOT_SET";

   # later update to include hungarian, finish, italian, etc..
    my @rusfig=();
    my @rusbom=();
    my @rusjab=();
    my @rustrp=();
    my @romfig=();
    my @rombom=();
    my @romjab=();
    my @gerfig=();
    my @gerbom=();
    my @gerjab=();
    my @gertrp=();
    my @hunfig=();
    my @hunbom=();
    my @hunjab=();
    my @usafig=();
    my @usabom=();
    my @usajab=();
    my @usatrp=();
    my @brifig=();
    my @bribom=();
    my @brijab=();
    my @britrp=();


    seek FLIGHTS,0,0;
    while (<FLIGHTS>){
	if ($_ =~ m/^rusfig=(.*);/) {
	    push (@rusfig ,(split /,/,$1));
	}
	if ($_ =~ m/^rusjab=(.*);/) {
	    push (@rusjab ,(split /,/,$1));
	}
	if ($_ =~ m/^rusbom=(.*);/) {
	    push (@rusbom ,(split /,/,$1));
	}
	if ($_ =~ m/^rustrp=(.*);/) {
	    push (@rustrp ,(split /,/,$1));
	}
	if ($_ =~ m/^romfig=(.*);/) {
	    push (@romfig ,(split /,/,$1));
	}
	if ($_ =~ m/^romjab=(.*);/) {
	    push (@romjab ,(split /,/,$1));
	}
	if ($_ =~ m/^rombom=(.*);/) {
	    push (@rombom ,(split /,/,$1));
	}
	if ($_ =~ m/^gerfig=(.*);/) {
	    push (@gerfig ,(split /,/,$1));
	}
	if ($_ =~ m/^gerjab=(.*);/) {
	    push (@gerjab ,(split /,/,$1));
	}
	if ($_ =~ m/^gerbom=(.*);/) {
	    push (@gerbom ,(split /,/,$1));
	}
	if ($_ =~ m/^gertrp=(.*);/) {
	    push (@gertrp ,(split /,/,$1));
	}
	if ($_ =~ m/^hunfig=(.*);/) {
	    push (@hunfig ,(split /,/,$1));
	}
	if ($_ =~ m/^hunjab=(.*);/) {
	    push (@hunjab ,(split /,/,$1));
	}
	if ($_ =~ m/^hunbom=(.*);/) {
	    push (@hunbom ,(split /,/,$1));
	}
	if ($_ =~ m/^usafig=(.*);/) {
	    push (@usafig ,(split /,/,$1));
	}
	if ($_ =~ m/^usajab=(.*);/) {
	    push (@usajab ,(split /,/,$1));
	}
	if ($_ =~ m/^usabom=(.*);/) {
	    push (@usabom ,(split /,/,$1));
	}
	if ($_ =~ m/^usatrp=(.*);/) {
	    push (@usatrp ,(split /,/,$1));
	}
	if ($_ =~ m/^brifig=(.*);/) {
	    push (@brifig ,(split /,/,$1));
	}
	if ($_ =~ m/^brijab=(.*);/) {
	    push (@brijab ,(split /,/,$1));
	}
	if ($_ =~ m/^bribom=(.*);/) {
	    push (@bribom ,(split /,/,$1));
	}
	if ($_ =~ m/^britrp=(.*);/) {
	    push (@britrp ,(split /,/,$1));
	}
    }
    #rus
    if ($request eq "rusfig") {
	$sqdname= $rusfig[(int(rand(scalar(@rusfig))))];
	return($sqdname);
    }
    if ($request eq "rusjab") {
	$sqdname= $rusjab[(int(rand(scalar(@rusjab))))];
	return($sqdname);
    }
    if ($request eq "rusbom") {
	$sqdname= $rusbom[(int(rand(scalar(@rusbom))))];
	return($sqdname);
    }
    if ($request eq "rustrp") {
	$sqdname= $rustrp[(int(rand(scalar(@rustrp))))];
	return($sqdname);
    }
    #ger
    if ($request eq "gerfig") {
	$sqdname= $gerfig[(int(rand(scalar(@gerfig))))];
	return($sqdname);
    }
    if ($request eq "gerjab") {
	$sqdname= $gerjab[(int(rand(scalar(@gerjab))))];
	return($sqdname);
    }
    if ($request eq "gerbom") {
	$sqdname= $gerbom[(int(rand(scalar(@gerbom))))];
	return($sqdname);
    }
    if ($request eq "gertrp") {
	$sqdname= $gertrp[(int(rand(scalar(@gertrp))))];
	return($sqdname);
    }
    #rom
    if ($request eq "romfig") {
	$sqdname= $romfig[(int(rand(scalar(@romfig))))];
	return($sqdname);
    }
    if ($request eq "romjab") {
	$sqdname= $romjab[(int(rand(scalar(@romjab))))];
	return($sqdname);
    }
    if ($request eq "rombom") {
	$sqdname= $rombom[(int(rand(scalar(@rombom))))];
	return($sqdname);
    }
    #hun
    if ($request eq "hunfig") {
	$sqdname= $hunfig[(int(rand(scalar(@hunfig))))];
	return($sqdname);
    }
    if ($request eq "hunjab") {
	$sqdname= $hunjab[(int(rand(scalar(@hunjab))))];
	return($sqdname);
    }
    if ($request eq "hunbom") {
	$sqdname= $hunbom[(int(rand(scalar(@hunbom))))];
	return($sqdname);
    }
    #usa
    if ($request eq "usafig") {
	$sqdname= $usafig[(int(rand(scalar(@usafig))))];
	return($sqdname);
    }
    if ($request eq "usajab") {
	$sqdname= $usajab[(int(rand(scalar(@usajab))))];
	return($sqdname);
    }
    if ($request eq "usabom") {
	$sqdname= $usabom[(int(rand(scalar(@usabom))))];
	return($sqdname);
    }
    if ($request eq "usatrp") {
	$sqdname= $usatrp[(int(rand(scalar(@usatrp))))];
	return($sqdname);
    }
    #bri
    if ($request eq "brifig") {
	$sqdname= $brifig[(int(rand(scalar(@brifig))))];
	return($sqdname);
    }
    if ($request eq "brijab") {
	$sqdname= $brijab[(int(rand(scalar(@brijab))))];
	return($sqdname);
    }
    if ($request eq "bribom") {
	$sqdname= $bribom[(int(rand(scalar(@bribom))))];
	return($sqdname);
    }
    if ($request eq "britrp") {
	$sqdname= $britrp[(int(rand(scalar(@britrp))))];
	return($sqdname);
    }
}

# returns a list with all definitions for a flight. First makes a matr4ix with all possible
# planes for a TASK and its weight by number. Then if there are more tna one option it selects
# a random one using this weights. If a plane type is speicfied, usually the matrix has only one
# entry (unique task/plane combination). If plane type is not spcified, all for that task is watched.
# lines are read from XX_aircraft.data file and lines are for example.

# FLYGHTS_DATA: 
#      army,army+task,external_name,human_flyable,class.air    ,def_weapons,def_fuel,def_alt,def_speed:tasks,
# EJ :    1,   rusjab,   chaika-m62,            1,air.I_153_M62,2xFAB100   ,     100,   1000,      350:   BD,
# PUSH to fly_matrix: external_name($1),class.air($4),weapons($5),fuel($6),alt($7),speed($8),aviones iniciale, army+task($1), aviones que quedan, numero de veces que ha aparecido en misiones

sub get_flight($$$$) {
    my ($army,$task,$human,$plane)= @_;
    my @fly_matrix=(); 
    my $index=0;
    if ($plane eq "")   {$plane ="[^,]+";}  # no specific plane requested, so we match all
#    if ($task eq "ESU") {$task="EBA";}

    my $plane_total=0; # numero total actual de aviones para el tipo de mision que buscamos
    my $plane_total_ini=0; # numero total inicial (en el inicio de la campana) de aviones para el tipo de mision que buscamos
    my $inv_army = ($army == 1) ? "IR" : "IA";
    my $mission_times = $extend; # numero total de misiones
    $mission_times =~ m/_([0-9])+/;
    $mission_times = $1;
    $mission_times = ($mission_times == 0) ? 1 : $mission_times;
    
    my $human_type = ($human == 0) ? "humanos" : "IA";
    printdebug ("get_flight(): Buscando aviones de bando $army para $task para " . $human_type . "\n");
    printdebug ("get_flight(): Numero de misiones $extend $mission_times \n");
    seek FLIGHTS,0,0;
    while (<FLIGHTS>){  #    $1      $2      $3      $4      $5      $6      $7     $8
	if ($_ =~ m/^$army,([^,]+),($plane),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+):$task,/){
	    if ($human == 0 || ($human==1 && $3 ==1 )) { # if  human==0  OR  (human==1 AND plane is human flyable)
		
		## @Heracles@20110708
		## Nuevo sistema de inventario de aviones
		my $planenum = 0;
		my $planereal = 0;
		my $planetimes = 0;
		my $my_army_task = $1;
		my $my_plane = $2;
		my $my_class_air = $4;
		my $my_weapons = $5;
		my $my_fuel = $6;
		my $my_altitude = $7;
		my $my_speed = $8;
		
		my $line_back = tell FLIGHTS;
		
		seek FLIGHTS, 0, 0;
		while (<FLIGHTS>) {
		    if ($_ =~ m/^$inv_army,$my_plane,([^,]+),([^,]+),([^,]+),/){
			$planenum = $1;
			$planereal = $2;
			$planetimes = $3;
		    }
		}

		if ($planenum == 0) { # avion no encontrado en inventario 
		    print "$big_red Error: </font>  No se encuentra el avión \"$my_plane\" en el inventario para el bando: $inv_army \n";
		    unlink $gen_lock;
		    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: No se encuentra el avión \"$my_plane\" en el inventario para el bando: $inv_army \n";
		    exit(0);
		}	
		 
		seek FLIGHTS, $line_back, 0;
		## @Heracles@20110708
		## Fin nuevo sistema de inventario de aviones
		
		push (@fly_matrix,[$my_plane,$my_class_air,$my_weapons,$my_fuel,$my_altitude,$my_speed,$planenum,$my_army_task,$planereal,$planetimes]); 
		$plane_total += $planereal;
		$plane_total_ini += $planenum;
		$index++;
		
		printdebug("get_flight(): Encontrado $index aviones con total actual $plane_total y total inicial $plane_total_ini \n");
		printdebug("get_flight(): $my_plane, $my_class_air, de los que quedan $planereal y han aparecido $planetimes misiones \n" );
	    }
	}
    }
    
    if ($index==0) { # matrix is empty? 
	print "$big_red Error: </font>  No puedo encontrar el avión \"$plane\" para el bando:  $army y tipo de misión: $task \n";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: No puedo encontrar el avión \"$plane\" para el bando:  $army y tipo de misión: $task \n\n";
	exit(0);
    }

    ## @Heracles@20110708@
    ## Nuevo sistema de inventario de aviones: algoritimo de calculo de porcentajes para seleccion de avion
    my $option=0;
    my $encontrado = ($index == 1) ? 1 : 0;
    if ($index > 1) { # more than one flight possible, selct one by number of planes weight
	
	my $delta_max = "NULL";;
	my $delta = 0.0;
	my $percent_to = 0.0;
	my $percent_from = 0.0;
	
	for (my $i = 0; $i < $index; $i++) {
	    if ($fly_matrix[$i][8] < $MIN_STOCK_FOR_FLYING) {
		printdebug ("get_flight(): Avion $fly_matrix[$i][0] con stock insuficiente $fly_matrix[$i][8] para bando $inv_army");
		next;
	    }
	    $percent_from = $fly_matrix[$i][9] / $mission_times;
	    $percent_to = $fly_matrix[$i][6] / $plane_total_ini;
	    $delta = $percent_to - $percent_from;
	    printdebug ("get_flight(): $fly_matrix[$i][0] FROM $percent_from TO $percent_to DELTA $delta");
	    
	    my $bool = $delta <=> $delta_max;
	    printdebug ("get_flight(): delta $delta mayor que delta_max $delta_max ? $bool");
	    if ( $bool == 1 || $delta_max == "NULL") {
		$delta_max = $delta;
		$option = $i;
		$encontrado++;
	    }
	}

    }
    
    if ($encontrado == 0) { # avion no encontrado en inventario 
        print "$big_red Error: </font>  Tipo de misión $task sin stock de aviones en el inventario para el bando: $inv_army \n";
        unlink $gen_lock;
        print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Tipo de misión $task sin stock de aviones en el inventario para el bando: $inv_army \n";
        exit(0);
    }    

    printdebug ("get_flight(): $fly_matrix[$option][0] seleccionado \n");		

    ## @Heracles@20110708@
    ## Sumamos las veces que ha salido un tipo de avion en una mision
    open(TEMPFLIGHTS, ">temp_aircraft.data");
    seek FLIGHTS,0,0;
    while (<FLIGHTS>) {
        if ($_ =~ m/^$inv_army,$fly_matrix[$option][0],([^,]+),([^,]+),([^,]+),/){
	    my $my_times = $3 + 1;
	    printdebug ("get_flight(): Seleccionamos $fly_matrix[$option][0], apariciones $3 misiones.\n");	    
	    $_ =~ s/^([^,]+,[^,]+,[^,]+,[^,]+),[^,]+,/$1,$my_times,/;
	    printdebug ("get_flight(): Actualizamos aircraft.data con: $_ \n");
	    print TEMPFLIGHTS;
	}
	else {
	    print TEMPFLIGHTS;	    
	}
    }
    close (TEMPFLIGHTS);
    close (FLIGHTS);
    unlink $FLIGHTS_DEF;
    rename "temp_aircraft.data", $FLIGHTS_DEF;
    if (!open (FLIGHTS, "<$FLIGHTS_DEF")) {
	print "$big_red ERROR Can't open File $FLIGHTS_DEF: $! on get_flight()\n";
	print "Please NOTIFY this error.\n";
	print &print_end_html();
	print GEN_LOG " Pid $$ : " .scalar(localtime(time)) ." ERROR: Can't open File $FLIGHTS_DEF: $! on get_flight()\n\n";
	exit(0);
    }    
    ## @Heracles@20110708@
    ## Fin nuevo sistema de inventario de aviones
    
    #return list
    my $sqdname= get_sqdname($fly_matrix[$option][7]);
    return ($sqdname, $fly_matrix[$option][1], $fly_matrix[$option][3], $fly_matrix[$option][2], 
		$fly_matrix[$option][4], $fly_matrix[$option][5], $fly_matrix[$option][0]);
}


# Build all groups list using information from set_attacks_types() amd using the amount of planes
# from globlal variables readed from options.txt on main proc
sub build_grplsts() {
    
#grplst : array = (TASK,nombre_SQD,N_planes,OnlyAI,skill,class,fuel,weapons,def_alt,def_spd);
# TASK : BA  = BOMBER ATTACK  
#        BD  = BOMBER DEFEND (intercept enemy tanks)
#        RE  = RECON
#        EBA = ESCORT BA
#        ESU = ESCORT SUM (suministros) equivalent to EBA
#        EBD = ESCORT BD
#        ET  = ESCORT TANKS
#        ER  = ESCORT RECON
#        I   = INTERCEPT (enemy recons, or enemy BA)
#        SUM = SUply Mission

    my @vuelo=(); 
    my $more_fighters=0;
    my $more_bombers=0;
    my $fig_ai_skill=1; # 0=Rookie 1=Normal 2=veteran 3=Ace

    if ($clima>90){ # clima 91..100 : low visibility rain , thunder
	$fig_ai_skill=0; # Rookie
	#$fig_ai_skill=1;  # Average
	#$fig_ai_skill=2; # veteran
	#$fig_ai_skill=3; # Ace

	#force radio enable on bad weather
	$VVS_RADIO="&0";
	$LW_RADIO="&0";
    }

    my $sqdname="";
    #--- RED DEFENE FLIGHT
    if ($red_bomb_defend==1) { # Blue attack tactic
	if ($red_bom_def_planes>0) {  
	    if ($red_bom_def_planes>2) {$more_bombers=$red_bom_def_planes-2; $red_bom_def_planes=2;}
	    @vuelo=get_flight("1","BD","0",$red_bom_def_type); # pedir un vuelo (army, task, human, plane) 
	    $sqdname= shift @vuelo;
	    push(@red_def_grplst, "BD",$sqdname."00",$red_bom_def_planes,$red_bom_def_ai,"2",@vuelo);
	    if ($more_bombers>0) {
		my $new_name="";
		while (1){
		    @vuelo=get_flight("1","BD","0",$vuelo[5]); # $vuelo[5] is selected plane external name grp 0
		    $new_name=shift @vuelo;
		    if ($new_name ne $sqdname) {last;}
		}
		push(@red_def_grplst, "BD",$new_name."01",$more_bombers,$red_bom_def_ai,"2",@vuelo);
		$red_bom_def_planes=2+$more_bombers;
		$more_bombers=0;
	    }
	}
	if ($red_fig_def_planes>0) {
	    if ($red_fig_def_planes>4) {$more_fighters=$red_fig_def_planes-4; $red_fig_def_planes=4;}
	    @vuelo=get_flight("1","EBD","0","");
	    $sqdname= shift @vuelo;
	    push(@red_def_grplst, "EBD",$sqdname."10",$red_fig_def_planes,$red_fig_def_ai,$fig_ai_skill,@vuelo);
	    if ($more_fighters>0) {
		push(@red_def_grplst, "EBD",$sqdname."11",$more_fighters,$red_fig_def_ai,$fig_ai_skill,@vuelo);
		$red_fig_def_planes=4+$more_fighters;
		$more_fighters=0;
	    }
	}
    }
    else { # blue attack strategic (or recon or suply)
	if ($red_fig_def_planes>0) {
	    if ($red_fig_def_planes>4) {$more_fighters=$red_fig_def_planes-4; $red_fig_def_planes=4;}
	    @vuelo=get_flight("1","I","0",""); 
	    $sqdname= shift @vuelo;
	    push(@red_def_grplst, "I",$sqdname."10",$red_fig_def_planes,$red_fig_def_ai,$fig_ai_skill,@vuelo);
	    if ($more_fighters>0) {
		push(@red_def_grplst, "I",$sqdname."11",$more_fighters,$red_fig_def_ai,$fig_ai_skill,@vuelo);
		$red_fig_def_planes=4+$more_fighters;
		$more_fighters=0;
	    }
	}
    }
    #---  RED ATTACK FLIGHT 
    if ($red_bomb_attk==1) { # reb attack strategic (or a recon or a suply)
	if ($RED_RECON==0 && $RED_SUM==0) { # no recon no sum
	    if ($red_bom_attk_planes>0) {  
		if ($red_bom_attk_planes>4) {$more_bombers=$red_bom_attk_planes-4; $red_bom_attk_planes=4;}
		@vuelo=get_flight("1","BA","0",$red_bom_attk_type); # pedir un vuelo (army, task, human, plane) 
		$sqdname= shift @vuelo;
		push(@red_attk_grplst, "BA",$sqdname."20",$red_bom_attk_planes,$red_bom_attk_ai,"2",@vuelo);
		if ($more_bombers>0) {
		    push(@red_attk_grplst, "BA",$sqdname."21",$more_bombers,$red_bom_attk_ai,"2",@vuelo);
		    $red_bom_attk_planes=4+$more_bombers;
		    $more_bombers=0;
		}
	    }
	    if ($red_fig_attk_planes>0) {
		if ($red_fig_attk_planes>4) {$more_fighters=$red_fig_attk_planes-4; $red_fig_attk_planes=4;}
		@vuelo=get_flight("1","EBA","0",""); #CHECK AI/HUM
		$sqdname= shift @vuelo;
		push(@red_attk_grplst, "EBA",$sqdname."30",$red_fig_attk_planes,$red_fig_attk_ai,$fig_ai_skill,@vuelo);
		if ($more_fighters>0) {
		    push(@red_attk_grplst, "EBA",$sqdname."31",$more_fighters,$red_fig_attk_ai,$fig_ai_skill,@vuelo);
		    $red_fig_attk_planes=4+$more_fighters;
		    $more_fighters=0;
		}
	    }
	}
	if ($RED_RECON==0 && $RED_SUM==1) { # RED SUM
	    if ($red_bom_attk_planes>0) {  
		if ($red_bom_attk_planes>4) {$more_bombers=$red_bom_attk_planes-4; $red_bom_attk_planes=4;}
		@vuelo=get_flight("1","SUM","0",$red_bom_attk_type); # pedir un vuelo (army, task, human, plane) 
		$sqdname= shift @vuelo;
		push(@red_attk_grplst, "SUM",$sqdname."20",$red_bom_attk_planes,$red_bom_attk_ai,"2",@vuelo);
		if ($more_bombers>0) {
		    push(@red_attk_grplst, "SUM",$sqdname."21",$more_bombers,$red_bom_attk_ai,"2",@vuelo);
		    $red_bom_attk_planes=4+$more_bombers;
		    $more_bombers=0;
		}
	    }
	    if ($red_fig_attk_planes>0) {
		if ($red_fig_attk_planes>4) {$more_fighters=$red_fig_attk_planes-4; $red_fig_attk_planes=4;}
		@vuelo=get_flight("1","ESU","0","");
		$sqdname= shift @vuelo;
		push(@red_attk_grplst, "ESU",$sqdname."30",$red_fig_attk_planes,$red_fig_attk_ai,$fig_ai_skill,@vuelo);
		if ($more_fighters>0) {
		    push(@red_attk_grplst, "ESU",$sqdname."31",$more_fighters,$red_fig_attk_ai,$fig_ai_skill,@vuelo);
		    $red_fig_attk_planes=4+$more_fighters;
		    $more_fighters=0;
		}
	    }
	}
	if ($RED_RECON==1) { # RED RECON
	    @vuelo=get_flight("1","R","0","");
	    $sqdname= shift @vuelo;
	    push(@red_attk_grplst, "R",$sqdname."20","2","0","2",@vuelo);
	    if ($red_fig_attk_planes>0) {
		if ($red_fig_attk_planes>4) {$more_fighters=$red_fig_attk_planes-4; $red_fig_attk_planes=4;}
		@vuelo=get_flight("1","ER","0",""); 
		$sqdname= shift @vuelo;
		push(@red_attk_grplst, "ER",$sqdname."30",$red_fig_attk_planes,$red_fig_attk_ai,$fig_ai_skill,@vuelo);
		if ($more_fighters>0) {
		    push(@red_attk_grplst, "ER",$sqdname."31",$more_fighters,$red_fig_attk_ai,$fig_ai_skill,@vuelo);
		    $red_fig_attk_planes=4+$more_fighters;
		    $more_fighters=0;
		}
	    }
	}


    }
    else { # Red attack tactic, with tanks
	if ($red_fig_attk_planes>0) {
	    if ($red_fig_attk_planes>4) {$more_fighters=$red_fig_attk_planes-4; $red_fig_attk_planes=4;}
	    @vuelo=get_flight("1","ET","0",""); 
	    $sqdname= shift @vuelo;
	    push(@red_attk_grplst, "ET",$sqdname."30",$red_fig_attk_planes,$red_fig_attk_ai,$fig_ai_skill,@vuelo);
	    if ($more_fighters>0) {
		push(@red_attk_grplst, "ET",$sqdname."31",$more_fighters,$red_fig_attk_ai,$fig_ai_skill,@vuelo);
		$red_fig_attk_planes=4+$more_fighters;
		$more_fighters=0;
	    }

	@vuelo=get_flight("1","AT","0","");
	$sqdname= shift @vuelo;
	push(@red_attk_grplst, "AT",$sqdname."32",$red_fig_attk_planes,$red_fig_attk_ai,$fig_ai_skill,@vuelo);

	}
    }
    
    #--- DEFENSE BLUE FLIGHT
    if ($blue_bomb_defend==1) { # red attack tactic
	if ($blue_bom_def_planes>0) {  
	    if ($blue_bom_def_planes>2) {$more_bombers=$blue_bom_def_planes-2; $blue_bom_def_planes=2;}
	    @vuelo=get_flight("2","BD","0",$blue_bom_def_type); # pedir un vuelo (army, task, human, plane) 
	    $sqdname= shift @vuelo;
	    push(@blue_def_grplst, "BD",$sqdname."00",$blue_bom_def_planes,$blue_bom_def_ai,"2",@vuelo);
	    if ($more_bombers>0) {
		my $new_name="";
		while (1){
		    @vuelo=get_flight("2","BD","0",$vuelo[5]); # $vuelo[5] is selected plane external name grp 0
		    $new_name=shift @vuelo;
		    if ($new_name ne $sqdname) {last;}
		}
		push(@blue_def_grplst, "BD",$new_name."01",$more_bombers,$blue_bom_def_ai,"2",@vuelo);
		$blue_bom_def_planes=2+$more_bombers;
		$more_bombers=0;
	    }
	}
	if ($blue_fig_def_planes>0) {
	    if ($blue_fig_def_planes>4) {$more_fighters=$blue_fig_def_planes-4; $blue_fig_def_planes=4;}
	    @vuelo=get_flight("2","EBD","0",""); 
	    $sqdname= shift @vuelo;
	    push(@blue_def_grplst, "EBD",$sqdname."10",$blue_fig_def_planes,$blue_fig_def_ai,$fig_ai_skill,@vuelo);
	    if ($more_fighters>0) {
		push(@blue_def_grplst, "EBD",$sqdname."11",$more_fighters,$blue_fig_def_ai,$fig_ai_skill,@vuelo);
		$blue_fig_def_planes=4+$more_fighters;
		$more_fighters=0;
	    }	    
	}
    }
    else { # Red attack strategic (or recon or sum)
	if ($blue_fig_def_planes>0) {
	    if ($blue_fig_def_planes>4) {$more_fighters=$blue_fig_def_planes-4; $blue_fig_def_planes=4;}
	    @vuelo=get_flight("2","I","0",""); 
	    $sqdname= shift @vuelo;
	    push(@blue_def_grplst, "I",$sqdname."10",$blue_fig_def_planes,$blue_fig_def_ai,$fig_ai_skill,@vuelo);
	    if ($more_fighters>0) {
		push(@blue_def_grplst, "I",$sqdname."11",$more_fighters,$blue_fig_def_ai,$fig_ai_skill,@vuelo);
		$blue_fig_def_planes=4+$more_fighters;
		$more_fighters=0;
	    }	    
	}
    }
    #--- BLUE ATTACK FLIGHT
    if ($blue_bomb_attk==1) {  # blue attack strategic (or recon or sum)
	if ($BLUE_RECON==0 && $BLUE_SUM==0) { # no recon no sum
	    if ($blue_bom_attk_planes>0) {  
		if ($blue_bom_attk_planes>4) {$more_bombers=$blue_bom_attk_planes-4; $blue_bom_attk_planes=4;}
		@vuelo=get_flight("2","BA","0",$blue_bom_attk_type); # pedir un vuelo (army, task, human, plane) 
		$sqdname= shift @vuelo;
		push(@blue_attk_grplst, "BA",$sqdname."20",$blue_bom_attk_planes,$blue_bom_attk_ai,"2",@vuelo);
		if ($more_bombers>0) {
		    push(@blue_attk_grplst, "BA",$sqdname."21",$more_bombers,$blue_bom_attk_ai,"2",@vuelo);
		    $blue_bom_attk_planes=4+$more_bombers;
		    $more_bombers=0;
		}
	    }
	    if ($blue_fig_attk_planes>0) {
		if ($blue_fig_attk_planes>4) {$more_fighters=$blue_fig_attk_planes-4; $blue_fig_attk_planes=4;}
		@vuelo=get_flight("2","EBA","0",""); 
		$sqdname= shift @vuelo;
		push(@blue_attk_grplst, "EBA",$sqdname."30",$blue_fig_attk_planes,$blue_fig_attk_ai,$fig_ai_skill,@vuelo);
		if ($more_fighters>0) {
		    push(@blue_attk_grplst, "EBA",$sqdname."31",$more_fighters,$blue_fig_attk_ai,$fig_ai_skill,@vuelo);
		    $blue_fig_attk_planes=4+$more_fighters;
		    $more_fighters=0;
		}	    
	    }
	}
	if ($BLUE_RECON==0 && $BLUE_SUM==1) { # sum
	    if ($blue_bom_attk_planes>0) {  
		if ($blue_bom_attk_planes>4) {$more_bombers=$blue_bom_attk_planes-4; $blue_bom_attk_planes=4;}
		@vuelo=get_flight("2","SUM","0",$blue_bom_attk_type); # pedir un vuelo (army, task, human, plane) 
		$sqdname= shift @vuelo;
		push(@blue_attk_grplst, "SUM",$sqdname."20",$blue_bom_attk_planes,$blue_bom_attk_ai,"2",@vuelo);
		if ($more_bombers>0) {
		    push(@blue_attk_grplst, "SUM",$sqdname."21",$more_bombers,$blue_bom_attk_ai,"2",@vuelo);
		    $blue_bom_attk_planes=4+$more_bombers;
		    $more_bombers=0;
		}
	    }

	    if ($blue_fig_attk_planes>0) {
		if ($blue_fig_attk_planes>4) {$more_fighters=$blue_fig_attk_planes-4; $blue_fig_attk_planes=4;}
		@vuelo=get_flight("2","ESU","0",""); 
		$sqdname= shift @vuelo;
		push(@blue_attk_grplst, "ESU",$sqdname."30",$blue_fig_attk_planes,$blue_fig_attk_ai,$fig_ai_skill,@vuelo);
		if ($more_fighters>0) {
		    push(@blue_attk_grplst, "ESU",$sqdname."31",$more_fighters,$blue_fig_attk_ai,$fig_ai_skill,@vuelo);
		    $blue_fig_attk_planes=4+$more_fighters;
		    $more_fighters=0;
		}	    
	    }
	}
	if ($BLUE_RECON==1) { # recon
	    @vuelo=get_flight("2","R","0",""); 
	    $sqdname= shift @vuelo;
	    push(@blue_attk_grplst,"R","g0120","2","0","2",@vuelo);
	    if ($blue_fig_attk_planes>0) {
		if ($blue_fig_attk_planes>4) {$more_fighters=$blue_fig_attk_planes-4; $blue_fig_attk_planes=4;}
		@vuelo=get_flight("2","ER","0",""); 
		$sqdname= shift @vuelo;
		my $sqdname= $gerfig[(int(rand(scalar(@gerfig))))];
		push(@blue_attk_grplst, "ER",$sqdname."30",$blue_fig_attk_planes,$blue_fig_attk_ai,$fig_ai_skill,@vuelo);
		if ($more_fighters>0) {
		    push(@blue_attk_grplst, "ER",$sqdname."31",$more_fighters,$blue_fig_attk_ai,$fig_ai_skill,@vuelo);
		    $blue_fig_attk_planes=4+$more_fighters;
		    $more_fighters=0;
		}	    
	    }
	}
    }
    else { # blue attack tactical with tanks
	if ($blue_fig_attk_planes>0) {
	    if ($blue_fig_attk_planes>4) {$more_fighters=$blue_fig_attk_planes-4; $blue_fig_attk_planes=4;}
	    @vuelo=get_flight("2","ET","0",""); 
	    $sqdname= shift @vuelo;
	    push(@blue_attk_grplst, "ET",$sqdname."30",$blue_fig_attk_planes,$blue_fig_attk_ai,$fig_ai_skill,@vuelo);
	    if ($more_fighters>0) {
		push(@blue_attk_grplst, "ET",$sqdname."31",$more_fighters,$blue_fig_attk_ai,$fig_ai_skill,@vuelo);
		$blue_fig_attk_planes=4+$more_fighters;
		$more_fighters=0;
	    }	 
	@vuelo=get_flight("2","AT","0","");
	$sqdname= shift @vuelo;
	push(@blue_attk_grplst, "AT",$sqdname."32",$blue_fig_attk_planes,$blue_fig_attk_ai,$fig_ai_skill,@vuelo);
	       
	}
    }
}

# enter coordinates, and returns coordinates of close parking place (static objects parked)  of an AF
# to set as bombers objetive
sub find_close_obj_area($$){
    my($cx,$cy)=@_;
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_=~ m/^AF[0-9]{2}:P[0-9],([^,]+),([^,]+),([^,]+),([^,]+),/){ 
	    if (distance($cx,$cy,$1,$2)<2000){ # si el park area esta en el AF <3km
		$cx=int(($1+$3)/2);
		$cy=int(($2+$4)/2);
		return($cx,$cy); #return central point of a parking place
	    }
	}
    }
    return($cx,$cy); # return same values if nothing found
}

# get a mission number unique. This is better to be done with file locks but some 
# windows versions cant:  flock() unimplemented on this platform
sub get_mission_nbr(){
    my $extend="_";
    my $counter;
    my $ret=0;
    
    if (!(open (COU,"<mis_counter.data"))){
	print "$big_red Error: </font>  Can't open counter file R : $!\n";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Can't open counter file R: $! \n\n";
	exit(0);
    }
    $counter=<COU>;
    close(COU);
    
    if (!(open (COU,">mis_counter.data"))){
	print "$big_red Error: </font>  Can't open counter file W : $!\n";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Can't open counter file W: $! \n\n";
	exit(0);
    }
    $extend=$counter;
    $counter =~ s/_//;
    printf COU ("_%05.0f",$counter+1);
    close(COU);
    return($extend); # retorna:   _%05.0f
}

# this is the mission header
# weather type is defined here, in spanish. later on print briefing is translated to other languages
# ------------
sub print_header() {

    print MIS "[MAIN]\n";
    print MIS "  MAP $MAP_NAME_LOAD\n";
    print MIS "  TIME ".$mis_time."\n";

    if ($clima<=20){ # clima 1..20 -> 20% Clear
    print MIS "  CloudType 0\n";
    print DET "cloud_type=0\n";
    $tipo_clima="Despejado";
    }
    if ($clima>20 && $clima<=90){ # clima 21..90 -> 70% Good
    print MIS "  CloudType 1\n";
    print DET "cloud_type=1\n";
    $tipo_clima="Bueno";
    }
    if ($clima>90 && $clima<=95){ # clima 91..95 -> 5% Blind
    print MIS "  CloudType 4\n";
    print DET "cloud_type=4\n";
    $tipo_clima="Baja visibilidad";
    }
    if ($clima>95 && $clima<=99){ # clima 96..99 -> 4% Rain/Snow
    print MIS "  CloudType 5\n";
    print DET "cloud_type=5\n";
    $tipo_clima="Precipitaciones";
    }
    if ($clima>99 && $clima<=100){ # clima only 100 -> 1% Storm
    print MIS "  CloudType 6\n";
    print DET "cloud_type=6\n";
    $tipo_clima="Tormenta";
    }

    print MIS "  CloudHeight $nubes\n";
    print MIS "  army 1\n";
    print MIS "  playerNum 0\n";
}


# print froup lists into mission. The order they are printed will be the order on the runway
# so we use some randmon mix to make more inpredictable what planes are in what task
sub print_grplsts() {

    # calculamos la cantidad de grupos en cada lista.
    my $red_def_groups = (scalar(@red_def_grplst)/$grpentries);
    my $red_attk_groups = (scalar(@red_attk_grplst)/$grpentries);
    my $blue_def_groups = (scalar(@blue_def_grplst)/$grpentries);
    my $blue_attk_groups = (scalar(@blue_attk_grplst)/$grpentries);
    my $i=0;
    my $j=0;
    my $k=0;
    print MIS "[Wing]\n";

    $k=int(rand(2));
    for ($j=0; $j<2; $j++){
	if ($k){ 
	    #fighters de defend group rojos
	    for ( $i=0; $i<$red_def_groups;  $i++){ 
		if ($red_def_grplst[$grpentries*$i] eq "I" ||
		    $red_def_grplst[$grpentries*$i] eq "EBD") {
		    print MIS $red_def_grplst[$grpentries*$i+1]."\n";
		}
	    }
	    $k=0;
	}
	else {
	    #figters en grupo ataque  rojos
	    for ( $i=0; $i<$red_attk_groups;  $i++){ 
		if ($red_attk_grplst[$grpentries*$i] eq "ET" ||
		    $red_attk_grplst[$grpentries*$i] eq "ER" ||
		    $red_attk_grplst[$grpentries*$i] eq "ESU" ||
		    $red_attk_grplst[$grpentries*$i] eq "EBA") { 
		    print MIS $red_attk_grplst[$grpentries*$i+1]."\n";
		}
	    }
	    $k=1;
	}
    }

    $k=int(rand(2));
    for ($j=0; $j<2; $j++){
	if ($k){ 
	    #luego   bombers de defend rojos
	    for ( $i=0; $i<$red_def_groups;  $i++){ 
		if ($red_def_grplst[$grpentries*$i] eq "BD") { 
		    print MIS $red_def_grplst[$grpentries*$i+1]."\n";
		}
	    }
	    $k=0;
	}
	else {
	    #luego bomebers en grupo de ataque rojos
	    for ( $i=0; $i<$red_attk_groups;  $i++){ 
		if ($red_attk_grplst[$grpentries*$i] eq "BA" ||
		    $red_attk_grplst[$grpentries*$i] eq "AT" ||
		    $red_attk_grplst[$grpentries*$i] eq "SUM" ||
		    $red_attk_grplst[$grpentries*$i] eq "R") {
		    print MIS $red_attk_grplst[$grpentries*$i+1]."\n";
		}
	    }
	    $k=1;
	}
    }

    $k=int(rand(2));
    for ($j=0; $j<2; $j++){
	if ($k){ 
	    # fighters en grupo de defensa azul
	    for ( $i=0; $i<$blue_def_groups;  $i++){ 
		if ($blue_def_grplst[$grpentries*$i] eq "I" ||
		    $blue_def_grplst[$grpentries*$i] eq "EBD") {
		    print MIS $blue_def_grplst[$grpentries*$i+1]."\n";
		}
	    }
	    $k=0;
	}
	else {
	    #luego escoltas azules, en orden de aparicion
	    for ( $i=0; $i<$blue_attk_groups; $i++){ 
		if ($blue_attk_grplst[$grpentries*$i] eq "ET" ||
		    $blue_attk_grplst[$grpentries*$i] eq "ER" ||
		    $blue_attk_grplst[$grpentries*$i] eq "ESU" ||
		    $blue_attk_grplst[$grpentries*$i] eq "EBA") {
		    print MIS $blue_attk_grplst[$grpentries*$i+1]."\n";
		}
	    }
	    $k=1;
	}
    }

    $k=int(rand(2));
    for ($j=0; $j<2; $j++){
	if ($k){ 
	    # bombers en grupo de defensa azul
	    for ( $i=0; $i<$blue_def_groups;  $i++){ 
		if ($blue_def_grplst[$grpentries*$i] eq "BD") { 
		    print MIS $blue_def_grplst[$grpentries*$i+1]."\n";
		}
	    }
	    $k=0;
	}
	else {
	    #luego bomebers en grupo de ataque azules
	    for ( $i=0; $i<$blue_attk_groups; $i++){ 
		if ($blue_attk_grplst[$grpentries*$i] eq "BA" ||
		    $blue_attk_grplst[$grpentries*$i] eq "AT" ||
		    $blue_attk_grplst[$grpentries*$i] eq "SUM" ||
		    $blue_attk_grplst[$grpentries*$i] eq "R") {
		    print MIS $blue_attk_grplst[$grpentries*$i+1]."\n";
		}
	    }
	    $k=1;
	}
    }
}

# returns  TRUE only if the AF we are looking has no enemy AF close.
# the minimal distance for 2 af is set on $MIN_ENEMY_AF_DIST
# any distance lower that that value will make return FAlSE
sub no_enemy_af_close($$$){
    my ($army,$afcx,$afcy)=@_;
    if ($army==1){ # we look for red AF, serach for no blue close
	if ($blue_af1_code ne "") {
	    if (distance($blue_af1_cx,$blue_af1_cy,$afcx,$afcy)<$MIN_ENEMY_AF_DIST){
		return(0);
	    }
	}
	if ($blue_af2_code ne "") {
	    if (distance($blue_af2_cx,$blue_af2_cy,$afcx,$afcy)<$MIN_ENEMY_AF_DIST){
		return(0);
	    }
	}
    }
    else { # we look for blue AF, serach for no red AF close
	if ($red_af1_code ne "") {
	    if (distance($red_af1_cx,$red_af1_cy,$afcx,$afcy)<$MIN_ENEMY_AF_DIST){
		return(0);
	    }
	}
	if ($red_af2_code ne "") {
	    if (distance($red_af2_cx,$red_af2_cy,$afcx,$afcy)<$MIN_ENEMY_AF_DIST){
		return(0);
	    }
	}
    }
    return(1); # ok, no enemy afields close
}


# build fighters way points. This is not really for all fighters. This will make way points 
# with a pattern for intercept or patrol. That is a kind of cross over target.
sub fighters_wp($$$$) {
    my ($player,$tgtcx,$tgtcy,$look) = @_ ;

    my $radio="";                        # set in config.pl
    if ($player==1) {$radio=$VVS_RADIO;} # "&0" 50%  or  "&1" 50%
    if ($player==2) {$radio=$LW_RADIO;}  # "&0" 50%  or  "&1" 50%

    #Armamos un aflist con los posibles AF de despegue para defensa
    #de aqui sale el vuelo de intercept(I) (a estategic attack(BA) o recon(R) enemigos)
    #-------------
    my @aflist=();
    my $dist;
    my $afcode="NONE";
    my $af_is_ship=0;
    my $afcx;
    my $afcy;
    my $old_afcode;
    my $old_dist=0;

    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/(AF[0-9]{2}),[^,]+,([^,]+),([^,]+),.*,([^,]+):([0-3])/){ #buscamos un AF cualquiera 
	    if ($5==$player && $4<80) { # si es amigo y da~nos menor a 80%
		$dist= distance($tgtcx,$tgtcy,$2,$3); #calculamos distancia
		if (($dist < $MAX_FIGHTERS_DIST) && ($dist >= $MIN_FIGHTERS_DIST)){
		    if (no_enemy_af_close($player,$2,$3)){
			push (@aflist, "$1","$2","$3");
		    }
		}
	    }
	}
    }

    # Verificamos que la liista no este vacia. si es asi, buscamos el AG mas cercano sin restriccion
    #---------
    if (scalar(@aflist)>0) { 
	my $azar=int(rand(scalar(@aflist)/3)); # CHECK Guarda con /3 si cambiamos la lista de af
	$afcode=$aflist[$azar*3];
	$afcx=$aflist[$azar*3+1];
	$afcy=$aflist[$azar*3+2];
	$dist= distance($tgtcx,$tgtcy,$afcx,$afcy); #calculamos distancia

	seek GEO_OBJ, 0, 0;
	while(<GEO_OBJ>) {
	    if ($_ =~ m/$afcode,[^,]+,[^,]+,[^,]+,([0-9]),.*,[^:]+:[0-3]/){ #buscamos el AF y leemos typo
		if ($1==4){
		    $af_is_ship=1; # is a test runway (static ship)
		}
		last;
	    }
	}
    }
    else {
	$old_dist=500000;
	seek GEO_OBJ, 0, 0;
	while(<GEO_OBJ>) {
	    if ($_ =~ m/(AF[0-9]{2}),[^,]+,([^,]+),([^,]+),([0-9]),.*,([^:]+):([0-3])/){ #buscamos un AF cualquiera
		if ($6==$player && $5<80) { # si es amigo y da~nos menosres a 80
		    $dist=  distance($tgtcx, $tgtcy, $2, $3); #calculamos distancia en Km
		    if ($dist < $old_dist) {
			$old_dist=$dist;
			$afcode=$1;
			$afcx=$2;
			$afcy=$3;
			if ($4==4) {$af_is_ship=1;}
			else {$af_is_ship=0;}
		    }
		}
	    }
	}
	$dist=$old_dist;
    }
    
    if ($afcode eq "NONE") { # esto no deberia ocurrir nunca a menos que un bando pierda todos los AF
	print "$big_red Error: </font> Can't shedule Fighters flight.<br>";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Can't shedule Fighters flight.\n\n";
	exit(0);
    }
    

# seleccion de la cabecera mas cercana al objetivo, seteamos landcood y takeoffcoord
# por ahora solo miramos en H1 la sig linea H2. Mas adelante expnadir a H3 y H4. CHECK
#-----------
    my @takeoffcoord=();
    my @landcoord=();

    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^$afcode:H1,([^,]+),([^,]+),/){ # por ahora solo miramos H1  CHECK
	    if ($af_is_ship==1 || distance($tgtcx,$tgtcy,$1,$2)<=$dist){ # do not swap ship AF
		@takeoffcoord=(int($1),int($2));
		$_=readline(GEO_OBJ); #y la siguiente linea(H2) CHECK
		$_=~ m/^$afcode:H2,([^,]+),([^,]+),/;
		@landcoord=(int($1),int($2));
	    }
	    else {
		@landcoord=(int($1),int($2));
		$_=readline(GEO_OBJ);
		$_=~ m/^$afcode:H2,([^,]+),([^,]+),/;
		@takeoffcoord=(int($1),int($2));
	    }
	    last; #version 24 optim change
	}
    }
    if ($player==1 && $red_af_count){ #si es un vuelo rojo y ya hay un af usado:
	if ( ($afcode eq $red_af1_code) && 
	     (($takeoffcoord[0]!=$red_af1_cx)||($takeoffcoord[1]!=$red_af1_cy)) ){ # si selen del mismo af, pero != header
	    my @temp=@landcoord;
	    @landcoord=@takeoffcoord;
	    @takeoffcoord=@temp;
	}
    }
    if ($player==1 && $af_is_ship==1 && ($red_ship_af==0 ||$afcode ne $red_af1_code) ){
	$red_ship_af++;
	push(@red_ship_chosed,$afcode);
    }

    if ($player==2 && $blue_af_count){ #si es un vuelo azul y ya hay un af usado:
	if ( ($afcode eq $blue_af1_code) &&
	     (($takeoffcoord[0]!=$blue_af1_cx)||($takeoffcoord[1]!=$blue_af1_cy)) ){ #si selen del mismo af, pero != header
	    my @temp=@landcoord;
	    @landcoord=@takeoffcoord;
	    @takeoffcoord=@temp;
	}
    }
    if ($player==2 && $af_is_ship==1 && ($blue_ship_af==0 ||$afcode ne $blue_af1_code) ){
	$blue_ship_af++;
	push(@blue_ship_chosed,$afcode);
    }
    
# una vez definido cual es el AF de despegue de defensa, guardar coord para poblar.
#-----------

    if ($player==1){
	$red_af_count++;
	if ($red_af_count==1) {
	    $red_af1_code=$afcode;
	    $red_af1_cx=$takeoffcoord[0];
	    $red_af1_cy=$takeoffcoord[1];
	}
	else { # es el af nro dos
	    $red_af2_code=$afcode;
	    $red_af2_cx=$takeoffcoord[0];
	    $red_af2_cy=$takeoffcoord[1];
	}
    }
    else {
	$blue_af_count++;
	if ($blue_af_count==1) {
	    $blue_af1_code=$afcode;
	    $blue_af1_cx=$takeoffcoord[0];
	    $blue_af1_cy=$takeoffcoord[1];
	}
	else {
	    $blue_af2_code=$afcode;
	    $blue_af2_cx=$takeoffcoord[0];
	    $blue_af2_cy=$takeoffcoord[1];
	}
	    
    }
    
    
    
#definimos los wp despues de despegar (aftertoffwp) y el anterior al aterrizaje (beforelandwp)=final
#-----------
   my @aftertoffwp=($takeoffcoord[0]+(($takeoffcoord[0]-$landcoord[0])*6),
		    $takeoffcoord[1]+(($takeoffcoord[1]-$landcoord[1])*6));


    # si el AF desde donde salimos esta a mas de XX kilometros, 
    # tratamos de aterrizar en uno + cercano

    if (($dist>$MIN_FIGHTERS_DIST)) {  # si venimos de lejos
	$old_afcode=$afcode;
	$old_dist=$dist;
	@aflist=(); # armamos una nueva lista
	seek GEO_OBJ, 0, 0;
	while(<GEO_OBJ>) {
	    if ($_ =~ m/(AF[0-9]{2}),[^,]+,([^,]+),([^,]+),2,[^:]+:([0-3])/){ #buscamos un AF (type 2 Normal)
		if ($4==$player) { # si es amigo
		    $dist=  distance($tgtcx, $tgtcy, $2, $3); #calculamos distancia en Km
		    if ($dist < $old_dist) {
			$old_dist=$dist;
			$afcode=$1;
			$afcx=$2;
			$afcy=$3;

		    }
		}
	    }
	}

	#aca setear nuevas coordenadas del nuevo AF para poblar. CHECK
	if ($afcode ne $old_afcode){ # si no es el mismo que antes 
	    if ($player==1) {
		if ($red_af3_code eq "") { # si el 3er af no esta usado..
		    $red_af3_code=$afcode;
		    $red_af3_cx=$afcx;
		    $red_af3_cy=$afcy;
		}
		else { # sino usamos usamos un 4to
		    $red_af4_code=$afcode;
		    $red_af4_cx=$afcx;
		    $red_af4_cy=$afcy;
		}
	    }
	    else { # para azul
		if ($red_af3_code eq "") { # si el 3er af no esta usado..
		    $blue_af3_code=$afcode;
		    $blue_af3_cx=$afcx;
		    $blue_af3_cy=$afcy;
		}
		else { # sino usamos un 4to
		    $blue_af4_code=$afcode;
		    $blue_af4_cx=$afcx;
		    $blue_af4_cy=$afcy;
		}
	    }
	    seek GEO_OBJ, 0, 0;
	    while(<GEO_OBJ>) {
		if ($_ =~ m/^$afcode:H1,([^,]+),([^,]+),/){ # por ahora solo miramos H1 
		    if (distance($tgtcx,$tgtcy,$1,$2) >$dist){ # aterrizaje en cabecera H1 + alejada
			@landcoord=(int($1),int($2));
		    }
		    else {   #sino aterrizaje en  cabecera H2
			$_=readline(GEO_OBJ);
			$_=~ m/^$afcode:H2,([^,]+),([^,]+),/;
			@landcoord=(int($1),int($2));
		    }
		    last; #version 24 optim change
		}
	    }
	}
    }

    my @beforelndwp=($landcoord[0]+(int($landcoord[0]-$afcx)*8),
		     $landcoord[1]+(int($landcoord[1]-$afcy)*8));
    
# a WP previous to final, called aproachlnd
#-----------
   my @aproachlnd=($beforelndwp[0]+($landcoord[1]-$beforelndwp[1])/2,
		 $beforelndwp[1]-($landcoord[0]-$beforelndwp[0])/2);
    if(sqrt(($tgtcx-$beforelndwp[0])**2+($tgtcy-$beforelndwp[1])**2) <
       sqrt(($tgtcx-$aproachlnd[0])**2+($tgtcy-$aproachlnd[1])**2)){ 
	@aproachlnd=($beforelndwp[0]-($landcoord[1]-$beforelndwp[1])/2,
		     $beforelndwp[1]+($landcoord[0]-$beforelndwp[0])/2);
    }
    
    
# verificamos que los wp cercanos al AF  no sean negativos (mapa izq o mapa abajo) 
# ni tampoco mayores a MAP_TOP y MAP_RIGHT (mejorar estoooo! )
#-----------
    while ( $aftertoffwp[0]<0){$aftertoffwp[0]+=1000;}
    while ( $aftertoffwp[1]<0){$aftertoffwp[1]+=1000;}
    while ( $aftertoffwp[0]>$MAP_RIGHT){$aftertoffwp[0]-=1000;}
    while ( $aftertoffwp[1]>$MAP_TOP){$aftertoffwp[1]-=1000;}
    
    while ( $beforelndwp[0]<0){$beforelndwp[0]+=1000;}
    while ( $beforelndwp[1]<0){$beforelndwp[1]+=1000;}
    while ( $beforelndwp[0]>$MAP_RIGHT){$beforelndwp[0]-=1000;}
    while ( $beforelndwp[1]>$MAP_TOP){$beforelndwp[1]-=1000;}
    
    while ( $aproachlnd[0]<0){ $aproachlnd[0]+=1000;}
    while ( $aproachlnd[1]<0){ $aproachlnd[1]+=1000;}
    while ( $aproachlnd[0]>$MAP_RIGHT){$aproachlnd[0]-=1000;}
    while ( $aproachlnd[1]>$MAP_TOP){$aproachlnd[1]-=1000;}
    
    my $groups= (scalar(@grplst)/$grpentries);
    my $i=0;

    # Waring: if fightets has "notgt", no target will be set.
    # in any other cases they will have target enemy at WP 2 as default
    # changing WP to bombers may impact here
    if ( $look eq "notgt" ) { $look ="";}
    else { $look = " $look 2";}

    for ( $i=0; $i<$groups; $i++){ 
	print MIS "[".$grplst[$grpentries*$i+1]."]\n";
		if ($grplst[$grpentries*$i+0] eq "AT") { print MIS "  Planes 3\n";}
		else {print MIS "  Planes ".$grplst[$grpentries*$i+2]."\n";}

	if ($grplst[$grpentries*$i+3] eq "1") {print MIS "  OnlyAI 1\n";}
	print MIS "  Skill ".$grplst[$grpentries*$i+4]."\n";
	print MIS "  Class ".$grplst[$grpentries*$i+5]."\n";
 		if ($grplst[$grpentries*$i+0] eq "AT") { print MIS " Fuel 0\n";}
		else {print MIS "  Fuel ".$grplst[$grpentries*$i+6]."\n";}

	print MIS "  weapons ".$grplst[$grpentries*$i+7]."\n";
	print MIS "[".$grplst[$grpentries*$i+1]."_Way]\n";
	
	# WP 0 takeoff
	if ($af_is_ship==1){  
	    print MIS "TAKEOFF ".$takeoffcoord[0]." ".$takeoffcoord[1]." 0.00 0.00 ".
		($red_ship_af+$blue_ship_af-1)."_Static 0 &0\n";
	}
	else {
	    print MIS "TAKEOFF ".$takeoffcoord[0]." ".$takeoffcoord[1]." 0.00 0.00 &0\n";
	}
	
	# WP 1 takeoff +1
	print MIS "NORMFLY ".$aftertoffwp[0]." ".$aftertoffwp[1]." 500.00 270.00 &0\n"; 
	
	# nesxt wapoints are patrol patterns
	my $ra=6500; # radius of pattern 
	my $alt=$grplst[$grpentries*$i+8];
	my $speed=$grplst[$grpentries*$i+9];
	my $cos_ra=0.7 * $ra; # this was cosine(45) * radius.  replaced to value, name remains
	
	if ($tgtcy-$takeoffcoord[1]>=0){ # we come from south
	    if ($tgtcx-$landcoord[0]>=0){ # we land to the west
		print MIS "NORMFLY ", $tgtcx, " ", $tgtcy-$ra * 1.4, " ", $alt, " ", $speed, " &0\n";
		print MIS "NORMFLY ", $tgtcx, " ", $tgtcy+$ra, " ", $alt, " ", $speed, $look, " &0\n";
		print MIS "NORMFLY ", $tgtcx+$cos_ra, " ",$tgtcy-$cos_ra, " ", $alt, " ", $speed, " &0\n";
		print MIS "NORMFLY ", $tgtcx-$cos_ra * 1.5," ",$tgtcy+$cos_ra * 1.5," ",$alt," ",$speed, $look, " &0\n";
	    }
	    else { # we come from south, we land to east dorection
		print MIS "NORMFLY ", $tgtcx, " ", $tgtcy-$ra * 1.4, " ", $alt, " ", $speed, " &0\n";
		print MIS "NORMFLY ", $tgtcx, " ", $tgtcy+$ra, " ", $alt, " ", $speed, $look, " &0\n";
		print MIS "NORMFLY ", $tgtcx-$cos_ra, " ", $tgtcy-$cos_ra, " ", $alt, " ", $speed, " &0\n";
		print MIS "NORMFLY ", $tgtcx+$cos_ra * 1.5," ",$tgtcy+$cos_ra * 1.5," ",$alt," ",$speed, $look, " &0\n";
	    }
	}
	else { #we come from north
	    if ($tgtcx-$landcoord[0]>=0){ # we land to the west
		print MIS "NORMFLY ", $tgtcx, " ", $tgtcy+$ra * 1.4, " ", $alt, " ", $speed, " &0\n";
		print MIS "NORMFLY ", $tgtcx, " ", $tgtcy-$ra, " ", $alt, " ", $speed, $look, " &0\n";
		print MIS "NORMFLY ", $tgtcx+$cos_ra, " ",$tgtcy+$cos_ra, " ", $alt, " ", $speed, " &0\n";
		print MIS "NORMFLY ", $tgtcx-$cos_ra * 1.5," ",$tgtcy-$cos_ra * 1.5," ",$alt," ",$speed, $look, " &0\n";
	    }
	    else { #we come from north, we land to the east
		print MIS "NORMFLY ", $tgtcx, " ", $tgtcy+$ra * 1.4, " ", $alt, " ", $speed, " &0\n";
		print MIS "NORMFLY ", $tgtcx, " ", $tgtcy-$ra, " ", $alt, " ", $speed, $look, " &0\n";
		print MIS "NORMFLY ", $tgtcx-$cos_ra, " ", $tgtcy+$cos_ra, " ", $alt, " ", $speed, " &0\n";
		print MIS "NORMFLY ", $tgtcx+$cos_ra * 1.5 ," ",$tgtcy-$cos_ra *1.5 ," ",$alt," ",$speed,$look, " &0\n";
	    }
	}

	# WP land -2 
# 	print MIS "NORMFLY ".$aproachlnd[0]." ".$aproachlnd[1]." 1000.00 300.00 &0\n";
	# WP land -1 
# 	print MIS "NORMFLY ".$beforelndwp[0]." ".$beforelndwp[1]." 500.00 250.00 &0\n";
	# WP Land 
	print MIS "LANDING ".$landcoord[0]." ".$landcoord[1]." 0.00 0.00 &0\n";
    }
    
}

# build bombers WP. this is not only for bombers, escorts (fighters) will have this waypoints too.
# The way points has a pattern: take off, fly to target return to base, and some pre bombing WP
# and aproach to land WP, etc...

sub bombers_wp($$$$) {
    my ($player,$tgtcx,$tgtcy,$mis_type) = @_ ;
    my 	$B_tgt_dist=0;
    my 	$B_home_dist=0;

#Armamos un aflist con los posibles AF de despegue para defensa tactica
#de aqui sale el vuelo de defensa (BD)  y ocpcional su la escolta (EBD)
#-------------
    my @aflist=();
    my $dist=0;
    my $afcode="NONE";
    my $af_is_ship=0;
    my $afcx;
    my $afcy;
    my $old_afcode;
    my $old_dist=0;

    my $radio="";                        # set in config.pl
    if ($player==1) {$radio=$VVS_RADIO;} # "&0" 50%  or  "&1" 50%
    if ($player==2) {$radio=$LW_RADIO;}  # "&0" 50%  or  "&1" 50%


    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
                 #AF01,aerodromo--F13,54552.79,128611.91,2,-F,13,2,0:2
	if ($_ =~ m/(AF[0-9]{2}),[^,]+,([^,]+),([^,]+),.*,([^,]+):([0-3])/){ #buscamos un AF cualquiera
	    if ($5==$player && $4<80) { # si es amigo y da~nos menor a 80%
		$dist= distance($tgtcx,$tgtcy,$2,$3); #calculamos distancia
		if ( ($dist < $MAX_BOMBERS_DIST) && ($dist >= $MIN_BOMBERS_DIST)){
		    if (no_enemy_af_close($player,$2,$3)){
			push (@aflist, "$1","$2","$3");
		    }
		}
	    }
	}
    }

    # Verificamos que la lista no este vacia. si es asi, buscamos el AG mas cercano y que dist >= MIN_BOMBER_DIST
    #---------
    if (scalar(@aflist)>0) { 
	my $azar=int(rand(scalar(@aflist)/3)); #CHECK: guarda /3 cambia si cambiamos la cant de datos por entrada en aflist
	$afcode=$aflist[$azar*3];
	$afcx=$aflist[$azar*3+1];
	$afcy=$aflist[$azar*3+2];
	$dist= distance($tgtcx,$tgtcy,$afcx,$afcy); #calculamos distancia
	$B_tgt_dist=$dist;
	$B_home_dist=$dist;
	seek GEO_OBJ, 0, 0;
	while(<GEO_OBJ>) {
	    if ($_ =~ m/$afcode,[^,]+,[^,]+,[^,]+,([0-9]),.*,[^:]+:[0-3]/){ #buscamos el AF y leemos typo
		if ($1==4){
		    $af_is_ship=1; # is a test runway (static ship)
		}
		last;
	    }
	}
    }
    else {
	$old_dist=500000;
	my $min_required=0;
	if ($mis_type eq "SUM") {$min_required=30000;} # only request a min distance for suply missions
	seek GEO_OBJ, 0, 0;
	while(<GEO_OBJ>) {
	    if ($_ =~ m/(AF[0-9]{2}),[^,]+,([^,]+),([^,]+),([0-9]),.*,([^:]+):([0-3])/){ #buscamos un AF dist 
		if ($6==$player && $5<80) { # si es amigo y da~nos menores a 80
		    $dist=  distance($tgtcx, $tgtcy, $2, $3); #calculamos distancia en Km
		    if (($dist < $old_dist) && ($dist >= $min_required)) { 
			$old_dist=$dist;
			$afcode=$1;
			$afcx=$2;
			$afcy=$3;
			if ($4==4) {$af_is_ship=1;}
			else {$af_is_ship=0;}
		    }
		}
	    }
	}
	$dist=$old_dist;
	$B_tgt_dist=$dist;
	$B_home_dist=$dist;
    }

    if ($afcode eq "NONE") { # esto no deberia ocurrir nunca a menos que un bando pierda todos los AF
	my $side="";
	if ($player==1) {$side="VVS (red)";}
	else {$side="LW (blue)";}
	print "$big_red Error: </font>  Can't shedule Bombers flight for $side side.<br>";
	print "This can happen because $side army has run out of airfield, or the only aviable airfiels are too close to the target. $side has to make a different request, where the place to attack (or suply) is more than 30km away.";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Can't shedule Bombers flight for $side side.\n\n";
	exit(0);
    }

# seleccion de la cabecera mas cercana al objetivo, seteamos landcood y takeoffcoord
# por ahora solo miramos en H1 la sig linea H2. Mas adelante expnadir a H3 y H4. CHECK
#-----------
    my @takeoffcoord=();
    my @landcoord=();

    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^$afcode:H1,([^,]+),([^,]+),/){ # por ahora solo miramos H1 
	    if ($af_is_ship==1 || distance($tgtcx,$tgtcy,$1,$2) <=$dist){ # despegue en cabecera H1 (always in ships)
		@takeoffcoord=(int($1),int($2));
		$_=readline(GEO_OBJ); #y la siguiente linea(H2)
		$_=~ m/^$afcode:H2,([^,]+),([^,]+),/;
		@landcoord=(int($1),int($2));
	    }
	    else {   #sino despegue en cabecera H2
		@landcoord=(int($1),int($2));
		$_=readline(GEO_OBJ);
		$_=~ m/^$afcode:H2,([^,]+),([^,]+),/;
		@takeoffcoord=(int($1),int($2));
	    }
	}
    }

    if ($player==1 && $red_af_count){ #si es un vuelo rojo y ya hay un af usado:
	if ( ($afcode eq $red_af1_code) && 
    	     (($takeoffcoord[0]!=$red_af1_cx)||($takeoffcoord[1]!=$red_af1_cy)) ){ #si selen del mismo af, pero != header
	    my @temp=@landcoord;
	    @landcoord=@takeoffcoord;
	    @takeoffcoord=@temp;
	}
    }
    if ($player==1 && $af_is_ship==1 && ($red_ship_af==0 ||$afcode ne $red_af1_code) ){
	$red_ship_af++;
	push(@red_ship_chosed,$afcode);
    }

    if ($player==2 && $blue_af_count){ #si es un vuelo azul y ya hay un af usado:
	if ( ($afcode eq $blue_af1_code) &&
	     (($takeoffcoord[0]!=$blue_af1_cx)||($takeoffcoord[1]!=$blue_af1_cy)) ){ # si selen del mismo af, pero != header
	    my @temp=@landcoord;
	    @landcoord=@takeoffcoord;
	    @takeoffcoord=@temp;
	}
    }
    if ($player==2 && $af_is_ship==1 && ($blue_ship_af==0 ||$afcode ne $blue_af1_code) ){
	$blue_ship_af++;
	push(@blue_ship_chosed,$afcode);
    }
 
# una vez definido cual es el AF de despegue de grupo ataque , guardar coord para poblar.
#-----------
    if ($player==1){
	$red_af_count++;
	if ($red_af_count==1) {
	    $red_af1_code=$afcode;
	    $red_af1_cx=$takeoffcoord[0];
	    $red_af1_cy=$takeoffcoord[1];
	}
	else { # es el af nro dos
	    $red_af2_code=$afcode;
	    $red_af2_cx=$takeoffcoord[0];
	    $red_af2_cy=$takeoffcoord[1];
	}
    }
    else {
	$blue_af_count++;
	if ($blue_af_count==1) {
	    $blue_af1_code=$afcode;
	    $blue_af1_cx=$takeoffcoord[0];
	    $blue_af1_cy=$takeoffcoord[1];
	}
	else {
	    $blue_af2_code=$afcode;
	    $blue_af2_cx=$takeoffcoord[0];
	    $blue_af2_cy=$takeoffcoord[1];
	}
	    
    }


#definimos el wp despues de despegar (aftertoffwp) 
#-----------
    my @aftertoffwp=($takeoffcoord[0]+(int($takeoffcoord[0]-$afcx)*12),
		  $takeoffcoord[1]+(int($takeoffcoord[1]-$afcy)*12));

    # si el AF desde donde salimos esta a mas de XX kilometros, 
    # tratamos de aterrizar en uno + cercano
    my $DIST_LIM=10000; # si vemos desde mas de esta distancia  buscar AF regreso alternativo
    if ($dist>$DIST_LIM) {  # 
	$old_afcode=$afcode;
	$old_dist=$dist;
	@aflist=(); # armamos una nueva lista
	seek GEO_OBJ, 0, 0;
	while(<GEO_OBJ>) {
	if ($_ =~ m/(AF[0-9]{2}),[^,]+,([^,]+),([^,]+),2,.*,([^,]+):([0-3])/){ #buscamos un AF cualquiera (type 2 normal)
	    if ($5==$player) { # si es amigo 
		    $dist=  distance($tgtcx, $tgtcy, $2, $3); #calculamos distancia en Km
		    if ($dist < $old_dist) {
			$old_dist=$dist;
			$afcode=$1;
			$afcx=$2;
			$afcy=$3;
			$B_home_dist=$dist;
		    }
		}
	    }
	}

	# aca setear nuevas coordenadas del nuevo AF para poblar. CHECK
	if ($afcode ne $old_afcode) { # si no es el mismo que antes
	    if ($player==1) {
		if ($red_af3_code eq "") { # si el 3er af no esta usado..
		    $red_af3_code=$afcode;
		    $red_af3_cx=$afcx;
		    $red_af3_cy=$afcy;
		}
		else { # sino usamos usamos un 4to
		    $red_af4_code=$afcode;
		    $red_af4_cx=$afcx;
		    $red_af4_cy=$afcy;
		}
	    }
	    else { # para azul
		if ($blue_af3_code eq "") { # si el 3er af no esta usado..
		    $blue_af3_code=$afcode;
		    $blue_af3_cx=$afcx;
		    $blue_af3_cy=$afcy;
		}
		else { # sino usamos un 4to
		    $blue_af4_code=$afcode;
		    $blue_af4_cx=$afcx;
		    $blue_af4_cy=$afcy;
		}
	    }
	    seek GEO_OBJ, 0, 0;
	    while(<GEO_OBJ>) {
		if ($_ =~ m/^$afcode:H1,([^,]+),([^,]+),/){ # por ahora solo miramos H1 
		    if (distance($tgtcx,$tgtcy,$1,$2) >$dist){ # aterrizaje en cabecera H1 + alejada
			@landcoord=(int($1),int($2));
		    }
		    else {   #sino aterrizaje en  cabecera H2
			$_=readline(GEO_OBJ);
			$_=~ m/^$afcode:H2,([^,]+),([^,]+),/;
			@landcoord=(int($1),int($2));
		    }
		    last; #version 24 optim change
		}
	    }
	}
    }

# aqui landcoor estan definidas, previamente o por el ultimo AF alternativo.
# asi que definimos el wp  anterior al aterrizaje (beforelandwp)=final
#--------
    my @beforelndwp=($landcoord[0]+(int($landcoord[0]-$afcx)*12),
		  $landcoord[1]+(int($landcoord[1]-$afcy)*12));

    
    
# definimos un WP previo al la final, llamado aproachlnd
#-----------
    
#vector normal
    my @aproachlnd=($beforelndwp[0]+($landcoord[1]-$beforelndwp[1])/2,
		 $beforelndwp[1]-($landcoord[0]-$beforelndwp[0])/2);
    
    if(sqrt(($tgtcx-$beforelndwp[0])**2+($tgtcy-$beforelndwp[1])**2) <
       sqrt(($tgtcx-$aproachlnd[0])**2+($tgtcy-$aproachlnd[1])**2)){ # si aproach es  mas lejano q' before, invertir vector
	@aproachlnd=($beforelndwp[0]-($landcoord[1]-$beforelndwp[1])/2,
		     $beforelndwp[1]+($landcoord[0]-$beforelndwp[0])/2);
    }
    
    
# verificamos que los wp cercanos al AF  no sean negativos (mapa izq o mapa abajo) 
# ni tampoco mayores a MAP_TOP y MAP_RIGHT (mejorar estoooo! ) CHECK
#-----------
    while ( $aftertoffwp[0]<0){$aftertoffwp[0]+=1000;}
    while ( $aftertoffwp[1]<0){$aftertoffwp[1]+=1000;}
    while ( $aftertoffwp[0]>$MAP_RIGHT){$aftertoffwp[0]-=1000;}
    while ( $aftertoffwp[1]>$MAP_TOP){$aftertoffwp[1]-=1000;}
    
    while ( $beforelndwp[0]<0){$beforelndwp[0]+=1000;}
    while ( $beforelndwp[1]<0){$beforelndwp[1]+=1000;}
    while ( $beforelndwp[0]>$MAP_RIGHT){$beforelndwp[0]-=1000;}
    while ( $beforelndwp[1]>$MAP_TOP){$beforelndwp[1]-=1000;}
    
    while ( $aproachlnd[0]<0){ $aproachlnd[0]+=1000;}
    while ( $aproachlnd[1]<0){ $aproachlnd[1]+=1000;}
    while ( $aproachlnd[0]>$MAP_RIGHT){$aproachlnd[0]-=1000;}
    while ( $aproachlnd[1]>$MAP_TOP){$aproachlnd[1]-=1000;}
    
    #definimos los valores de aproximacion al objetivo. con estos 2 valores obtenemos
    # los 2 WP antes y depues del ataque.
    #-----------
    my $aproxx=0;
    my $aproxy=0;

    if ((abs(abs($tgtcx-$takeoffcoord[0])- abs($tgtcy-$takeoffcoord[1])))<($dist/2)){ # ~ angulos de 45grad +/- 20
	if ($takeoffcoord[0]<$tgtcx) {
	    $aproxx=-9000 + int(rand(4000)); # -7000 +/- 2000
	}
	else {
	    $aproxx=9000 - int(rand(4000)); # +7000 +/- 2000
	}
	$aproxy=int(sqrt(15000**2-($aproxx)**2))*((-1)**int(rand(2)));    
    }
    else { # angulos cercanos a 0, 180, 90 y 270
	if ( abs($tgtcx-$takeoffcoord[0])>=abs($tgtcy-$takeoffcoord[1]) ){ # angulos cercanos a 0, 180 (Este-Oeste en FB)
	    $aproxx=int(rand(6000));
	    if ($tgtcx>=$takeoffcoord[0]){
		$aproxx=-$aproxx;
	    }
	    $aproxy=int(sqrt(15000**2-($aproxx)**2))*((-1)**int(rand(2)));    
	}
	else { # angulos cercanos a 90, 2700 (Norte-Sur en FB)
	    $aproxy=int(rand(6000));
	    if ($tgtcy>=$takeoffcoord[1]){
		$aproxy=-$aproxy;
	    }
	    $aproxx=int(sqrt(15000**2-($aproxy)**2))*((-1)**int(rand(2)));    
	}
    }
    
# verificar que los 2 WP de aproximacion  no sean negativos (mapa izq o mapa abajo) 
# o mayores a MAP_TOP y MAP_RIGHT. En caso de serlo, invertimos el signo (CHECK: anda bien esto??!) 
#----------
    if (($tgtcx+$aproxx)<0 ||($tgtcx+$aproxx>$MAP_RIGHT)){
	$aproxx=-$aproxx;
    }
    if (($tgtcy+$aproxy)<0 ||($tgtcy+$aproxy>$MAP_TOP)){
	$aproxy=-$aproxy;
    }
    
    
# Antes de comenzar a escribir los WP del vuelo de ataque, debemos encontrar
# el obketivo en caso de ataque puntual. Para atace estrategico, con muchos
#objetivos en la zona no hace falta. (CHECK: seguro? y los dive bombers?)

    my $tgt_name="";
    my $tgt_name_2="";
    #tratamos de adivinar cual es el chief si atacamos tanques
    if ($grplst[0] eq "BD" || $grplst[0] eq "EBD" ){ # si se trata de BD = enemigos mandan tanques...(guarda!! uso def [0])
	if ($player==1) { # si es vuelo es rojo
	    if ($RED_ATTK_TACTIC==1) { #si los rojos  enviaron tanques
		$tgt_name=($red_tanks_groups+1)."_Chief 1"; # $red_tanks_groups apunta al primer grupo tank blue
		$tgt_name_2=($red_tanks_groups+3)."_Chief 1"; 
	    }
	    else {
		$tgt_name="0_Chief 1"; #  si no hay tankes rojos los azules empiezan en 0
		$tgt_name_2="2_Chief 1"; 
	    }
	}
	else { # player es azul
	    $tgt_name="0_Chief 1"; # como los tanques rojos se colocan siempre primero
	    $tgt_name_2="2_Chief 1"; 
	}
    }

# para cada grupo bomber, recon o escolta imprimimos los WP
#----------
    my $groups= (scalar(@grplst)/$grpentries);
    my $i=0;
    for ( $i=0; $i<$groups; $i++){ 
	print MIS "[".$grplst[$grpentries*$i+1]."]\n";
	print MIS "  Planes ".$grplst[$grpentries*$i+2]."\n";
	if ($grplst[$grpentries*$i+3] eq "1") {print MIS "  OnlyAI 1\n";}
	print MIS "  Skill ".$grplst[$grpentries*$i+4]."\n";
	print MIS "  Class ".$grplst[$grpentries*$i+5]."\n";
	print MIS "  Fuel ".$grplst[$grpentries*$i+6]."\n";
	print MIS "  weapons ".$grplst[$grpentries*$i+7]."\n";
	print MIS "[".$grplst[$grpentries*$i+1]."_Way]\n";
	
	# WP 0
	if ($af_is_ship==1){  
	    print MIS "TAKEOFF ".$takeoffcoord[0]." ".$takeoffcoord[1]." 0.00 0.00 ".
		($red_ship_af+$blue_ship_af-1)."_Static 0 &0\n";
	}
	else {
	    print MIS "TAKEOFF ".$takeoffcoord[0]." ".$takeoffcoord[1]." 0.00 0.00  &0\n";
	}
	my $speed=$grplst[$grpentries*$i+9];
	
	# WP 1
	print MIS "NORMFLY ".$aftertoffwp[0]." ".$aftertoffwp[1]." 500.00 $speed "; 
	if ($i>0 && $grplst[$grpentries*$i+0] ne "BD"){ # si no es 1er grupo y es escolta
	    print MIS " $grplst[1] 1"; 
	} 
	print MIS "$radio\n";
	
	my $alt=$grplst[8]; 
	if (($grplst[$grpentries*$i+0] eq "EBD")||($grplst[$grpentries*$i+0] eq "EBA")||
	    ($grplst[$grpentries*$i+0] eq "ER") ){
	    $alt+=1000; # escolta 100 metros + arriba del grupo de ataque
	}

	# WP 2 (solo si NO son SUM o ESU)
	#if ( ! (($grplst[$grpentries*$i+0] eq "SUM") || ($grplst[$grpentries*$i+0] eq "ESU")) ) {
	#    print MIS "NORMFLY ".int($tgtcx+$aproxx)." ".int($tgtcy+$aproxy)." ".$alt." ".$speed;
	#    if ($i>0) { # si no es el bomber lider, es el segundo o el escolta
	#	print MIS " $grplst[1] 2"; #GUARDA USO SUPUESTO *NOMBRE BOMBER* LIDER - CHECK
	#    } 
	#    print MIS "\n";
	#}

	# WP 3
	if ( ($grplst[$grpentries*$i+0] eq "BA")) {
	    print MIS "GATTACK ".int($tgtcx)." ".int($tgtcy)." ".$alt." ".$speed." ".$tgt_name." &0\n";
	} #tgt_name sera el grupo de tanuqes (BD) o nada para (BA) asi hacen level bomb

	if ($i && $grplst[$grpentries*$i+0] eq "BD")  {
	    print MIS "GATTACK ".int($tgtcx)." ".int($tgtcy)." ".$alt." ".$speed." ".$tgt_name_2." &0\n";
	}
	elsif ($grplst[$grpentries*$i+0] eq "BD")  {
	    print MIS "GATTACK ".int($tgtcx)." ".int($tgtcy)." ".$alt." ".$speed." ".$tgt_name." &0\n";
	}

	if ( ($grplst[$grpentries*$i+0] eq "EBD")||($grplst[$grpentries*$i+0] eq "EBA")||
	     ($grplst[$grpentries*$i+0] eq "ER") ||($grplst[$grpentries*$i+0] eq "ESU") ){  
	    print MIS "NORMFLY ".int($tgtcx)." ".int($tgtcy)." ".$alt." ".$speed." ".$grplst[1]." 3 &0\n"; #GUARDA [1] check
	}
	if (($grplst[$grpentries*$i+0] eq "R")|| ($grplst[$grpentries*$i+0] eq "SUM") ) {
	    print MIS "NORMFLY ".int($tgtcx)." ".int($tgtcy)." ".$alt." ".$speed." &0\n";
	}
	
	# WP 4
	print MIS "NORMFLY ".$aproachlnd[0]." ".$aproachlnd[1]." 1000.00 $speed &0\n";
	# WP 5
	print MIS "NORMFLY ".$beforelndwp[0]." ".$beforelndwp[1]." 500.00 ".(int($speed *.70))." &0\n";
	# WP 6
	print MIS "LANDING ".$landcoord[0]." ".$landcoord[1]." 0.00 0.00 &0\n";
    }


    if ( $grplst[0] eq "SUM" ) {
	if ($player==1 && $red_target =~ m/SUM-/ && $red_bom_attk_ai==1 && $RED_SUM_AI_LAND eq "") {
	    $RED_SUM_AI_LAND=$afcode;
	}
	if ($player==2 && $blue_target =~ m/SUM-/ && $blue_bom_attk_ai==1 && $BLUE_SUM_AI_LAND eq "") {
	    $BLUE_SUM_AI_LAND=$afcode;
	}
    }

    return ((int($B_tgt_dist/100)/10),(int($B_home_dist/100)/10));
}

sub add_test_runways() {  # runways that are static ships
    my $i;
    my $object;
    my $afcode;
    my $rw_data;

    $object="_Static ships.Ship\$RwySteel 1 ";  # allied AF
    for ($i=0; $i<$red_ship_af; $i++){
	$afcode= shift @red_ship_chosed;
	$afcode="DATA_".$afcode;
	seek GEO_OBJ, 0, 0; 
	while(<GEO_OBJ>) {
	    if ($_ =~ m/^$afcode:([^:]+):/){ # AF ship data
		$rw_data=$1;
		last;
	    }
	}
	print MIS $s_obj_counter.$object.$rw_data."\n";
	$s_obj_counter++;
    }

    $object="_Static ships.Ship\$RwySteel 2 ";  # axis AF
    for ($i=0; $i<$blue_ship_af; $i++){
	$afcode= shift @blue_ship_chosed;
	$afcode="DATA_".$afcode;
	seek GEO_OBJ, 0, 0; 
	while(<GEO_OBJ>) {
	    if ($_ =~ m/^$afcode:([^:]+):/){ # AF ship data
		$rw_data=$1;
		last;
	    }
	}
	print MIS $s_obj_counter.$object.$rw_data."\n";
	$s_obj_counter++;
    }
}

#this places a staic JU52 or a LI2 on each airfield and sirens
#Only to make AF get a correct army color (not white)
sub obj_id_airfields() {
    my $objet;
    my $marker_x;
    my $marker_y;
    my $sirena="_Static vehicles.stationary.Siren\$SirenCity ";
    seek RED_OBJ, 0, 0;
    while(<RED_OBJ>) {
	if ($_ =~ m/ *[0-9]+(_Static vehicles.planes.Plane\$LI_2 1 ([^ ]+) ([^ ]+) .*)$/) {
	    $object=$1;
	    $marker_x=$2;
	    $marker_y=$3;
	    seek GEO_OBJ, 0, 0;
	    while(<GEO_OBJ>) {
		if ($_ =~  m/AF.{2},[^,]+,([^,]+),([^,]+),[^:]*:1.*$/) {
		    if (distance($marker_x,$marker_y,$1,$2)<2000){
			print MIS $s_obj_counter.$object."\n";
			$s_obj_counter++;
                        print MIS $s_obj_counter.$sirena."1 ".$marker_x." ".$marker_y." 0 0\n";
			$s_obj_counter++;
			last; #version 24 optim change
		    }
		}
	    }
	}
    }
    seek BLUE_OBJ, 0, 0;
    while(<BLUE_OBJ>) {
	if ($_ =~ m/ *[0-9]+(_Static vehicles.planes.Plane\$JU_52_3MG4E 2 ([^ ]+) ([^ ]+) .*)$/) {
	    $object=$1;
	    $marker_x=$2;
	    $marker_y=$3;
	    seek GEO_OBJ, 0, 0;
	    while(<GEO_OBJ>) {
		if ($_ =~  m/AF.{2},[^,]+,([^,]+),([^,]+),[^:]*:2.*$/) {
		    if (distance($marker_x,$marker_y,$1,$2)<2000){
			print MIS $s_obj_counter.$object."\n";
			$s_obj_counter++;
                        print MIS $s_obj_counter.$sirena."2 ".$marker_x." ".$marker_y." 0 0\n";
			$s_obj_counter++;
			last; #version 24 optim change
		    }
		}
	    }
	}
    }
}

# place static objects on airfields
sub poblate_airfield ($) {
    my $afcode = shift(@_) ;

    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/$afcode,.*,([^,]+):([0-2])/) {
	    my $damage=$1;
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " poblate_airfield(" . $afcode . "): Damage=" . $damage. "\n";	    
	    my $army=$2;
	    $_=readline(GEO_OBJ); #y la siguiente linea(H1) CHECK
	    $_ =~ m/^AF[0-9]{2}:H1,([^,]+),([^,]+),/;
	    my $coord_xh1=$1;
	    my $coord_yh1=$2;
	    $_=readline(GEO_OBJ); #y la siguiente linea(H2) CHECK
	    $_ =~ m/^AF[0-9]{2}:H2,([^,]+),([^,]+),/;
	    my $coord_xh2=$1;
	    my $coord_yh2=$2;
	    my $vector_x = ($coord_xh1 - $coord_xh2);
	    my $vector_y = ($coord_yh1 - $coord_yh2);
	    my $modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
	    $vector_x/=$modulo;
	    $vector_y/=$modulo;
	    my $normal_x=$vector_y;
	    my $normal_y=-$vector_x;
	    my $metros=200;
	    my $aaa_radio=$metros * 0.707; 
	    my $object_low;
	    my $object_medium;
	    my $object_high;
	    if ($army==1) {
		$object_low="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		$object_medium="_Static vehicles.artillery.Artillery\$Zenit61K 1 ";
		$object_high="_Static vehicles.artillery.Artillery\$Zenit85mm_1939 1 ";
	    }
	    else {
		$object_low="_Static vehicles.artillery.Artillery\$Flak38_20mm 2 ";
		$object_medium="_Static vehicles.artillery.Artillery\$Flak18_37mm 2 ";
		$object_high="_Static vehicles.artillery.Artillery\$Flak18_88mm 2 ";
	    }
	    my $aaa_x;
	    my $aaa_y;
	    #header 1 +45 grados = 25 mm
	    $aaa_x = int($coord_xh1 + $aaa_radio*($vector_x + $normal_x));
	    $aaa_y = int($coord_yh1 + $aaa_radio*($vector_y + $normal_y));
	    print MIS $s_obj_counter.$object_low.$aaa_x." ".$aaa_y." 0 0\n";
	    $s_obj_counter++;
	    if ($damage<=80) {
		#header 1 -45 grados = 25 mm
		$aaa_x = int($coord_xh1 + $aaa_radio*($vector_x - $normal_x));
		$aaa_y = int($coord_yh1 + $aaa_radio*($vector_y - $normal_y));
		print MIS $s_obj_counter.$object_low.$aaa_x." ".$aaa_y." 0 0\n";
		$s_obj_counter++;
		if ($damage<=50) {
		    #header 2 +45 grados = 25 mm
		    $aaa_x = int($coord_xh2 + $aaa_radio*(-$vector_x + $normal_x));
		    $aaa_y = int($coord_yh2 + $aaa_radio*(-$vector_y + $normal_y));
		    print MIS $s_obj_counter.$object_low.$aaa_x." ".$aaa_y." 0 0\n";
		    $s_obj_counter++;

		    #header 2 +45 grados +radio mayor = 25 mm
		    $aaa_x = int($coord_xh2 + $aaa_radio*(- 2*$vector_x + $normal_x));
		    $aaa_y = int($coord_yh2 + $aaa_radio*(- 2*$vector_y + $normal_y));
		    print MIS $s_obj_counter.$object_low.$aaa_x." ".$aaa_y." 0 0\n";
		    $s_obj_counter++;
		    
		    #header 2 +45 grados +radio mayor = 25 mm
		    $aaa_x = int($coord_xh2 + $aaa_radio*(- $vector_x + 2* $normal_x));
		    $aaa_y = int($coord_yh2 + $aaa_radio*(- $vector_y + 2*$normal_y));
		    print MIS $s_obj_counter.$object_low.$aaa_x." ".$aaa_y." 0 0\n";
		    $s_obj_counter++;
		    
		    if ($damage<=20) {
			#header 2 -45 grados = 25 mm
			$aaa_x = int($coord_xh2 + $aaa_radio*(-$vector_x - $normal_x));
			$aaa_y = int($coord_yh2 + $aaa_radio*(-$vector_y - $normal_y));
			print MIS $s_obj_counter.$object_low.$aaa_x." ".$aaa_y." 0 0\n";
			$s_obj_counter++;
			
			
			#header 1 -45 grados + radio mayor = 25 mm
			$aaa_x = int($coord_xh1 + $aaa_radio*(2*$vector_x - $normal_x));
			$aaa_y = int($coord_yh1 + $aaa_radio*(2*$vector_y - $normal_y));
			print MIS $s_obj_counter.$object_low.$aaa_x." ".$aaa_y." 0 0\n";
			$s_obj_counter++;
			
			#header 1 -45 grados + radio mayor = 25 mm
			$aaa_x = int($coord_xh1 + $aaa_radio*($vector_x - 2*$normal_x));
			$aaa_y = int($coord_yh1 + $aaa_radio*($vector_y - 2*$normal_y));
			print MIS $s_obj_counter.$object_low.$aaa_x." ".$aaa_y." 0 0\n";
			$s_obj_counter++;
			
		    }
		}
	    }
	    
	    # @Heracles@20110411
	    # Posicionamiento de AAA media
	    if ($damage<=80) {
		#header 1 +45 grados + radio super = 37 mm
		$aaa_x = int($coord_xh1 + $aaa_radio*(4*$vector_x + $normal_x));
		$aaa_y = int($coord_yh1 + $aaa_radio*(4*$vector_y + $normal_y));
		print MIS $s_obj_counter.$object_medium.$aaa_x." ".$aaa_y." 0 0\n";
		$s_obj_counter++;
		if ($damage<=50) {
		    #header 1 +45 grados + radio super = 37 mm
		    $aaa_x = int($coord_xh1 + $aaa_radio*($vector_x + 4*$normal_x));
		    $aaa_y = int($coord_yh1 + $aaa_radio*($vector_y + 4*$normal_y));
		    print MIS $s_obj_counter.$object_medium.$aaa_x." ".$aaa_y." 0 0\n";
		    $s_obj_counter++;		    
		}
	    }
	    
	    if ($damage<=80) {
		#header 1 +45 grados + radio mayor = 85 mm
		$aaa_x = int($coord_xh1 + $aaa_radio*(2*$vector_x + $normal_x));
		$aaa_y = int($coord_yh1 + $aaa_radio*(2*$vector_y + $normal_y));
		print MIS $s_obj_counter.$object_high.$aaa_x." ".$aaa_y." 0 0\n";
		$s_obj_counter++;
		if ($damage<=50) {
		    #header 1 +45 grados + radio mayor = 85 mm
		    $aaa_x = int($coord_xh1 + $aaa_radio*($vector_x + 2*$normal_x));
		    $aaa_y = int($coord_yh1 + $aaa_radio*($vector_y + 2*$normal_y));
		    print MIS $s_obj_counter.$object_high.$aaa_x." ".$aaa_y." 0 0\n";
		    $s_obj_counter++;
		    if ($damage<=20) {
			#header 2 -45 grados + radio mayor = 85 mm
			$aaa_x = int($coord_xh2 + $aaa_radio*(2*-$vector_x - $normal_x));
			$aaa_y = int($coord_yh2 + $aaa_radio*(2*-$vector_y - $normal_y));
			print MIS $s_obj_counter.$object_high.$aaa_x." ".$aaa_y." 0 0\n";
			$s_obj_counter++;
			# @Heracles@20110411@
			# More AAA. This is hell...
			#header 2 -45 grados + radio super = 85 mm
			$aaa_x = int($coord_xh2 + $aaa_radio*(4*-$vector_x - $normal_x));
			$aaa_y = int($coord_yh2 + $aaa_radio*(4*-$vector_y - $normal_y));
			print MIS $s_obj_counter.$object_high.$aaa_x." ".$aaa_y." 0 0\n";
			$s_obj_counter++;
			if ($damage<=10) {
			    #header 2 -45 grados + radio mayor = 85 mm
			    $aaa_x = int($coord_xh2 + $aaa_radio*(-$vector_x - 2*$normal_x));
			    $aaa_y = int($coord_yh2 + $aaa_radio*(-$vector_y - 2*$normal_y));
			    print MIS $s_obj_counter.$object_high.$aaa_x." ".$aaa_y." 0 0\n";
			    $s_obj_counter++;
			    # @Heracles@20110411@
			    # More AAA. This is hell...
			    #header 2 -45 grados + radio super = 85 mm
			    $aaa_x = int($coord_xh2 + $aaa_radio*(-$vector_x - 4*$normal_x));
			    $aaa_y = int($coord_yh2 + $aaa_radio*(-$vector_y - 4*$normal_y));
			    print MIS $s_obj_counter.$object_high.$aaa_x." ".$aaa_y." 0 0\n";
			    $s_obj_counter++;			    
			}
		    }
		}
	    }
            # aca ya terminamos de poner la aaa. ahora ponemos 2 sirenas, una en cada header
	    my $sir="_Static vehicles.stationary.Siren\$SirenCity ";
	    print MIS $s_obj_counter.$sir.$army." ".int($coord_xh1+30*$vector_x)." ".int($coord_yh1+30*$vector_y)." 0 0\n";
	    $s_obj_counter++;
	    print MIS $s_obj_counter.$sir.$army." ".int($coord_xh2-30*$vector_x)." ".int($coord_yh2-30*$vector_y)." 0 0\n";
	    $s_obj_counter++;

	    if ($hora>=17 || $hora<=7 || $clima>90) {
		my $fd=50;
		my $fc;
		$sir="_Static vehicles.stationary.Campfire\$CampfireAirfield 0 ";
		for ($fc=0; $fc<10 ; $fc++){
		    print MIS $s_obj_counter.$sir.
			int($coord_xh1+$fd*$vector_x)." ".int($coord_yh1+$fd*$vector_y)." 0 0\n";
		    $s_obj_counter++;
		    print MIS $s_obj_counter.$sir.
			int($coord_xh2-$fd*$vector_x)." ".int($coord_yh2-$fd*$vector_y)." 0 0\n";
		    $s_obj_counter++;
		    $fd+=5;
		}
	    }

	    # terminado las sirenas,ponemos los aviones estaticos segun park places (P[0-9])
	    my $coord_p1x;
	    my $coord_p1y;
	    my $coord_p2x;
	    my $coord_p2y;

	  NEXT:
	    $_=readline(GEO_OBJ); #y la siguiente a H2 -> park coord -  CHECK
	    if ($_!~ m/^AF[0-9]{2}:P[0-9],([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),/){ # si no hat park area, ir a prox AF
		; # nada
	    }
	    else {
		$coord_p1x=$1;
		$coord_p1y=$2;
		$coord_p2x=$3;
		$coord_p2y=$4;
		$angle=$5;
		
		$vector_x = ($coord_p2x - $coord_p1x);
		$vector_y = ($coord_p2y - $coord_p1y);
		$modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
		$vector_x/=$modulo;
		$vector_y/=$modulo;

		my $to_place=0;
		my $obj_nr=0;
		my $wspan=0; 
		my $m_usados=0; # metros usados
		while ($m_usados+15<$modulo){ # mientras nos queden 15 metros disponibles...

		    if ($to_place==0) { #seleccionamos un bojeto con su correpondiente wspan si no hay to_place
			$to_place=int(rand(3)+2); # de 2 a 5 objetos
			$obj_nr=int(rand(1000)+1); # objeto al azar de 1 a 1000 ;
			if ($army==1) {  # base roja
			    seek FLIGHTS,0,0;  #ST100,1,I153,vehicles.planes.Plane$I_153_M62,15:150		
			    while(<FLIGHTS>) {
				if ( $_ =~ m/ST1[0-9]{2},$army,[^,]+,([^,]+),([^,]+):([0-9]+)/){
				    if ($obj_nr<=$3){
					$wspan=$2;
					$object=$1;
					last;
				    }
				}
			    }
			}
			else {
			    if ($army==2) { # base azul
				seek FLIGHTS,0,0;  #ST203,2,FW189,vehicles.planes.Plane$FW_189A2,25:500
				while(<FLIGHTS>) {
				    if ( $_ =~ m/ST2[0-9]{2},$army,[^,]+,([^,]+),([^,]+):([0-9]+)/){
					if ($obj_nr<=$3){
					    $wspan=$2;
					    $object=$1;
					    last;
					}
				    }
				}
			    }
			}
		    }
		    #avanzamos medio wingspan,
		    $coord_p1x +=($wspan/2*$vector_x);
		    $coord_p1y +=($wspan/2*$vector_y); 

		    #colocamos avion u otro objeto siponible, como un camion de fuel
		    print MIS $s_obj_counter."_Static ".$object." ".$army." ".int($coord_p1x).
			" ".int($coord_p1y)." ".$angle." 0\n";
		    $s_obj_counter++;
		    $to_place--;

		    #avanzamos medio wingspan + 4 metros + $da~nos/4 = cuanto mas da~nada menos objetos.
		    $coord_p1x +=((4+$damage/8+$wspan/2)*$vector_x);
		    $coord_p1y +=((4+$damage/8+$wspan/2)*$vector_y); 
		    $m_usados+=$wspan+4+$damage/8;		    
		}
		goto NEXT; # Buscar nuevo park point
	    }
	    last; #version 24 optim change
	}
    }
}

# find wp for tanks 
sub find_tank_wp($$$){
    my ($army, $tgt_cx, $tgt_cy) =@_;

    if (! (open (TKWP, "<$TANKS_WP"))){
	print "$big_red Error: </font>  Can't open File : $TANKS_WP : $!\n";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Can't open File : $TANKS_WP : $! \n\n";
	exit(0);
    }
    my @wplist=();

    seek TKWP,0,0;
    while (<TKWP>) {
	if ($_=~ m/ *[0-9]+_Static [^ ]+ [12] ([^ ]+) ([^ ]+) [^ ]+ [^ ]+/) {
	    if ( $1<($tgt_cx+5000) && $1>($tgt_cx-5000) && $2<($tgt_cy+5000) && $2>($tgt_cy-5000)){ #encontramos un wp
		push (@wplist,$1,$2);
	    }
	}
    }
    if ((scalar(@wplist)/2)<2) { 
	print  "$big_red Error: </font> Can't find 2 WP for tanks. Maybe NOATTK sector o bad template. X: $tgt_cx Y: $tgt_cy\n"; 
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " ERROR: Can't find 2 WP for tanks. Maybe NOATTK sector o bad template. X: $tgt_cx Y: $tgt_cy \n\n"; 
	exit(0);
    }

    my $orig=int(rand(scalar(@wplist)/2));
    my $dest=int(rand(scalar(@wplist)/2));
    while ($dest==$orig) {
	$dest=int(rand(scalar(@wplist)/2)); # hasta que no tengamos dos distintos
    }
    #seteamos los wp de tanques globales.
    if ($army==1) {
	push (@red_tank_wp,$wplist[$orig*2],$wplist[$orig*2+1],$wplist[$dest*2],$wplist[$dest*2+1]);
    }
    else{
	push (@blue_tank_wp,$wplist[$orig*2],$wplist[$orig*2+1],$wplist[$dest*2],$wplist[$dest*2+1]);
    }
    close(TKWP);
}

# print tanks (chiefs) into mission file
sub add_tanks(){
    my $i;

    #primero para rojo
    if ($RED_ATTK_TACTIC==1) {
	find_tank_wp(1,$red_tgtcx,$red_tgtcy);

	my $tank_chief_name="";
	$tank_chief_name="_Chief $ALLIED_TANKS_ATTK";

	for ($i=0; $i<$red_tanks_groups; $i++){
	    print MIS "  ".$chief_counter.$tank_chief_name." 1\n"; 
	    print DET "redchf ".$chief_counter."_Chief\n";
	    $chief_counter++;
	}
    }
    #luego azul
    if ($BLUE_ATTK_TACTIC==1) {
	find_tank_wp(2,$blue_tgtcx,$blue_tgtcy);

	my $tank_chief_name="";
	$tank_chief_name="_Chief $AXIS_TANKS_ATTK";

	for ($i=0; $i<$blue_tanks_groups; $i++){
	    print MIS "  ".$chief_counter.$tank_chief_name." 2\n";  # vs BT7
	    print DET "bluchf ".$chief_counter."_Chief\n";
	    $chief_counter++;
	}
    }

    my $chf=0;
    my $delta=100; # metros de separacion entre grupo de tanques
    if ($delta < $CHAMP_RAD) {$delta=$CHAMP_RAD+20;} # asegurarse que flanqueen el campamento

    if ($RED_ATTK_TACTIC==1) {

	my $vector_x = ($red_tank_wp[2] -$red_tank_wp[0]);
	my $vector_y = ($red_tank_wp[3] -$red_tank_wp[1]);
	my $modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
	$vector_x/=$modulo;  # modulo cant be 0 because wp1 != wp2
	$vector_y/=$modulo;
	my $normal_x=$vector_y;
	my $normal_y=-$vector_x;
	my $grp=-1;    
	my $stop_dist=20;

	for ($i=0; $i<$red_tanks_groups; $i++){
	    if ($i==0) {$stop_dist=-$CHAMP_RAD;}
	    if ($i==1) {$stop_dist=120;}
	    if ($i==2) {$stop_dist=-$CHAMP_RAD;}

	    print MIS "[".$chf."_Chief_Road]\n";
	    print MIS "  ".(int($red_tank_wp[0] + $grp * $delta * $normal_x))." ".
		(int($red_tank_wp[1] + $grp * $delta * $normal_y))." 120 5 2 2.0\n"; #con delay de 5 minutos
	    print MIS "  ".(int($red_tank_wp[2] + $grp * $delta * $normal_x - ($CHAMP_RAD+$stop_dist) * $vector_x))." ".
		(int($red_tank_wp[3] + $grp * $delta * $normal_y - ($CHAMP_RAD+$stop_dist) * $vector_y))." 120\n";
	    $chf++;
	    $grp++;
	}
    }

    if ($BLUE_ATTK_TACTIC==1) {

	my $vector_x = ($blue_tank_wp[2] -$blue_tank_wp[0]);
	my $vector_y = ($blue_tank_wp[3] -$blue_tank_wp[1]);
	my $modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
	$vector_x/=$modulo; # modulo cant be 0 because wp1 != wp2
	$vector_y/=$modulo;
	my $normal_x=$vector_y;
	my $normal_y=-$vector_x;
	my $grp=-1;    
	my $stop_dist=20;

	for ($i=0; $i<$blue_tanks_groups; $i++){
	    if ($i==0) {$stop_dist=-$CHAMP_RAD;}
	    if ($i==1) {$stop_dist=120;}
	    if ($i==2) {$stop_dist=-$CHAMP_RAD;}

	    print MIS "[".$chf."_Chief_Road]\n";
	    print MIS "  ".(int($blue_tank_wp[0] + $grp * $delta * $normal_x))." ".
		(int($blue_tank_wp[1] + $grp * $delta * $normal_y))." 120 5 2 2.0\n"; #con delay de 5 minutos
	    print MIS "  ".(int($blue_tank_wp[2] + $grp * $delta * $normal_x - ($CHAMP_RAD+$stop_dist) * $vector_x))." ".
		(int($blue_tank_wp[3] + $grp * $delta * $normal_y - ($CHAMP_RAD+$stop_dist) * $vector_y))." 120\n";
	    $chf++;
	    $grp++;
	}
    }
}


# print static objects
sub add_tank_static() {
    my $suply_sector=1; 
    my $tank_name;
    my $ttl_sector=0;
    if ($RED_ATTK_TACTIC==1){

	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/$red_tgt_code,[^,]+,[^,]+,[^,]+,([^,]+),([^:]+):2/) {
		$ttl_sector=$1;
		$suply_sector=$2; 
		last;
	    }
	}

	if ($suply_sector>0 || $ttl_sector >= $TTL_WITH_DEF ) { #CHECK sera el suminstro aleman.. si tienen, ponemos tanques  alemanes a defender

	    my $vector_x = ($red_tank_wp[2] -$red_tank_wp[0]);
	    my $vector_y = ($red_tank_wp[3] -$red_tank_wp[1]);
	    my $modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
	    $vector_x/=$modulo; # modulo cant be 0 because wp1 != wp2
	    $vector_y/=$modulo;
	    my $normal_x=$vector_y;
	    my $normal_y=-$vector_x;
	    my $angle=0;
	    
	    if ($vector_x==0){
		if ($vector_y>=0){$angle=90;}
		else {$angle=270;}
	    }
	    else {
		$angle=atan2(abs($red_tank_wp[3] - $red_tank_wp[1]),abs($red_tank_wp[2] - $red_tank_wp[0]));
		$angle=$angle * 57.3;
		if ($vector_y<=0){ # 3ro y 4to cuad
		    if ($vector_x>=0){$angle=360-$angle;} #4to cuad
		    else {$angle+=180;} #3er cuad
		}
		else{ # 2do cuad o 1er quad (no hacemos nada)
		    if ($vector_x<0){ $angle=180-$angle;} # 2do cuad
		}
	    }
	    while ($angle >360){ $angle-=360;}
	    $angle=540-$angle;  # para los rusos es giro en otro sentido.
	    $angle=int($angle); # el valor entero

   
	    $tank_name="_Static $AXIS_TANKS_DEF 2 "; 
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x)." ".($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y)." $angle 0\n";
	    $s_obj_counter++;
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40*$normal_x)." ".($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y)." $angle 0\n";
	    $s_obj_counter++;
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2] - $CHAMP_RAD * $vector_x - 20*$normal_x)." ".($red_tank_wp[3] - $CHAMP_RAD * $vector_y - 20 * $normal_y)." $angle 0\n";
	    $s_obj_counter++;
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0*$normal_x)." ".($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y)." $angle 0\n";
	    $s_obj_counter++;
	} # end if suply >0

#Tipo campamento
#$CHAMP_TYPE=0;

	if ($CHAMP_TYPE==0 ) { # blue static champ 0
	    if ($AAA_IN_CHAMPS) {
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 "; # una aaa
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+15)." ".($red_tank_wp[3]+15)." 180 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 "; # una aaa
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+10)." ".($red_tank_wp[3]-50)." 180 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 "; # una aaa
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-30)." ".($red_tank_wp[3]+10)." 180 0\n";
		$s_obj_counter++;
		if ($LATE_AAA_IN_CHAMPS) {
		    $tank_name="_Static vehicles.artillery.Artillery\$Nimrod 2 "; 
		    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+10)." ".($red_tank_wp[3]+0)." 30 0\n";
		    $s_obj_counter++;
		}
	    }
#	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitzMaultierAA 2 "; 
#	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+10)." ".($red_tank_wp[3]-35)." 30 0\n";
#	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$Howitzer_150mm 2 "; 
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-50)." ".($red_tank_wp[3]+0)." 240 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 "; 
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+0)." ".($red_tank_wp[3]+10)." 315 0\n";
	    $s_obj_counter++;
#	    $tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
#	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-55)." ".($red_tank_wp[3]-35)." 210 0\n";
#	    $s_obj_counter++;

#Nuevos objetos dz

#Pak Izquierda
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 120)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 50)." 235 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 120)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 55)." 135 0\n";
	    $s_obj_counter++;
#Pak Arriba
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x - 20 * $normal_x) - 40)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y - 20 * $normal_y) + 50)." 235 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 45)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 50)."  315\n";
	    $s_obj_counter++;
#Pak Derecha
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 60)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 30)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 60)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 35)." 45 0\n";
	    $s_obj_counter++;
#Pak Abajo
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x - 20 * $normal_x) - 40)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y - 20 * $normal_y) - 90)." 45 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 45)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 90)."  135 0\n";
	    $s_obj_counter++;
#AAA
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 40)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 40)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 40)." 0 0\n";
	    $s_obj_counter++;
#Camiones
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_fuel 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 40)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_fuel 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 40)." 0 0\n";
	    $s_obj_counter++;


	} # blue static champ 0 END
	if ($CHAMP_TYPE==1 ) { # blue static champ 1
	    if ($AAA_IN_CHAMPS) {
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-14.21)." ".($red_tank_wp[3]+21.37)." 600.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-1.97)." ".($red_tank_wp[3]-28.76)." 450.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-9.77)." ".($red_tank_wp[3]-17.47)." 540.00 0\n";
		$s_obj_counter++;
		if ($LATE_AAA_IN_CHAMPS) {
		}
	    }
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+2.22)." ".($red_tank_wp[3]-17.38)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-13.97)." ".($red_tank_wp[3]-1.76)." 505.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$SdKfz251 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-3.88)." ".($red_tank_wp[3]+16.91)." 450.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$SdKfz251 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-7.55)." ".($red_tank_wp[3]+16.98)." 450.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+4.16)." ".($red_tank_wp[3]+7.41)." 540.00 0\n";
	    $s_obj_counter++;

#DZ Nuevos objetos
# Artilleria Norte
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 1)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 80)." 235.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 1)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 80)." 315.00 0\n";
	    $s_obj_counter++;
# Artilleria Sur
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 1)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 80)." 45.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 1)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 80)." 135.00 0\n";
	    $s_obj_counter++;
#Pak Izquierda
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 1)." 235 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 1)." 135 0\n";
	    $s_obj_counter++;
#Pak Derecha
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 1)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 1)." 45 0\n";
	    $s_obj_counter++;
#AAA
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 2)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 2)." 0 0\n";
	    $s_obj_counter++;
#Camiones
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_fuel 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 0)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_fuel 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 4)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 56)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 0)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_fuel 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 56)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 4)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_fuel 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 58)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 40)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_fuel 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 58)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 36)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 50)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 40)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_fuel 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 50)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 36)." 0 0\n";
	    $s_obj_counter++;
	} # blue static champ 1 END
	if ($CHAMP_TYPE==2 ) { # blue static champ 2
	    if ($AAA_IN_CHAMPS) {
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-37.45)." ".($red_tank_wp[3]+41.77)." 585.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-37.84)." ".($red_tank_wp[3]-36.83)." 465.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+42.33)." ".($red_tank_wp[3]-35.86)." 420.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+41.83)." ".($red_tank_wp[3]+41.34)." 690.00 0\n";
		$s_obj_counter++;
		if ($LATE_AAA_IN_CHAMPS) {
		}
	    }
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-2.47)." ".($red_tank_wp[3]+43.29)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-39.49)." ".($red_tank_wp[3]+3.95)." 540.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-3.11)." ".($red_tank_wp[3]-38.24)." 450.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+43.93)." ".($red_tank_wp[3]-11.45)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+12.38)." ".($red_tank_wp[3]+1.45)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-16.34)." ".($red_tank_wp[3]+1.93)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+5.54)." ".($red_tank_wp[3]-15.54)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+10.36)." ".($red_tank_wp[3]-16.02)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+14.63)." ".($red_tank_wp[3]-15.93)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-14.4)." ".($red_tank_wp[3]+18.27)." 450.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-10.22)." ".($red_tank_wp[3]+18.33)." 450.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-5.66)." ".($red_tank_wp[3]+18.38)." 450.00 0\n";
	    $s_obj_counter++;
#DZ Nuevos objetos
# Artilleria Norte
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 30)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 225.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 28)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 315.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 30)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 225.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 28)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 315.00 0\n";
	    $s_obj_counter++;
# Artilleria Sur
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 30)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 45.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 28)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 135.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 30)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 45.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 28)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 135.00 0\n";
	    $s_obj_counter++;

#Pak Izquierda
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 30)." 225 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) + 32)." 135 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 30)." 225 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 32)." 135 0\n";
	    $s_obj_counter++;

#Pak Derecha
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 30)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) + 32)." 45 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 30)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 80)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 32)." 45 0\n";
	    $s_obj_counter++;

#AAA
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 25)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 25)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 25)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 25)." 0 0\n";
	    $s_obj_counter++;

	} # blue static champ 2 END
	if ($CHAMP_TYPE==3 ) { # blue static champ 3
	    if ($AAA_IN_CHAMPS) {
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-46.22)." ".($red_tank_wp[3]+50.13)." 585.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+0.5)." ".($red_tank_wp[3]-40.27)." 450.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 2 ";
		print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+44.86)." ".($red_tank_wp[3]+50.86)." 675.00 0\n";
		$s_obj_counter++;
		if ($LATE_AAA_IN_CHAMPS) {
		}
	    }
	    $tank_name="_Static vehicles.stationary.Siren\$SirenCity 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-27.69)." ".($red_tank_wp[3]+0.36)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$RSO 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+8.52)." ".($red_tank_wp[3]+3.42)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-28.64)." ".($red_tank_wp[3]-6.22)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-28.05)." ".($red_tank_wp[3]+16.07)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-45.25)." ".($red_tank_wp[3]+4.71)." 540.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+45.16)." ".($red_tank_wp[3]+4.69)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$SdKfz251 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-38.71)." ".($red_tank_wp[3]+41.67)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_medic 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-7.91)." ".($red_tank_wp[3]-1.89)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+0.05)." ".($red_tank_wp[3]+40.75)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$VW82t 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]+29.11)." ".($red_tank_wp[3]+6.91)." 540.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$OpelBlitz6700A_radio 2 ";
	    print MIS $s_obj_counter.$tank_name.($red_tank_wp[2]-0.44)." ".($red_tank_wp[3]-29.05)." 630.00 0\n";
	    $s_obj_counter++;
#DZ Nuevos objetos
# Artilleria Norte
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 5)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 270 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 5)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 270 0\n";
	    $s_obj_counter++;
# Artilleria Sur
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 5)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 90 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Howitzer_150mm 2 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 5)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 90 0\n";
	    $s_obj_counter++;

#Pak Izquierda
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 30)." 225 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) + 20)." 225\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 30)." 135 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 20)." 135 0\n";
	    $s_obj_counter++;

#Pak Derecha
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 30)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) + 20)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 30)." 45 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$PaK38 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 70)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 20)." 45 0\n";
	    $s_obj_counter++;

#AAA
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 30)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 50)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$DemagFlak 2 "; 
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 40)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 40)." 0 0\n";
	    $s_obj_counter++;
	} # blue static champ 3 END
    } # RED attk tactic ==1 END

    if ($BLUE_ATTK_TACTIC==1){

	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/$blue_tgt_code,[^,]+,[^,]+,[^,]+,([^,]+),([^:]+):1/) {
		$ttl_sector=$1;
		$suply_sector=$2;
		last;
	    }
	}

	if ($suply_sector>0 ||$ttl_sector >= $TTL_WITH_DEF ) { #CHECK sera el suminstro ruso.. si tienen, ponemos tanques  rusos a defender
	    my $vector_x = ($blue_tank_wp[2] -$blue_tank_wp[0]);
	    my $vector_y = ($blue_tank_wp[3] -$blue_tank_wp[1]);
	    my $modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
	    $vector_x/=$modulo; # modulo cant be 0 because wp1 != wp2
	    $vector_y/=$modulo;
	    my $normal_x=$vector_y;
	    my $normal_y=-$vector_x;
	    my $angle=0;
	    
	    if ($vector_x==0){
		if ($vector_y>=0){$angle=90;}
		else {$angle=270;}
	    }
	    else {
		$angle=atan2(abs($blue_tank_wp[3] - $blue_tank_wp[1]),abs($blue_tank_wp[2] - $blue_tank_wp[0]));
		$angle=$angle * 57.3;
		if ($vector_y<=0){ # 3ro y 4to cuad
		    if ($vector_x>=0){$angle=360-$angle;} #4to cuad
		    else {$angle+=180;} #3er cuad
		}
		else{ # 2do cuad o 1er quad (no hacemos nada)
		    if ($vector_x<0){ $angle=180-$angle;} # 2do cuad
		}
	    }
	    while ($angle >360){ $angle-=360;}
	    $angle=540-$angle;  # para los rusos es giro en otro sentido.
	    $angle=int($angle); # el valor entero

	    $tank_name="_Static $ALLIED_TANKS_DEF 1 ";
	    
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x)." ".($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y)." $angle 0\n";
	    $s_obj_counter++;
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x)." ".($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y)." $angle 0\n";
	    $s_obj_counter++;
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2] - $CHAMP_RAD * $vector_x - 20 * $normal_x)." ".($blue_tank_wp[3] - $CHAMP_RAD * $vector_y - 20 * $normal_y)." $angle 0\n";
	    $s_obj_counter++;
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x)." ".($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y)." $angle 0\n";
	    $s_obj_counter++;
	} # end if suply >0
	if ($CHAMP_TYPE==0 ) { # red static champ 0
	    if ($AAA_IN_CHAMPS) {
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+15)." ".($blue_tank_wp[3]+15)." 180 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+10)." ".($blue_tank_wp[3]-50)." 180 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-30)." ".($blue_tank_wp[3]+10)." 180 0\n";
		$s_obj_counter++;
		if ($LATE_AAA_IN_CHAMPS) {
		    $tank_name="_Static vehicles.artillery.Artillery\$M16 1 ";
		    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-20)." ".($blue_tank_wp[3]+30)." 30 0\n";
		    $s_obj_counter++;
		    $tank_name="_Static vehicles.artillery.Artillery\$M16 1 ";
		    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+10)." ".($blue_tank_wp[3]+0)." 30 0\n";
		    $s_obj_counter++;
		}
	    }
	    $tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+10)." ".($blue_tank_wp[3]-35)." 30 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-50)." ".($blue_tank_wp[3]+0)." 240 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+0)." ".($blue_tank_wp[3]+10)." 315 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-55)." ".($blue_tank_wp[3]-35)." 210 0\n";
	    $s_obj_counter++;
#Nuevos objetos DZ
#Pak Izquierda
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 120)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 50)." 235 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 120)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 55)." 135 0\n";
	    $s_obj_counter++;
#Pak Arriba
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x - 20 * $normal_x) - 40)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y - 20 * $normal_y) + 50)." 235 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 45)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 50)."  315\n";
	    $s_obj_counter++;
#Pak Derecha
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 60)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 30)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 60)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 35)." 45 0\n";
	    $s_obj_counter++;
#Pak Abajo
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x - 20 * $normal_x) - 40)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y - 20 * $normal_y) - 90)." 45 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 45)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 90)."  135 0\n";
	    $s_obj_counter++;
#AAA
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 40)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 40)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 40)." 0 0\n";
	    $s_obj_counter++;
#Camiones
		$tank_name="_Static vehicles.stationary.Stationary\$ZIS5_fuel 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 40)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$ZIS5_fuel 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 40)." 0 0\n";
	    $s_obj_counter++;


	} # red static champ 0 END

	if ($CHAMP_TYPE==1 ) { # red static champ 1
	    if ($AAA_IN_CHAMPS) {
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+2.44)." ".($blue_tank_wp[3]-20.94)." 425.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-21.19)." ".($blue_tank_wp[3]-5.42)." 520.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+3.61)." ".($blue_tank_wp[3]+6.58)." 400.00 0\n";
		$s_obj_counter++;
		if ($LATE_AAA_IN_CHAMPS) {
		}
	    }
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-28.07)." ".($blue_tank_wp[3]-25.47)." 700.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$StudebeckerRocket 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+20.97)." ".($blue_tank_wp[3]+16.44)." 435.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-1.47)." ".($blue_tank_wp[3]+12.86)." 645.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-18.86)." ".($blue_tank_wp[3]-27)." 470.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$WillisMB 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+15.58)." ".($blue_tank_wp[3]+7.22)." 470.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$StudebeckerTruck 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-29.75)." ".($blue_tank_wp[3]+6.05)." 485.00 0\n";
	    $s_obj_counter++;
#DZ Nuevos objetos
# Artilleria Norte
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 1)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 80)." 235.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 1)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 80)." 315.00 0\n";
	    $s_obj_counter++;
# Artilleria Sur
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 1)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 80)." 45.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 1)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 80)." 135.00 0\n";
	    $s_obj_counter++;
#Pak Izquierda
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 1)." 235 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 1)." 135 0\n";
	    $s_obj_counter++;
#Pak Derecha
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 1)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 1)." 45 0\n";
	    $s_obj_counter++;
#AAA
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 2)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 2)." 0 0\n";
	    $s_obj_counter++;
#Camiones
		$tank_name="_Static vehicles.stationary.Stationary\$StudebeckerTruck 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 0)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$StudebeckerTruck 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 60)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 4)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 56)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 0)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$StudebeckerTruck 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 56)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 4)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$StudebeckerTruck 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 58)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 40)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$StudebeckerTruck 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 58)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 36)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 50)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 40)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.stationary.Stationary\$StudebeckerTruck 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 50)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 36)." 0 0\n";
	    $s_obj_counter++;

	} # red static champ 1 END
	if ($CHAMP_TYPE==2 ) { # red static champ 2
	    if ($AAA_IN_CHAMPS) {
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-37.7)." ".($blue_tank_wp[3]-37.2)." 495.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+42.33)." ".($blue_tank_wp[3]-36.86)." 390.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+41.61)." ".($blue_tank_wp[3]+40.34)." 675.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-37.24)." ".($blue_tank_wp[3]+40.29)." 585.00 0\n";
		$s_obj_counter++;
		if ($LATE_AAA_IN_CHAMPS) {
		}
	    }
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-39.49)." ".($blue_tank_wp[3]+2.95)." 540.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-2.47)." ".($blue_tank_wp[3]+42.29)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+43.93)." ".($blue_tank_wp[3]-12.45)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-3.11)." ".($blue_tank_wp[3]-39.24)." 450.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_PC 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-14.56)." ".($blue_tank_wp[3]+15.66)." 450.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_PC 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-6.43)." ".($blue_tank_wp[3]+15.66)." 450.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_PC 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-10.4)." ".($blue_tank_wp[3]+15.77)." 450.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_PC 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+14.45)." ".($blue_tank_wp[3]-14.09)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_PC 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+5.7)." ".($blue_tank_wp[3]-14.4)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_PC 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+9.95)." ".($blue_tank_wp[3]-14.36)." 630.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+15.4)." ".($blue_tank_wp[3]+0.52)." 360.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-13.56)." ".($blue_tank_wp[3]+0.47)." 360.00 0\n";
	    $s_obj_counter++;
#DZ Nuevos objetos
# Artilleria Norte
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 30)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 225.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 28)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 315.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 30)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 225.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 28)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 315.00 0\n";
	    $s_obj_counter++;

# Artilleria Sur
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 28)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 45.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 30)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 135.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 28)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 45.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 30)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 135.00 0\n";
	    $s_obj_counter++;

#Pak Izquierda
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 30)." 225 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 28)." 135 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 28)." 225 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) + 30)." 135 0\n";
	    $s_obj_counter++;
#Pak Derecha
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 28)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) + 30)." 45 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 28)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 80)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 30)." 45 0\n";
	    $s_obj_counter++;

#AAA
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 25)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 25)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 25)." 0 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 25)." 0 0\n";
	    $s_obj_counter++;

	} # red static champ 2 END
	if ($CHAMP_TYPE==3 ) { # red static champ 3
	    if ($AAA_IN_CHAMPS) {
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-38.92)." ".($blue_tank_wp[3]+1.33)." 540.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+40.8)." ".($blue_tank_wp[3]+23.44)." 690.00 0\n";
		$s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$Zenit25mm_1940 1 ";
		print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+40.88)." ".($blue_tank_wp[3]-23.36)." 390.00 0\n";
		$s_obj_counter++;
		if ($LATE_AAA_IN_CHAMPS) {
		}
	    }
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_PC 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-9.78)." ".($blue_tank_wp[3]-12.36)." 690.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+22.5)." ".($blue_tank_wp[3]-17.74)." 615.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_medic 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+28.58)." ".($blue_tank_wp[3]-9.19)." 540.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+30.8)." ".($blue_tank_wp[3]-0.11)." 540.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+30.14)." ".($blue_tank_wp[3]+6.38)." 540.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-36.13)." ".($blue_tank_wp[3]+24.05)." 585.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-36.39)." ".($blue_tank_wp[3]-23.83)." 480.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Siren\$SirenCity 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+9.35)." ".($blue_tank_wp[3]+0.08)." 540.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.lights.Searchlight\$SL_ManualBlue 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]+42.91)." ".($blue_tank_wp[3]+3.41)." 540.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.stationary.Stationary\$ZIS5_radio 1 ";
	    print MIS $s_obj_counter.$tank_name.($blue_tank_wp[2]-2.08)." ".($blue_tank_wp[3]+12.97)." 450.00 0\n";
	    $s_obj_counter++;
#DZ Nuevos objetos
# Artilleria Norte
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 5)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 270.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 5)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 70)." 270.00 0\n";
	    $s_obj_counter++;
# Artilleria Sur
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 5)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 90.00 0\n";
	    $s_obj_counter++;
	    $tank_name="_Static vehicles.artillery.Artillery\$ML20 1 ";
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) - 5)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) - 70)." 90.00 0\n";
	    $s_obj_counter++;
#Pak Izquierda
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 30)." 225 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) + 20)." 225 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 20)." 135 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) - 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 30)." 135 0\n";
	    $s_obj_counter++;
#Pak Derecha
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 20)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) + 30)." 315 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 20)." 45 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS3 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 40 * $normal_x) + 70)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 40 * $normal_y) - 30)." 45 0\n";
	    $s_obj_counter++;

#AAA
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 30)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 50)." 270 0\n";
	    $s_obj_counter++;
		$tank_name="_Static vehicles.artillery.Artillery\$ZIS5_AA 1 "; 
	    print MIS $s_obj_counter.$tank_name.(($blue_tank_wp [2] - $CHAMP_RAD * $vector_x + 0 * $normal_x) + 40)." ".(($blue_tank_wp [3] - $CHAMP_RAD * $vector_y + 0 * $normal_y) + 40)." 0 0\n";
	    $s_obj_counter++;
	} # red static champ 3 END
    } # BLUE attk tactic ==1 END
}

# print building structures of field champs 
sub add_tank_biulding() {
    my $object;
    my $bld_counter=0;

    if ($RED_ATTK_TACTIC==1){
	if ($CHAMP_TYPE==0 ) { # blue buildings champ 0 
	    $object="_bld House\$AirdromeBarrelBlock2W 1 "; #tienda alemana
	    print MIS $bld_counter.$object.($red_tank_wp[2]-50 )." ".($red_tank_wp[3]-50 )." 0\n";
	    $bld_counter++;
	    print MIS $bld_counter.$object.($red_tank_wp[2]-50)." ".($red_tank_wp[3]-20)." 0\n";
	    $bld_counter++;
	    print MIS $bld_counter.$object.($red_tank_wp[2]-10)." ".($red_tank_wp[3]-50 )." 0\n";
	    $bld_counter++;
	    print MIS $bld_counter.$object.($red_tank_wp[2]-10)." ".($red_tank_wp[3]-20)." 0\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2W 1 ";# fuel aleman
	    print MIS $bld_counter.$object.($red_tank_wp[2]-50 )." ".($red_tank_wp[3]-35)." 0\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock1W 1 ";# fuel aleman
	    print MIS $bld_counter.$object.($red_tank_wp[2]-10)." ".($red_tank_wp[3]-35)." 180\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock1W 1 ";# fuel aleman
	    print MIS $bld_counter.$object.($red_tank_wp[2]-10)." ".($red_tank_wp[3]-5)." 0\n";
	    $bld_counter++;

# Nuevos objetos DZ
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 122)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 52)." 0 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 40)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 52)." 270 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 62)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 32)." 180 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 42)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 92)." 270 0\n";
	    $bld_counter++;
	} # blue buildings champ 0 END
	if ($CHAMP_TYPE==1 ) { # blue buildings champ 1 
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-14.5)." ".($red_tank_wp[3]+21.36)." 410.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-3.19)." ".($red_tank_wp[3]+20.16)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-2.11)." ".($red_tank_wp[3]-28.83)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture88mm_Flak_Pos1 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+23.86)." ".($red_tank_wp[3]-1.7)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeTank1 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+0.86)." ".($red_tank_wp[3]-7.02)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeRadar1 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+13.41)." ".($red_tank_wp[3]+32.62)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture88mm_Flak_Pos2 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+0.49)." ".($red_tank_wp[3]-17.37)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$RailShlagbaum 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-25.13)." ".($red_tank_wp[3]+13.16)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureBunker_Omaha 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+21.63)." ".($red_tank_wp[3]+22.62)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureObserv_Bunker 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+13.38)." ".($red_tank_wp[3]+29.48)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-10)." ".($red_tank_wp[3]-17.52)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureBunker_Omaha 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+7.63)." ".($red_tank_wp[3]+23.58)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-8.75)." ".($red_tank_wp[3]+20.18)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-13.69)." ".($red_tank_wp[3]+15.36)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-13.69)." ".($red_tank_wp[3]+3.09)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-14.86)." ".($red_tank_wp[3]-1.91)." 680.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-9.14)." ".($red_tank_wp[3]-3.91)." 680.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-6.89)." ".($red_tank_wp[3]-6.58)." 680.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-17.58)." ".($red_tank_wp[3]+11.83)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-22.28)." ".($red_tank_wp[3]+11.83)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-17.58)." ".($red_tank_wp[3]+7.62)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-23.21)." ".($red_tank_wp[3]+7.62)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeControlTowerSmall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-27.6)." ".($red_tank_wp[3]+13.09)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeControlTowerSmall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-27.46)." ".($red_tank_wp[3]+5.34)." 540.00\n";
	    $bld_counter++;
# Nuevos objetos DZ
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 0)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 82)." 90 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 0)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 82)." 270 0\n";
	    $bld_counter++;
	} # blue buildings champ 1 END 
	if ($CHAMP_TYPE==2 ) { # blue buildings champ 2 
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-37.72)." ".($red_tank_wp[3]+41.77)." 405.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-37.95)." ".($red_tank_wp[3]-36.66)." 675.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+42.45)." ".($red_tank_wp[3]-35.75)." 570.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+42.04)." ".($red_tank_wp[3]+41.63)." 510.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+7.5)." ".($red_tank_wp[3]+40.84)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+13.2)." ".($red_tank_wp[3]+40.84)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+19.02)." ".($red_tank_wp[3]+40.86)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+24.81)." ".($red_tank_wp[3]+40.93)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+30.36)." ".($red_tank_wp[3]+40.95)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+36.22)." ".($red_tank_wp[3]+40.95)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.81)." ".($red_tank_wp[3]+35.75)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.88)." ".($red_tank_wp[3]+30.06)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.88)." ".($red_tank_wp[3]+24.52)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.93)." ".($red_tank_wp[3]+18.97)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.95)." ".($red_tank_wp[3]+13.54)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.95)." ".($red_tank_wp[3]+10.54)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-21.18)." ".($red_tank_wp[3]-36.2)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-15.68)." ".($red_tank_wp[3]-36.2)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+7.43)." ".($red_tank_wp[3]-36.27)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+29.31)." ".($red_tank_wp[3]-36.34)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+40.72)." ".($red_tank_wp[3]+36)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+40.79)." ".($red_tank_wp[3]+30.47)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+40.77)." ".($red_tank_wp[3]+24.81)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+40.86)." ".($red_tank_wp[3]+0.7)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$RailShlagbaum 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+41.52)." ".($red_tank_wp[3]+4.09)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeControlTowerSmall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+39.88)." ".($red_tank_wp[3]+18.41)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeControlTowerSmall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+39.86)." ".($red_tank_wp[3]+1.33)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-9.34)." ".($red_tank_wp[3]+40.86)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-14.97)." ".($red_tank_wp[3]+40.9)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-20.66)." ".($red_tank_wp[3]+40.95)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-26.16)." ".($red_tank_wp[3]+40.93)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-31.84)." ".($red_tank_wp[3]+40.97)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+40.97)." ".($red_tank_wp[3]-17.77)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+40.97)." ".($red_tank_wp[3]-22.36)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+41.04)." ".($red_tank_wp[3]-26.31)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+41.04)." ".($red_tank_wp[3]-30.24)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+34.77)." ".($red_tank_wp[3]-36.29)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+40.83)." ".($red_tank_wp[3]-4.63)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+40.77)." ".($red_tank_wp[3]+19.88)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$RailShlagbaum 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+42.31)." ".($red_tank_wp[3]+16.84)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-26.81)." ".($red_tank_wp[3]-36.13)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-32.27)." ".($red_tank_wp[3]-36.11)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.99)." ".($red_tank_wp[3]-14.2)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.97)." ".($red_tank_wp[3]-19.81)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.99)." ".($red_tank_wp[3]-25.27)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.99)." ".($red_tank_wp[3]-3)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+3.58)." ".($red_tank_wp[3]-36.2)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+12.65)." ".($red_tank_wp[3]-36.29)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+18.24)." ".($red_tank_wp[3]-36.31)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+23.75)." ".($red_tank_wp[3]-36.31)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+37.22)." ".($red_tank_wp[3]-36.24)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-31.47)." ".($red_tank_wp[3]+28.25)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-30.22)." ".($red_tank_wp[3]+31.5)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+4.16)." ".($red_tank_wp[3]+40.88)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-3.2)." ".($red_tank_wp[3]-37.36)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+42.22)." ".($red_tank_wp[3]-11.52)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-38.02)." ".($red_tank_wp[3]+3.88)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-2.54)." ".($red_tank_wp[3]+42)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock1 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+5.5)." ".($red_tank_wp[3]+1.47)." 375.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeMaskingnet 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+10.16)." ".($red_tank_wp[3]-14.2)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeMaskingnet 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-10.36)." ".($red_tank_wp[3]+17.09)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeMaskingnet 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+9.61)." ".($red_tank_wp[3]+17.33)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock1 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-5.43)." ".($red_tank_wp[3]+1.75)." 570.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+31.18)." ".($red_tank_wp[3]-25.77)." 570.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+35.2)." ".($red_tank_wp[3]-26.43)." 390.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeMaskingnet 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-9.59)." ".($red_tank_wp[3]-14.27)." 630.00\n";
	    $bld_counter++;
# Nuevos objetos DZ
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 29)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 72)." 90 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 29)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 72)." 90 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 29)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 72)." 270 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($red_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 29)." ".(($red_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 72)." 270 0\n";
	    $bld_counter++;
	} # blue buildings champ 2 END 
	if ($CHAMP_TYPE==3 ) { # blue buildings champ 3 
	    $object="_bld House\$AirdromeBarrelBlock1 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+39.75)." ".($red_tank_wp[3]-35.41)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_Pyramid_US 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-27.28)." ".($red_tank_wp[3]-22.22)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_Pyramid_US 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-27.52)." ".($red_tank_wp[3]+0.19)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_Pyramid_US 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+27.67)." ".($red_tank_wp[3]-22.24)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_Pyramid_US 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+27.38)." ".($red_tank_wp[3]+1.27)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeControlTowerSmall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+2.07)." ".($red_tank_wp[3]+0.44)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-47.44)." ".($red_tank_wp[3]+4.77)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-44.11)." ".($red_tank_wp[3]+9.32)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-44.25)." ".($red_tank_wp[3]-0.49)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+43.92)." ".($red_tank_wp[3]-0.05)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$GermanyFlag 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-0.11)." ".($red_tank_wp[3]+14.02)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$GermanyFlag 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+0.33)." ".($red_tank_wp[3]-13.63)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_Pyramid_US 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-27.28)." ".($red_tank_wp[3]+22.63)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+43.96)." ".($red_tank_wp[3]+9.86)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+46.91)." ".($red_tank_wp[3]+4.75)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_Pyramid_US 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+27.33)." ".($red_tank_wp[3]+22.72)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos_W 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-0.27)." ".($red_tank_wp[3]-40.13)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos_W 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-45.72)." ".($red_tank_wp[3]+50.47)." 585.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos_W 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+45.57)." ".($red_tank_wp[3]+50.27)." 675.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+6.63)." ".($red_tank_wp[3]-41.07)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-6.88)." ".($red_tank_wp[3]-41.19)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+44.08)." ".($red_tank_wp[3]+41.47)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+36.6)." ".($red_tank_wp[3]+49.24)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-36.58)." ".($red_tank_wp[3]+49.1)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-44.47)." ".($red_tank_wp[3]+42)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTreeLine 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+16.11)." ".($red_tank_wp[3]-18.17)." 690.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_Pyramid_US 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+28.67)." ".($red_tank_wp[3]-21.24)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_Pyramid_US 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+29.67)." ".($red_tank_wp[3]-20.24)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTreeLine 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]+13.46)." ".($red_tank_wp[3]+16.11)." 510.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTreeLine 1 ";
	    print MIS $bld_counter.$object.($red_tank_wp[2]-34.25)." ".($red_tank_wp[3]-21.02)." 570.00\n";
	    $bld_counter++;
	} # blue buildings champ 3 END 
	
    }
    if ($BLUE_ATTK_TACTIC==1){
	if ($CHAMP_TYPE==0 ) { # red buildings champ 0 
	    $object="_bld House\$AirdromeBarrelBlock2W 1 "; #tienda rusa
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-50)." ".($blue_tank_wp[3]-50)." 0\n";
	    $bld_counter++;
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-50)." ".($blue_tank_wp[3]-20)." 0\n";
	    $bld_counter++;
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-10)." ".($blue_tank_wp[3]-50)." 0\n";
	    $bld_counter++;
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-10)." ".($blue_tank_wp[3]-20)." 0\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2W 1 "; # fuel ruso
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-50)." ".($blue_tank_wp[3]-35)." 0\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock1W 1 "; # fuel ruso
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-10)." ".($blue_tank_wp[3]-35)." 180\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock1W 1 "; # fuel ruso
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-10)." ".($blue_tank_wp[3]-5)." 0\n";
	    $bld_counter++;
# Nuevos objetos DZ
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 122)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 52)." 0 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 40)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 52)." 270 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 62)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 32)." 180 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 42)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 92)." 270 0\n";
	    $bld_counter++;

	} # red buildings champ 0 END
	if ($CHAMP_TYPE==1 ) { # red buildings champ 1 
	    $object="_bld House\$Furniture88mm_Flak_Pos2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-21)." ".($blue_tank_wp[3]-5.32)." 520.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-19.02)." ".($blue_tank_wp[3]-27.5)." 645.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-22.5)." ".($blue_tank_wp[3]-16.75)." 700.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-13.86)." ".($blue_tank_wp[3]-24.16)." 610.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-18.52)." ".($blue_tank_wp[3]+7.63)." 700.00\n";
	    $bld_counter++;
	    $object="_bld House\$RailShlagbaum 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-21.74)." ".($blue_tank_wp[3]-19.83)." 430.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeControlTowerSmall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-20.86)." ".($blue_tank_wp[3]-15.36)." 610.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-17.19)." ".($blue_tank_wp[3]+10.13)." 430.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-8.44)." ".($blue_tank_wp[3]-22.19)." 610.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-3.11)." ".($blue_tank_wp[3]-20.21)." 610.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-11.83)." ".($blue_tank_wp[3]+12.1)." 430.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-6.41)." ".($blue_tank_wp[3]+14.05)." 430.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-1.33)." ".($blue_tank_wp[3]+14.58)." 460.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+1.91)." ".($blue_tank_wp[3]+11.97)." 520.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+2.44)." ".($blue_tank_wp[3]-21.47)." 610.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+6.08)." ".($blue_tank_wp[3]-16.97)." 610.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+11.44)." ".($blue_tank_wp[3]-15.02)." 610.00\n";
	    $bld_counter++;
	    $object="_bld House\$CrimeaHouse3 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+12.24)." ".($blue_tank_wp[3]+14.47)." 435.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-2.22)." ".($blue_tank_wp[3]+18.42)." 375.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+0.5)." ".($blue_tank_wp[3]+22.28)." 415.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+5.3)." ".($blue_tank_wp[3]+24.82)." 430.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+10.5)." ".($blue_tank_wp[3]+26.03)." 445.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+15.83)." ".($blue_tank_wp[3]+25.77)." 460.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+20.72)." ".($blue_tank_wp[3]+23.61)." 490.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+23.74)." ".($blue_tank_wp[3]+19.55)." 520.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_HQ_US 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+4.83)." ".($blue_tank_wp[3]-14.25)." 610.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_HQ_US 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+8.86)." ".($blue_tank_wp[3]-12.89)." 610.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+15.8)." ".($blue_tank_wp[3]-12.35)." 585.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+19.61)." ".($blue_tank_wp[3]-8.19)." 580.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+23.03)." ".($blue_tank_wp[3]-3.8)." 575.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+25.25)." ".($blue_tank_wp[3]+0.91)." 555.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+25.92)." ".($blue_tank_wp[3]+6.22)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+25.42)." ".($blue_tank_wp[3]+11.72)." 530.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+24.77)." ".($blue_tank_wp[3]+15.58)." 530.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTree2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+15.08)." ".($blue_tank_wp[3]+22.96)." 470.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTree2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+7.02)." ".($blue_tank_wp[3]+22.11)." 470.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTree2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+10.72)." ".($blue_tank_wp[3]+23.22)." 470.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-9.14)." ".($blue_tank_wp[3]-1.8)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+4.19)." ".($blue_tank_wp[3]+6.57)." 580.00\n";
	    $bld_counter++;
# Nuevos objetos DZ
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 0)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 82)." 90 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 0)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 82)." 270 0\n";
	    $bld_counter++;

	} # red buildings champ 1 END 
	if ($CHAMP_TYPE==2 ) { # red buildings champ 2 
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-37.72)." ".($blue_tank_wp[3]+40.77)." 405.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-37.95)." ".($blue_tank_wp[3]-37.66)." 675.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+42.45)." ".($blue_tank_wp[3]-36.75)." 570.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+42.04)." ".($blue_tank_wp[3]+40.63)." 510.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+7.5)." ".($blue_tank_wp[3]+39.84)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+13.2)." ".($blue_tank_wp[3]+39.84)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+19.02)." ".($blue_tank_wp[3]+39.86)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+24.81)." ".($blue_tank_wp[3]+39.93)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+30.36)." ".($blue_tank_wp[3]+39.95)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+36.22)." ".($blue_tank_wp[3]+39.95)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.81)." ".($blue_tank_wp[3]+34.75)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.88)." ".($blue_tank_wp[3]+29.06)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.88)." ".($blue_tank_wp[3]+23.52)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.93)." ".($blue_tank_wp[3]+17.97)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.95)." ".($blue_tank_wp[3]+12.54)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.95)." ".($blue_tank_wp[3]+9.54)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-21.18)." ".($blue_tank_wp[3]-37.2)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-15.68)." ".($blue_tank_wp[3]-37.2)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+7.43)." ".($blue_tank_wp[3]-37.27)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+29.31)." ".($blue_tank_wp[3]-37.34)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.72)." ".($blue_tank_wp[3]+35)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.79)." ".($blue_tank_wp[3]+29.47)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.77)." ".($blue_tank_wp[3]+23.81)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.86)." ".($blue_tank_wp[3]-0.29)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$RailShlagbaum 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+41.52)." ".($blue_tank_wp[3]+3.09)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeControlTowerSmall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+39.88)." ".($blue_tank_wp[3]+17.41)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeControlTowerSmall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+39.86)." ".($blue_tank_wp[3]+0.33)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-9.34)." ".($blue_tank_wp[3]+39.86)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-14.97)." ".($blue_tank_wp[3]+39.9)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-20.66)." ".($blue_tank_wp[3]+39.95)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-26.16)." ".($blue_tank_wp[3]+39.93)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-31.84)." ".($blue_tank_wp[3]+39.97)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.97)." ".($blue_tank_wp[3]-18.77)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.97)." ".($blue_tank_wp[3]-23.36)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+41.04)." ".($blue_tank_wp[3]-27.31)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+41.04)." ".($blue_tank_wp[3]-31.24)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+34.77)." ".($blue_tank_wp[3]-37.29)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.83)." ".($blue_tank_wp[3]-5.63)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.77)." ".($blue_tank_wp[3]+18.88)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$RailShlagbaum 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+42.31)." ".($blue_tank_wp[3]+15.84)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-26.81)." ".($blue_tank_wp[3]-37.13)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-32.27)." ".($blue_tank_wp[3]-37.11)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.99)." ".($blue_tank_wp[3]-15.2)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.97)." ".($blue_tank_wp[3]-20.81)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.99)." ".($blue_tank_wp[3]-26.27)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.99)." ".($blue_tank_wp[3]-4)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+3.58)." ".($blue_tank_wp[3]-37.2)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+12.65)." ".($blue_tank_wp[3]-37.29)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+18.24)." ".($blue_tank_wp[3]-37.31)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+23.75)." ".($blue_tank_wp[3]-37.31)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+37.22)." ".($blue_tank_wp[3]-37.24)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-31.47)." ".($blue_tank_wp[3]+27.25)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-30.22)." ".($blue_tank_wp[3]+30.5)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+4.16)." ".($blue_tank_wp[3]+39.88)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-3.2)." ".($blue_tank_wp[3]-38.36)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+42.22)." ".($blue_tank_wp[3]-12.52)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-38.02)." ".($blue_tank_wp[3]+2.88)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$Furniture20mm_Flak_Pos 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-2.54)." ".($blue_tank_wp[3]+41)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock1 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+5.5)." ".($blue_tank_wp[3]+0.47)." 375.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2W 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+10.16)." ".($blue_tank_wp[3]-15.2)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2W 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-10.36)." ".($blue_tank_wp[3]+16.09)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2W 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+9.52)." ".($blue_tank_wp[3]+16.02)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock1 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-5.43)." ".($blue_tank_wp[3]+0.75)." 570.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+31.18)." ".($blue_tank_wp[3]-26.77)." 570.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+35.2)." ".($blue_tank_wp[3]-27.43)." 390.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2W 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-11.77)." ".($blue_tank_wp[3]-15.13)." 630.00\n";
	    $bld_counter++;
# Nuevos objetos DZ
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 29)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 72)." 90 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 29)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 72)." 90 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) + 29)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) - 72)." 270 0\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.(($blue_tank_wp[2] - $CHAMP_RAD * $vector_x + 20 * $normal_x) - 29)." ".(($blue_tank_wp[3] - $CHAMP_RAD * $vector_y + 20 * $normal_y) + 82)." 270 0\n";
	    $bld_counter++;

	} # red buildings champ 2 END 
	if ($CHAMP_TYPE==3 ) { # red buildings champ 3 
	    $object="_bld House\$Tent_HQ_US 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-28.01)." ".($blue_tank_wp[3]+13.66)." 390.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+33.66)." ".($blue_tank_wp[3]+19.75)." 660.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeBarrelBlock2W 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+30.47)." ".($blue_tank_wp[3]+3.08)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$AirdromeControlTowerSmall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-21.44)." ".($blue_tank_wp[3]+5.39)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_HQ_US 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-28.61)." ".($blue_tank_wp[3]+5.44)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_HQ_US 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-28.19)." ".($blue_tank_wp[3]-4.88)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_HQ_US 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-19.58)." ".($blue_tank_wp[3]-5.8)." 600.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_HQ_US 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-14.89)." ".($blue_tank_wp[3]+3.83)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+41.8)." ".($blue_tank_wp[3]+24.3)." 510.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-39.66)." ".($blue_tank_wp[3]+1.22)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$RailShlagbaum 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+0.94)." ".($blue_tank_wp[3]+25.21)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+8.85)." ".($blue_tank_wp[3]+23.83)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+36.24)." ".($blue_tank_wp[3]+24.25)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-2.85)." ".($blue_tank_wp[3]+24.01)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.61)." ".($blue_tank_wp[3]-19.53)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-31.89)." ".($blue_tank_wp[3]-23.78)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+36.47)." ".($blue_tank_wp[3]-23.82)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.19)." ".($blue_tank_wp[3]-18.22)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.13)." ".($blue_tank_wp[3]+18.32)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-37.58)." ".($blue_tank_wp[3]-25.11)." 675.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-37.22)." ".($blue_tank_wp[3]+26.22)." 420.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.58)." ".($blue_tank_wp[3]-3.64)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.58)." ".($blue_tank_wp[3]+6.49)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-36.58)." ".($blue_tank_wp[3]+20.16)." 360.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-31.41)." ".($blue_tank_wp[3]+24.13)." 450.00\n";
	    $bld_counter++;
	    $object="_bld House\$VehicleGAZ67t 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+21.5)." ".($blue_tank_wp[3]+1.86)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTreeLine 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-15.96)." ".($blue_tank_wp[3]-22.36)." 465.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+43.3)." ".($blue_tank_wp[3]+3.38)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.19)." ".($blue_tank_wp[3]-1.49)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+40.33)." ".($blue_tank_wp[3]+8.27)." 540.00\n";
	    $bld_counter++;
	    $object="_bld House\$Tent_HQ_US 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-15.58)." ".($blue_tank_wp[3]+13.3)." 480.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTreeLine 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+25.58)." ".($blue_tank_wp[3]-23.83)." 465.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTreeLine 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-16.85)." ".($blue_tank_wp[3]+17.25)." 645.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureTreeLine 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]-17.25)." ".($blue_tank_wp[3]-7.21)." 420.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbag_Wall 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+4.64)." ".($blue_tank_wp[3]-24.11)." 630.00\n";
	    $bld_counter++;
	    $object="_bld House\$FurnitureSandbags_Round 1 ";
	    print MIS $bld_counter.$object.($blue_tank_wp[2]+42.08)." ".($blue_tank_wp[3]-23.61)." 570.00\n";
	    $bld_counter++;
	} # red buildings champ 3 END 
    }
}

#  briefing:
#-------
sub print_briefing() {

    open (DESC, ">$PATH_TO_WEBROOT/gen/badc$extend.properties"); 

    # calculamos la cantidad de grupos en cada lista.
    my $red_def_groups = (scalar(@red_def_grplst)/$grpentries);
    my $red_attk_groups = (scalar(@red_attk_grplst)/$grpentries);
    my $blue_def_groups = (scalar(@blue_def_grplst)/$grpentries);
    my $blue_attk_groups = (scalar(@blue_attk_grplst)/$grpentries);
    my $i=0;
    my $basta=0;

   $languajes=2;


    print DESC "Name Mision  badc".$extend."\n";
    my $gen_date=scalar(localtime(time));
    print DESC "Short Mision  badc".$extend."\\n".$gen_date."\\nGameHost:$Dhost\\nRedReq:$Rhost\\nBlueReq:$Bhost\\n";
    print DESC "\n";


    print DESC "Description <ARMY NONE>\\n\\n\\nMission Badc".$extend."\\n$gen_date\\n\\n";
    print DESC "\\n\\nGameHost:$Dhost\\nRedReq:$Rhost\\nBlueReq:$Bhost\\n\\n";
    print DESC "\\n\\nSeleccione su avion y lea su \"Briefing\".";
    print DESC "\\n\\n\\n\\n\\nSelect your aircraft and check Briefing.";
    print DESC "\\n*You will find english version scrollin down.*\\n\\n";
    print DESC "</ARMY><ARMY RED>\\n";

    for ($lang=0; $lang<$languajes; $lang++) {
	
	if ($lang==0) {print DESC "\\n** ENGLISH Briefing: scrol down **\\n\\n";}
	if ($lang==1) {print DESC "\\n\\n          ------------------------\\n\\n";}

	if ($lang==0) {$des_hora="Hora  -> $hora:$minutos\\n";}
	if ($lang==1) {$des_hora="Time  -> $hora:$minutos\\n";}
	print DESC $des_hora;

	if ($lang==0) {$des_clima="Clima -> $tipo_clima";}
	if ($lang==1) {
	    if ($tipo_clima eq "Despejado"){$des_clima="Weather -> Clear";}
	    if ($tipo_clima eq "Bueno"){$des_clima="Weather -> Good";}
	    if ($tipo_clima eq "Baja visibilidad"){$des_clima="Weather -> Low Visivility";}
	    if ($tipo_clima eq "Precipitaciones"){$des_clima="Weather -> Rain/snow fall";}
	    if ($tipo_clima eq "Tormenta"){$des_clima="Weather -> Storm";}
	}
	print DESC $des_clima;

	if ($tipo_clima eq "Bueno") {
	    if ($lang==0) {$des_nubes=" Nubes a $nubes metros.";}
	    if ($lang==1) {$des_nubes=" clouds at $nubes meters.";}
	    print DESC $des_nubes;
	}
	print DESC "\\n\\n\\n";
	
	#bombers de defend rojos
#	if ($red_def_groups==0){
#	    if ($lang==0) {$des_red_def_no_fly="\\n\\nDefensa: $blue_target \\n\\nNo volaremos en esta zona.";}
#	    if ($lang==1) {$des_red_def_no_fly="\\n\\nDefense: $blue_target \\n\\nWe are not flying in this area.";}
#	    print DESC $des_red_def_no_fly;
#	}
	for ( $i=0; $i<$red_def_groups;  $i++){ 
	    if ($red_def_grplst[$grpentries*$i] eq "BD"){
		my $bom_cant=$red_def_grplst[$grpentries*$i+2];
		if ($red_def_grplst[$grpentries*($i+1)] eq "BD"){ # si hay un siguiente grupo bomber D
		    $bom_cant+=$red_def_grplst[$grpentries*($i+1)+2];
		}
		if ($lang==0) {$des_red_def_BD="\\n\\nDefensa: $blue_target \\n\\nSe ha solicitado a la fuerza aerea atacar a un grupo de tanques enemigos que avanzan dentro de nuestro territorio en el sector $blue_target . Mucha atencion antes de atacar, ya que en esa zona puede haber tropas amigas resistiendo el avance. Nuestro grupo de ataque consiste en  ".$bom_cant." ".$red_def_grplst[$grpentries*$i+10].".\\nDistancia al objetivo: $RED_DEF_TGT Km.\\nDistancia Objetivo a base: $RED_DEF_HOME Km.\\n\\nInformacion adicional: Nuestro campamento esta localizado ". (int((($blue_tank_wp[2])%10000)/10)/100) ." km E y ". (int((($blue_tank_wp[3])%10000)/10)/100) ." km N respecto el vertice SO del sector atacado. Los carros enemigos avanzan hacia nuestro campamento desde la posicion ". (int((($blue_tank_wp[0])%10000)/10)/100) ." km E y ". (int((($blue_tank_wp[1])%10000)/10)/100) ." km N respecto el vertice SO del sector atacado.\\n\\n";}

		if ($lang==1) {$des_red_def_BD="\\n\\nDefense: $blue_target \\n\\nOur air force has been request to attack a group of enemy tanks advancing into our territory on area  $blue_target . Pay attention before attack, because in that area is possible to find friendly troops, fighting against the incoming enemy. Our attack group consist in ".$bom_cant." ".$red_def_grplst[$grpentries*$i+10].".\\nDistance to tgt: $RED_DEF_TGT Km.\\nDistance tgt to base: $RED_DEF_HOME Km.\\n\\nAditional information: Our camp base is located ". (int((($blue_tank_wp[2])%10000)/10)/100) ." km E and ". (int((($blue_tank_wp[3])%10000)/10)/100) ." km N respect the SW vertex of attacked sector. The enemy tanks are advancing towards our camp base from ". (int((($blue_tank_wp[0])%10000)/10)/100) ." km E and ". (int((($blue_tank_wp[1])%10000)/10)/100) ." km N respect the SW vertex of attacked sector.\\n\\n";}
		print DESC enc_unicode($des_red_def_BD);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($basta>0){$i=1000; $basta=0;} #salimos del for.
	}

	#fighters de defend group rojos
	for ( $i=0; $i<$red_def_groups;  $i++){ 
	    if ($red_def_grplst[$grpentries*$i] eq "I" && !$BLUE_RECON && !$BLUE_SUM){
		if ($lang==0) {$des_red_def_I="\\n\\nDefensa: $blue_target \\nNuestra mision hoy consiste en patrullaje. Posiblemente los enemigos intenten una ataque estrategico en la zona $blue_target para reducir nuestros suministro y capacidad operativa. Nuestra patrulla consiste en ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].".\\n";}
		if ($lang==1) {$des_red_def_I="\\n\\nDefense: $blue_target \\nOur mission today consist in patrol. Is possible that enemy try an strategic attack on zone $blue_target to reduce our suply and operational radius. The CAP consists in ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_red_def_I);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($red_def_grplst[$grpentries*$i] eq "I" && $BLUE_RECON){
		if ($lang==0) {$des_red_def_I="\\n\\nPatrulla: $blue_target \\nNuestra mision hoy consiste en patrullaje. Posiblemente los enemigos realicen vuelos de reconocimiento.  Nuestra patrulla consiste en ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].".\\n";}
		if ($lang==1) {$des_red_def_I="\\n\\nPatrol: $blue_target \\nOur mission today consist in patrol. Is possible that enemy try recon flights.  The CAP consists in ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_red_def_I);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($red_def_grplst[$grpentries*$i] eq "I" && $BLUE_SUM){
		if ($lang==0) {$des_red_def_I="\\n\\nPatrulla: $blue_target \\nNuestra mision hoy consiste en patrullaje. Los enemigos estan haciendo vuelos de reaprovisionamiento. Localizar y destruir los transportes. Nuestra patrulla consiste en ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].".\\n";}
		if ($lang==1) {$des_red_def_I="\\n\\nPatrol: $blue_target \\nOur mission today consist in patrol. The enemy is resuplying. Seek and destroy enemy trasports. The CAP consists in ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_red_def_I);
		$basta=1; # solo imprimimos 1 vez
	    }

	    if ( $red_def_grplst[$grpentries*$i] eq "EBD"){
		if ($red_bom_def_planes>0) {
		    if ($lang==0) {$des_red_def_EBD="El grupo de ataque tendra una escolta de ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].".\\n";}
		    if ($lang==1) {$des_red_def_EBD="The attack goup will fly with an escort of ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].".\\n";}
		}
		else { # hay escolta BD pero no hay BD
		    if ($lang==0) {$des_red_def_EBD="\\n\\nDefensa: $blue_target \\n\\nSe ha solicitado a la fuerza aerea atacar a un grupo de tanques enemigos que avanzan dentro de nuestro territorio en el sector $blue_target . No disponemos de bombarderos. Los unicos aviones disponibles en este momento son ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].". Utilizenlos para la tarea como mejor puedan. Suerte!\\nDistancia al objetivo: $RED_DEF_TGT Km.\\nDistancia Objetivo a base: $RED_DEF_HOME Km.\\n";}
		    if ($lang==1) {$des_red_def_EBD="\\n\\nDefense: $blue_target \\n\\nOur air force has been request to attack a group of enemy tanks advancing into our territory on area  $blue_target . Right now we do not have aviable bombers to send. The only aircrafts aviable are ".$red_fig_def_planes." ".$red_def_grplst[$grpentries*$i+10].". Use them as best you can for your duty. Good Luck!\\nDistance to tgt: $RED_DEF_TGT Km.\\nDistance tgt to base: $RED_DEF_HOME Km.\\n";}
		}
		print DESC enc_unicode($des_red_def_EBD);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($basta>0){$i=1000; $basta=0;} #salimos del for.
	}

	# bomebers en grupo de ataque rojos
#	if ($red_attk_groups==0){ 
#	    if ($lang==0) {$des_red_attk_no_fly="\\n\\nAtaque: $red_target \\n\\nNo volaremos en esta zona.";}
#	    if ($lang==1) {$des_red_attk_no_fly="\\n\\nAttack: $red_target \\n\\nWe are not flying in that area.";}
#	    print DESC $des_red_attk_no_fly;
#	}
	for ( $i=0; $i<$red_attk_groups;  $i++){ 
	    if ($red_attk_grplst[$grpentries*$i] eq "BA"){
		my $bom_cant=$red_attk_grplst[$grpentries*$i+2];
		if ($red_attk_grplst[$grpentries*($i+1)] eq "BA"){ # si hay un siguiente grupo bomber A
		    $bom_cant+=$red_attk_grplst[$grpentries*($i+1)+2];
		}
		if ($lang==0) {$des_red_attk_BA="\\n\\n\\nAtaque: $red_target \\nEstamos realizando un ataque estrategigo para reducir la capacidad del enemigo. Atacaremos $red_target con ".$bom_cant." ".$red_attk_grplst[$grpentries*$i+10].".\\nDistancia al objetivo: $RED_ATTK_TGT Km.\\nDistancia Objetivo a base: $RED_ATTK_HOME Km.\\n";}
		if ($lang==1) {$des_red_attk_BA="\\n\\n\\nAttack: $red_target \\nWe are doing an strategic attack to reduce suply and operational chances of enemy. We will attack $red_target with ".$bom_cant." ".$red_attk_grplst[$grpentries*$i+10].".\\nDistance to tgt: $RED_ATTK_TGT Km.\\nDistance tgt base: $RED_ATTK_HOME Km.\\n";}
		print DESC enc_unicode($des_red_attk_BA);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($red_attk_grplst[$grpentries*$i] eq "R"){
		if ($lang==0) {$des_red_attk_R="\\n\\nReconocimiento: $red_target \\nNos han encargado una mision de reconocimiento sobre el area".$red_target.". El reconocimento se realizara con  ".$red_attk_grplst[$grpentries*$i+2]." ".$red_attk_grplst[$grpentries*$i+10].".\\nDistancia al objetivo: $RED_ATTK_TGT Km.\\nDistancia Objetivo a base: $RED_ATTK_HOME Km.\\n";}
		if ($lang==1) {$des_red_attk_R="\\n\\nRecon: $red_target \\nA recon tas was ordered today over ".$red_target." area. The recon group consist in ".$red_attk_grplst[$grpentries*$i+2]." ".$red_attk_grplst[$grpentries*$i+10]."..\\nDistance to tgt: $RED_ATTK_TGT Km.\\nDistance tgt base: $RED_ATTK_HOME Km.\\n";}
		print DESC enc_unicode($des_red_attk_R);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($red_attk_grplst[$grpentries*$i] eq "SUM"){
		my $bom_cant=$red_attk_grplst[$grpentries*$i+2];
		if ($red_attk_grplst[$grpentries*($i+1)] eq "SUM"){ # si hay un siguiente grupo sum
		    $bom_cant+=$red_attk_grplst[$grpentries*($i+1)+2];
		}
		if ($lang==0) {$des_red_attk_R="\\n\\nSuministro: $red_target \\nNos han encargado una mision de suministro en ".$red_target.". El transporte se realizara con  ".$bom_cant." ".$red_attk_grplst[$grpentries*$i+10].".\\n";
		    if ($RED_SUM_AI==0){$des_red_attk_R.="Esta es una mision de suministro humano. Los transportes deberan ser volados por pilotos humanos para que puedan suministrar. Los transportes deberan llevar armas: DEFAULT y 100% combustible.\\nDistancia al objetivo: $RED_ATTK_TGT Km.\\nDistancia Objetivo a base: $RED_ATTK_HOME Km.\\nTiempo para realizar la mision: $RED_SUM_TIME minutos.\\n";}
		}
		if ($lang==1) {$des_red_attk_R="\\n\\nSupply: $red_target \\nA We need to suply ".$red_target.". The transport group consist in ".$bom_cant." ".$red_attk_grplst[$grpentries*$i+10].".\\n";
		    if ($RED_SUM_AI==0){$des_red_attk_R.="This is a human supply mission. The transport planes has to be flown by human pilots or supply will not be valid. Transport require weapons DEFAULT and 100% fuel and has to land safe in a friendly base after city supply.\\nDistance to tgt: $RED_ATTK_TGT Km.\\nDistance tgt to base: $RED_ATTK_HOME Km.\\nTime to acomplish mission: $RED_SUM_TIME minutes.\\n";}
	        }
		print DESC enc_unicode($des_red_attk_R);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($basta>0){$i=1000; $basta=0;} #salimos del for.
	}

	#figters en grupo ataque  rojos
	for ( $i=0; $i<$red_attk_groups;  $i++){ 
	    if ($red_attk_grplst[$grpentries*$i] eq "ET"){
		if ($lang==0) {$des_red_attk_ET="\\n\\n\\nAtaque: $red_target \\nNuestras tropas estan  atacando la zona $red_target y han requerido soporte aereo, nuestra mision es eliminar bombarderos enemigos que interfieran la operacion. El vuelo consiste en ".$red_fig_attk_planes." ".$red_attk_grplst[$grpentries*$i+10].". Recomendamos de ser posible llevar armas de ataque a tierra, que usaremos en caso de enconrar algun objetvo de opurtunidad que se resista a nuestras tropas de tierra.\\n\\nInformacion adicional: Nuestros carros avanzan hacia el campamento enemigo desde ". (int((($red_tank_wp[0])%10000)/10))/100 ." km E y ". (int((($red_tank_wp[1])%10000)/10))/100 ." km N respecto el vertice SO del sector atacado. El campamento enemigo esta localizado ". (int((($red_tank_wp[2])%10000)/10))/100 ." km E y ". (int((($red_tank_wp[3])%10000)/10))/100 ." km N respecto del vertice SO del sector atacado.\\n";}

		if ($lang==1) {$des_red_attk_ET="\\n\\n\\nAttack: $red_target \\nOur troops are attacking  $red_target area and has request air suport. Our mission is to eliminate any enemy bombardiers disturbing our operations. The flight consists on ".$red_fig_attk_planes." ".$red_attk_grplst[$grpentries*$i+10].". Is recommended, if possible, to carry ground attack weapons, to use in case we find some oportunity ground tragets, special on enemy troops blocking our advance.\\n\\nAditional information: Our tanks are advancing towards enemy camp base from ". (int((($red_tank_wp[0])%10000)/10))/100 ." km E and ". (int((($red_tank_wp[1])%10000)/10))/100 ." km N respect the SW vertex of attacked sector. Enemy camp  base is located ". (int((($red_tank_wp[2])%10000)/10))/100 ." km E and ". (int((($red_tank_wp[3])%10000)/10))/100 ." km N respect the SW vertex of attacked sector. \\n";}
		print DESC enc_unicode($des_red_attk_ET);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($red_attk_grplst[$grpentries*$i] eq "ER"){
		if ($lang==0) {$des_red_attk_ER="Escoltaremos a nuestro vuelo de reconocimiento con  ".$red_fig_attk_planes." ".$red_attk_grplst[$grpentries*$i+10].".\\n";}
		if ($lang==1) {$des_red_attk_ER="Recon escorst will be ".$red_fig_attk_planes." ".$red_attk_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_red_attk_ER);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($red_attk_grplst[$grpentries*$i] eq "ESU"){
		if ($lang==0) {$des_red_attk_ER="Escoltaremos los transportes  con  ".$red_fig_attk_planes." ".$red_attk_grplst[$grpentries*$i+10].".\\n";}
		if ($lang==1) {$des_red_attk_ER="Transpot escorts will be ".$red_fig_attk_planes." ".$red_attk_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_red_attk_ER);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($red_attk_grplst[$grpentries*$i] eq "EBA"){
		if ($lang==0) {$des_red_attk_EBA="Escoltaremos a nuestros bombarderos con  ".$red_fig_attk_planes." ".$red_attk_grplst[$grpentries*$i+10].".\\n";}
		if ($lang==1) {$des_red_attk_EBA=" Escorts for the bomber group will be ".$red_fig_attk_planes." ".$red_attk_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_red_attk_EBA);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($basta>0){$i=1000; $basta=0;} #salimos del for.
	}
	
	print DESC "\\n\\n\\n\\n\\n\\n";
    }
    print DESC "</ARMY><ARMY BLUE>\\n";
    
    for ($lang=0; $lang<$languajes; $lang++) {
	if ($lang==0) {print DESC "\\n** ENGLISH Briefing: scroll down **\\n\\n";}
	if ($lang==1) {print DESC "\\n\\n          ------------------------\\n\\n";}

	if ($lang==0) {$des_hora="Hora  -> $hora:$minutos\\n";}
	if ($lang==1) {$des_hora="Time  -> $hora:$minutos\\n";}
	print DESC $des_hora;

	if ($lang==0) {$des_clima="Clima -> $tipo_clima";}
	if ($lang==1) {
	    if ($tipo_clima eq "Despejado"){$des_clima="Weather -> Clear";}
	    if ($tipo_clima eq "Bueno"){$des_clima="Weather -> Good";}
	    if ($tipo_clima eq "Baja visibilidad"){$des_clima="Weather -> Low Visivility";}
	    if ($tipo_clima eq "Precipitaciones"){$des_clima="Weather -> Rain/snow fall";}
	    if ($tipo_clima eq "Tormenta"){$des_clima="Weather -> Storm";}
	}
	print DESC $des_clima;

	if ($tipo_clima eq "Bueno") {
	    if ($lang==0) {$des_nubes=" Nubes a $nubes metros.";}
	    if ($lang==1) {$des_nubes=" clouds at $nubes meters.";}
	    print DESC $des_nubes;
	}
	print DESC "\\n\\n\\n";
	
	# bombers en grupo de defensa azul
#	if ($blue_def_groups==0){ 
#	    if ($lang==0) {$des_blue_def_no_fly= "\\n\\nDefensa: $red_target \\n\\nNo volaremos en esta zona.";}
#	    if ($lang==1) {$des_blue_def_no_fly= "\\n\\nDefense: $red_target \\n\\nWe are not flying on that area.";}
#	    print DESC $des_blue_def_no_fly;
#	}
	for ( $i=0; $i<$blue_def_groups;  $i++){ 
	    if ($blue_def_grplst[$grpentries*$i] eq "BD"){
		my $bom_cant=$blue_def_grplst[$grpentries*$i+2];
		if ($blue_def_grplst[$grpentries*($i+1)] eq "BD"){ # si hay un siguiente grupo bomber D
		    $bom_cant+=$blue_def_grplst[$grpentries*($i+1)+2];
		}
		if ($lang==0) {$des_blue_def_BD="\\n\\nDefensa: $red_target \\nSe ha solicitado a la fuerza aerea atacar a un grupo de tanques enemigos que avanzan dentro de nuestro territorio en el sector $red_target . Mucha atencion antes de atacar, ya que en esa zona puede haber tropas amigas resistiendo el avance.\\nNuestro grupo de ataque consiste en ".$bom_cant." ".$blue_def_grplst[$grpentries*$i+10].".\\nDistancia al objetivo: $BLUE_DEF_TGT Km.\\nDistancia Objetivo a base: $BLUE_DEF_HOME Km.\\n\\nInformacion adicional: Nuestro campamento esta localizado ". (int((($red_tank_wp[2])%10000)/10))/100 ." km E y ". (int((($red_tank_wp[3])%10000)/10))/100 ." km N respecto el vertice SO del sector atacado. Los carros enemigos avanzan hacia nuestro campamento desde la posicion ". (int((($red_tank_wp[0])%10000)/10))/100 ." km E y ". (int((($red_tank_wp[1])%10000)/10))/100 ." km N respecto el vertice SO del sector atacado.\\n\\n";}

		if ($lang==1) {$des_blue_def_BD="\\n\\nDefense: $red_target \\n\\nOur air force has been request to attack a group of enemy tanks advancing into our territory un the area  $red_target . Pay attention before attack, because in that area is possible to find friendly troops, fighting against the incoming enemy. Our attack group consist in ".$bom_cant." ".$blue_def_grplst[$grpentries*$i+10].".\\nDistance to tgt: $BLUE_DEF_TGT Km.\\nDistance tgt to base: $BLUE_DEF_HOME Km.\\n\\nAditional information: Our camp base is located ". (int((($red_tank_wp[2])%10000)/10))/100 ." km E and ". (int((($red_tank_wp[3])%10000)/10))/100 ." km N respect the SW vertex of attacked sector. The enemy tanks are advancing towards our camp base from ". (int((($red_tank_wp[0])%10000)/10))/100 ." km E and ". (int((($red_tank_wp[1])%10000)/10))/100 ." km N respect the SW vertex of attacked sector.\\n\\n";}
		print DESC enc_unicode($des_blue_def_BD);
		$basta=1; # solo imprimimos 1 vez
	    } 
	    if ($basta>0){$i=1000; $basta=0;} #salimos del for.
	}

	# fighters en grupo de defensa azul
	for ( $i=0; $i<$blue_def_groups;  $i++){ 
	    if ($blue_def_grplst[$grpentries*$i] eq "I" && !$RED_RECON && !$RED_SUM){
		if ($lang==0) {$des_blue_def_I="\\n\\nPatrulla: $red_target \\nNuestra mision hoy consiste en patrullaje. Posiblemente los enemigos intenten una ataque estrategico en la zona $red_target para reducir nuestros suministro y capacidad operativa. Nuestra patrulla consiste en ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].".";}
		if ($lang==1) {$des_blue_def_I="\\n\\nPatrol: $red_target \\nOur mission today consist in patrol. Is possible that enemy try an strategic attack on zone $red_target to reduce our suply and operational radius. The CAP consists in ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_blue_def_I);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($blue_def_grplst[$grpentries*$i] eq "I" && $RED_RECON){
		if ($lang==0) {$des_blue_def_I="\\n\\nPatrulla: $red_target \\nNuestra mision hoy consiste en patrullaje. Posiblemente los enemigos realicen vuelos de reconocimiento. Nuestra patrulla consiste en ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].".";}
		if ($lang==1) {$des_blue_def_I="\\n\\nPatrol: $red_target \\nOur mission today consist in patrol. Is possible that enemy make recon flights. The CAP consists in ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_blue_def_I);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($blue_def_grplst[$grpentries*$i] eq "I" && $RED_SUM){
		if ($lang==0) {$des_blue_def_I="\\n\\nPatrulla: $red_target \\nNuestra mision hoy consiste en patrullaje. Posiblemente los enemigos realizaran vuelos de reaprovisionamiento. Encontrar y destruir los transportes enemigos . Nuestra patrulla consiste en ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].".";}
		if ($lang==1) {$des_blue_def_I="\\n\\nPatrol: $red_target \\nOur mission today consist in patrol. Is possible that enemy make resuply flights. Seek and destroy the transports. The CAP consists in ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_blue_def_I);
		$basta=1; # solo imprimimos 1 vez
	    }

	    if ($blue_def_grplst[$grpentries*$i] eq "EBD"){
		if ($blue_bom_def_planes >0) {
		    if ($lang==0) {$des_blue_def_EBD="El grupo de ataque tendra una escolta de ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].".\\n";}
		    if ($lang==1) {$des_blue_def_EBD="The attack group will be escorted by ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].".\\n";}
		}
		else { # hay escolta BD pero no hay BD
		    if ($lang==0) {$des_blue_def_EBD="\\n\\nDefensa: $red_target \\n\\nSe ha solicitado a la fuerza aerea atacar a un grupo de tanques enemigos que avanzan dentro de nuestro territorio en el sector $red_target . No disponemos de bombarderos. Los unicos aviones disponibles en este momento son ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].". Utilizenlos para la tarea como mejor puedan. Suerte!\\nDistancia al objetivo: $BLUE_DEF_TGT Km.\\nDistancia Objetivo a base: $BLUE_DEF_HOME Km.\\n";}
		    if ($lang==1) {$des_blue_def_EBD="\\n\\nDefense: $red_target \\n\\nOur air force has been request to attack a group of enemy tanks advancing into our territory on area  $red_target . Right now we do not have aviable bombers to send. The only aircrafts aviable are ".$blue_fig_def_planes." ".$blue_def_grplst[$grpentries*$i+10].". Use them as best you can for your duty. Good Luck!\\nDistance to tgt: $BLUE_DEF_TGT Km.\\nDistance tgt to base: $BLUE_DEF_HOME Km.\\n";}
		}

		print DESC enc_unicode($des_blue_def_EBD);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($basta>0){$i=1000; $basta=0;} #salimos del for.
	}
	
	# bombers grupo de ataque azul
#	if ($blue_attk_groups==0){ 
#	    if ($lang==0) {$des_blue_attk_no_fly="\\n\\nAtaque: $blue_target \\n\\nNo volaremos en esta zona.";}
#	    if ($lang==1) {$des_blue_attk_no_fly="\\n\\nAttack: $blue_target \\n\\nWe are not flying on that area.";}
#	    print DESC $des_blue_attk_no_fly;
#	}
	for ( $i=0; $i<$blue_attk_groups; $i++){ 
	    if ($blue_attk_grplst[$grpentries*$i] eq "BA"){
		my $bom_cant=$blue_attk_grplst[$grpentries*$i+2];
		if ($blue_attk_grplst[$grpentries*($i+1)] eq "BA"){ # si hay un siguiente grupo bomber A
		    $bom_cant+=$blue_attk_grplst[$grpentries*($i+1)+2];
		}
		if ($lang==0) {$des_blue_attk_BA="\\n\\n\\nAtaque: $blue_target \\nEstamos realizando un ataque estrategigo para reducir la capacidad del enemigo. Atacaremos $blue_target con ".$bom_cant." ".$blue_attk_grplst[$grpentries*$i+10].".\\nDistancia al objetivo: $BLUE_ATTK_TGT Km.\\nDistancia Objetivo a base: $BLUE_ATTK_HOME Km.\\n";}
		if ($lang==1) {$des_blue_attk_BA="\\n\\n\\nAttack: $blue_target \\nWe are doing a strategic attack to reduce suply and operational chances of enemy. We will attack $blue_target with ".$bom_cant." ".$blue_attk_grplst[$grpentries*$i+10].".\\nDistance to tgt: $BLUE_ATTK_TGT Km.\\nDistance tgt to base: $BLUE_ATTK_HOME Km.\\n";}
		print DESC enc_unicode($des_blue_attk_BA);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($blue_attk_grplst[$grpentries*$i] eq "R") {
		if ($lang==0) {$des_blue_attk_R="\\n\\nReconocimiento: $blue_target \\nNos han encargado una mision de reconocimiento sobre el $blue_target El vuelo de reconocimiento consiste en ".$blue_attk_grplst[$grpentries*$i+2]." ".$blue_attk_grplst[$grpentries*$i+10].".\\nDistancia al objetivo: $BLUE_ATTK_TGT Km.\\nDistancia Objetivo a base: $BLUE_ATTK_HOME Km.\\n";}
		if ($lang==1) {$des_blue_attk_R="\\n\\nRecon: $blue_target \\nA recon tas was ordered today over ".$blue_target." area. The recon group consist in ".$blue_attk_grplst[$grpentries*$i+2]." ".$blue_attk_grplst[$grpentries*$i+10].".\\nDistance to tgt: $BLUE_ATTK_TGT Km.\\nDistance tgt to base: $BLUE_ATTK_HOME Km.\\n";}
		print DESC enc_unicode($des_blue_attk_R);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($blue_attk_grplst[$grpentries*$i] eq "SUM") {
		my $bom_cant=$blue_attk_grplst[$grpentries*$i+2];
		if ($blue_attk_grplst[$grpentries*($i+1)] eq "SUM"){ # si hay un siguiente grupo bomber sum
		    $bom_cant+=$blue_attk_grplst[$grpentries*($i+1)+2];
		}
		if ($lang==0) {$des_blue_attk_R="\\n\\nSuministro: $blue_target \\nDebemos suministrar $blue_target. Los transportes seran ".$bom_cant." ".$blue_attk_grplst[$grpentries*$i+10].".\\n";
		    if ($BLUE_SUM_AI==0){$des_blue_attk_R.="Esta es una mision de suministro humano. Los transportes deberan ser volados por pilotos humanos para que puedan suministrar. Los transportes deberan llevar armas: default y 100% combustible.\\nDistancia al objetivo: $BLUE_ATTK_TGT Km.\\nDistancia Objetivo a base: $BLUE_ATTK_HOME Km.\\nTiempo para completar la mision $BLUE_SUM_TIME minutos.\\n";}
		}
		if ($lang==1) {$des_blue_attk_R="\\n\\nSupply: $blue_target \\nWe need to suply $blue_target. The transport group consist in ".$bom_cant." ".$blue_attk_grplst[$grpentries*$i+10].".\\n";
		    if ($BLUE_SUM_AI==0){ $des_blue_attk_R.="This is a human supply mission. The transport planes has to be flown by human pilots or supply will not be valid. Transport require weapons DEFAULT and 100% fuel and has to land safe in a friendly base after city supply.\\nDistance to tgt: $BLUE_ATTK_TGT Km.\\nDistance tgt to base: $BLUE_ATTK_HOME Km.\\nTime to acomplish mission: $BLUE_SUM_TIME minutes.\\n";}
		}
		print DESC enc_unicode($des_blue_attk_R);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($basta>0){$i=1000; $basta=0;} #salimos del for.
	}

	# figters grupo de ataque azul
	for ( $i=0; $i<$blue_attk_groups; $i++){ 
	    if ($blue_attk_grplst[$grpentries*$i] eq "ET"){
		if ($lang==0) {$des_blue_attk_ET="\\n\\n\\nAtaque: $blue_target \\nNuestras tropas estan atacando la zona $blue_target y han requerido soporte aereo, nuestra mision es eliminar bombarderos enemigos que interfieran la operacion. El vuelo consiste en ".$blue_fig_attk_planes." ".$blue_attk_grplst[$grpentries*$i+10].". Recomendamos de ser posible  llevar armas de ataque a tierra, que usaremos en caso de enconrar algun objetvo de opurtunidad que se resista a nuestras tropas de tierra.\\n\\nInformacion adicional: Nuestros carros avanzan hacia el campamento enemigo desde ". (int((($blue_tank_wp[0])%10000)/10))/100 ." km E y ". (int((($blue_tank_wp[1])%10000)/10))/100 ." km N respecto el vertice SO del sector atacado. El campamento enemigo esta localizado ". (int((($blue_tank_wp[2])%10000)/10))/100 ." km E y ". (int((($blue_tank_wp[3])%10000)/10))/100 ." km N respecto del vertice SO del sector atacado.\\n";}
		if ($lang==1) {$des_blue_attk_ET="\\n\\n\\nAttack: $blue_target \\nOur troops are attacking  $blue_target area and has request air suport. Our mission is to eliminate any enemy bombardiers disturbing our operations. The flight consists on ".$blue_fig_attk_planes." ".$blue_attk_grplst[$grpentries*$i+10].". Is recommended, if possible, to carry ground attack weapons, to use in case we find some oportunity ground tragets, special on enemy troops blocking our advance.\\n\\nAditional information: Our tanks are advancing towards enemy camp base from ". (int((($blue_tank_wp[0])%10000)/10))/100 ." km E and ". (int((($blue_tank_wp[1])%10000)/10))/100 ." km N respect the SW vertex of attacked sector. Enemy camp  base is located ". (int((($blue_tank_wp[2])%10000)/10))/100 ." km E and ". (int((($blue_tank_wp[3])%10000)/10))/100 ." km N respect the SW vertex of attacked sector. \\n";}

		print DESC enc_unicode($des_blue_attk_ET);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($blue_attk_grplst[$grpentries*$i] eq "ER"){
		if ($lang==0) {$des_blue_attk_ER="Escoltaremos a nuestro vuelo de reconocimiento con  ".$blue_fig_attk_planes." ".$blue_attk_grplst[$grpentries*$i+10].".\\n";}
		if ($lang==1) {$des_blue_attk_ER="Our recon flihgt will have an escort of ".$blue_fig_attk_planes." ".$blue_attk_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_blue_attk_ER);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($blue_attk_grplst[$grpentries*$i] eq "ESU"){
		if ($lang==0) {$des_blue_attk_ER="Escoltaremos a nuestro vuelo de transporte con  ".$blue_fig_attk_planes." ".$blue_attk_grplst[$grpentries*$i+10].".\\n";}
		if ($lang==1) {$des_blue_attk_ER="Our transport flihgt will be escorted by ".$blue_fig_attk_planes." ".$blue_attk_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_blue_attk_ER);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($blue_attk_grplst[$grpentries*$i] eq "EBA"){
		if ($lang==0) {$des_blue_attk_EBA="Escoltaremos a nuestros bombarderos con ".$blue_fig_attk_planes." ".$blue_attk_grplst[$grpentries*$i+10].".\\n";}
		if ($lang==1) {$des_blue_attk_EBA="The bomber group will be escorted by ".$blue_fig_attk_planes." ".$blue_attk_grplst[$grpentries*$i+10].".\\n";}
		print DESC enc_unicode($des_blue_attk_EBA);
		$basta=1; # solo imprimimos 1 vez
	    }
	    if ($basta>0){$i=1000; $basta=0;} #salimos del for.
	}
	print DESC "\\n\\n\\n\\n\\n\\n";
    }
    print DESC "</ARMY>";
    close(DESC);
}

# @Heracles@20110417@
# Cálcula que tipo de aaa tenemos que colocar en un WP de aaa (tipo 2000) para distribuirla
# en la ciudad objetivo según las variables $AAA_CITY_HIGH_PERCENT, $AAA_CITY_MEDIUM_PERCENT,
# $AAA_CITY_LOW_PERCENT
sub calc_aaa_city(@) {
    my @my_aaa_dist = @_;
    
    printdebug("calc_aaa_city() : Entra con aaa-dist : ". $my_aaa_dist[0] . "-" . $my_aaa_dist[1] . "-" . $my_aaa_dist[2]);
    
    my $aaa_total = sum_array(@my_aaa_dist) * 1.0;
    printdebug("calc_aaa_city() : aaa_total " . $aaa_total);
    my @aaa_percent_dist = (0.0, 0.0, 0.0);
    my @aaa_percent_delta = (0.0, 0.0, 0.0);
    
    if ($aaa_total > 0) {
        $aaa_percent_dist[0] = ($my_aaa_dist[0] * 1.0 )/ $aaa_total;
        $aaa_percent_dist[1] = ($my_aaa_dist[1] * 1.0 )/ $aaa_total;
        $aaa_percent_dist[2] = ($my_aaa_dist[2] * 1.0 )/ $aaa_total;
    }    
    printdebug("calc_aaa_city() : % aaa : ". $aaa_percent_dist[0] . "-" . $aaa_percent_dist[1] . "-" . $aaa_percent_dist[2]);    
    
    $aaa_percent_delta[0] = $AAA_CITY_HIGH - $aaa_percent_dist[0];
    $aaa_percent_delta[1] = $AAA_CITY_MEDIUM - $aaa_percent_dist[1];
    $aaa_percent_delta[2] = $AAA_CITY_LOW - $aaa_percent_dist[2];
    
    printdebug("calc_aaa_city() : % aaa delta: ". $aaa_percent_delta[0] . "-" . $aaa_percent_delta[1] . "-" . $aaa_percent_delta[2]);    
    
    my $max = $aaa_percent_delta[0];
    my $my_aaa_type = 0;
    
    for ($i = 1; $i < 3; $i++) {
	if ($aaa_percent_delta[$i] > $max) {
	    $max = $aaa_percent_delta[$i];
	    $my_aaa_type = $i;
	}
    }
    
    printdebug("calc_aaa_city() : salimos con tipo ". $my_aaa_type . " -- deltas ". $aaa_percent_delta[0] . "-". $aaa_percent_delta[1] ."-" . $aaa_percent_delta[2] );
    return $my_aaa_type;
}

# poblate with static objects a place close to a city
## @Heracles@20110710
## Añadimos un cuarto argumento para indicar si sólo queremos AAA : 0 poblar con todo - 1 poblar sólo con AAA
sub poblate_city($$$$){ 
    my($army,$cx,$cy,$only_aaa)= @_;

    my $this_city_objs=0;
    my $this_city_objs_aaa=0;
    my $coord_p1x;
    my $coord_p1y;	
    my $coord_p2x;
    my $coord_p2y;	
    my $type;
    my $vector_x;
    my $vector_y;
    my $modulo;
    my $angle;
    my $object;
    my $object_high;
    my $object_medium;
    my $object_low;
    my $wspan; 
    my $to_place;
    my $m_usados;
    my @aaa_dist = (0, 0, 0);

    seek CITY, 0, 0;
    # @Heracles@20110117@
    # Anulamos las luces que marcan objetivo en las ciudades.
    # if ($RED_ATTK_TACTIC==0){print MIS $s_obj_counter."_Static vehicles.stationary.Smoke\$Smoke15 0 ".int($red_tgtcx)." ".int($red_tgtcy)." ".$angle." 0\n";}
    # if ($BLUE_ATTK_TACTIC==0){print MIS $s_obj_counter."_Static vehicles.stationary.Smoke\$Smoke15 0 ".int($blue_tgtcx)." ".int($blue_tgtcy)." ".$angle." 0\n";}

    while(<CITY>) {
	if ($_ =~ m/ *NORMFLY ([^ ]+) ([^ ]+)/){
	    $coord_p1x=$1;
	    $coord_p1y=$2;	
	    $_=readline(CITY);
	    $_ =~ m/ *NORMFLY ([^ ]+) ([^ ]+) ([^ ]+)/;
	    $coord_p2x=$1;
	    $coord_p2y=$2;
	    $type=$3;
	    if (distance($cx,$cy,$1,$2)<1000) {
		$m_usados=0;
	        $vector_x = ($coord_p2x - $coord_p1x);
		$vector_y = ($coord_p2y - $coord_p1y);
		$modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
		$vector_x/=$modulo;
		$vector_y/=$modulo;
		if ($vector_x==0){
		    if ($vector_y>=0){$angle=90;}
		    else {$angle=270;}
		}
		else {
		    $angle=atan2(abs($coord_p2y - $coord_p1y),abs($coord_p2x - $coord_p1x));
		    $angle=$angle * 57.3;
		    if ($vector_y<=0){ # 3ro y 4to cuad
			if ($vector_x>=0){$angle=360-$angle;} #4to cuad
			else {$angle+=180;} #3er cuad
		    }
		    else{ # 2do cuad o 1er quad (no hacemos nada)
			if ($vector_x<0){ $angle=180-$angle;} # 2do cuad
		    }
		}
		while ($angle >360){ $angle-=360;}
		$angle=360-$angle;  # para los rusos es giro en otro sentido.
		$angle=int($angle); # el valor entero
				
		# comenzamos: typo AAA
		if ($type==2000) { # si es aaa
		    $wspan=5; 
		    if ($army==1) {
			$object_high="vehicles.artillery.Artillery\$Zenit85mm_1939";
			$object_medium="vehicles.artillery.Artillery\$Zenit61K";
			$object_low="vehicles.artillery.Artillery\$Zenit25mm_1940";
		    }
		    else {
			$object_high="vehicles.artillery.Artillery\$Flak18_88mm";
			$object_medium="vehicles.artillery.Artillery\$Flak18_37mm";
			$object_low="vehicles.artillery.Artillery\$Flak38_20mm";			
		    }
		    
		    printdebug("poblate_city() Empezamos...");
		    my @aaa_type = ( $object_high, $object_medium, $object_low );
		    printdebug("poblate_city() Tipo AAA HIGH ".$aaa_type[0]);
		    printdebug("poblate_city() Tipo AAA MEDIUM ".$aaa_type[1]);
		    printdebug("poblate_city() Tipo AAA LOW ".$aaa_type[2]);		    		    
		    printdebug("poblate_city() Entramos con aaa_dist: ". $aaa_dist[0] . "-" . $aaa_dist[1] . "-" .$aaa_dist[2]);		    
		    my $my_aaa_type = calc_aaa_city(@aaa_dist);

		    #colocamos aaa
		    print MIS $s_obj_counter."_Static ".$aaa_type[$my_aaa_type]." ".$army." ".int($coord_p1x).
			" ".int($coord_p1y)." ".$angle." 0\n";

		    $aaa_dist[$my_aaa_type]++;
		    $s_obj_counter++;
		    $this_city_objs_aaa++;
		    
		    printdebug("poblate_city() Salimos con aaa_dist: ". $aaa_dist[0] . "-" . $aaa_dist[1] . "-" .$aaa_dist[2]);		    
		}

		# VEHICULOS:  tipo 500 angulo normal y 1000 son vehiculos rotados 90 a derecha (+90 en el il2FB)
		if (($type==500 || $type==1000) && $only_aaa == 0){ #seleccionamos objeto wspan 
		    if ($type==1000) {$angle+=90;} # rotamos
		    while ($m_usados<$modulo-6) {
			$to_place=int(rand(2)+2); # de 2 a 4 objetos
			$obj_nr=int(rand(1000)+1); # objeto al azar de 1 a 1000 ;
			if ($army==1) {  # base roja
			    seek FLIGHTS,0,0;  #ST100,1,I153,vehicles.planes.Plane$I_153_M62,15:150		
			    while(<FLIGHTS>) {
				if ( $_ =~ m/SV1[0-9]{2},$army,[^,]+,([^,]+),([^,]+):([0-9]+)/){
				    if ($obj_nr<=$3){
					$wspan=$2;
					$object=$1;
					last;
				    }
				}
			    }
			}
			else { # base azul
			    seek FLIGHTS,0,0;  #ST203,2,FW189,vehicles.planes.Plane$FW_189A2,25:500
			    while(<FLIGHTS>) {
				if ( $_ =~ m/SV2[0-9]{2},$army,[^,]+,([^,]+),([^,]+):([0-9]+)/){
				    if ($obj_nr<=$3){
					$wspan=$2;
					$object=$1;
					last;
				    }
				}
			    }
			}
			while ($to_place && $m_usados<$modulo-6) { # mientras no nos pasemos   
			    #avanzamos medio wingspan,
			    $coord_p1x +=($wspan/2*$vector_x);
			    $coord_p1y +=($wspan/2*$vector_y); 
			    
			    #colocamos avion u otro objeto diponible, como un camion de fuel
			    if (($this_city_objs+$this_city_objs_aaa) <90){
				print MIS $s_obj_counter."_Static ".$object." ".$army." ".int($coord_p1x)
				    ." ".int($coord_p1y)." ".$angle." 0\n";
				$s_obj_counter++;
				$this_city_objs++;
			    }
			    $to_place--;
			    
			    #avanzamos medio wingspan  + f(damage) [disabled]
			    $coord_p1x +=(($wspan/2)*$vector_x);
			    $coord_p1y +=(($wspan/2)*$vector_y); 
			    $m_usados+=$wspan;		    
			}
		    }
		}
		#TRENES
		if ($type==1500 && $only_aaa == 0) { 
		    $angle+=180; # locomotora mirando alreves
		    if ($army==1){ $object="vehicles.stationary.Stationary\$Wagon9";}
		    else { $object="vehicles.stationary.Stationary\$Wagon11";}
		    $wspan=15;
		    $coord_p1x +=($wspan/2*$vector_x);
		    $coord_p1y +=($wspan/2*$vector_y); 
		    if (($this_city_objs+$this_city_objs_aaa) <90){
			print MIS $s_obj_counter."_Static ".$object." ".$army." ".
			    int($coord_p1x)." ".int($coord_p1y)." ".$angle." 0\n";
			$s_obj_counter++;
			$this_city_objs++;
		    }
		    $coord_p1x +=((1+$wspan/2)*$vector_x);
		    $coord_p1y +=((1+$wspan/2)*$vector_y); 
		    $m_usados+=$wspan+1;		    
		    
		    if ($army==1){$object="vehicles.stationary.Stationary\$Wagon10";}
		    else {$object="vehicles.stationary.Stationary\$Wagon12";}
		    $wspan=9;
		    $coord_p1x +=($wspan/2*$vector_x);
		    $coord_p1y +=($wspan/2*$vector_y); 
		    if (($this_city_objs+$this_city_objs_aaa) <90){
			print MIS $s_obj_counter."_Static ".$object." ".$army." ".
			    int($coord_p1x)." ".int($coord_p1y)." ".$angle." 0\n";
			$s_obj_counter++;
			$this_city_objs++;
		    }
		    $coord_p1x +=((1+$wspan/2)*$vector_x);
		    $coord_p1y +=((1+$wspan/2)*$vector_y); 
		    $m_usados+=$wspan+1;		    
		    
		    $angle-=180;
		    $wspan=15;
		    $to_place=0;
		    while ($m_usados<$modulo-10) { # mientras no nos pasemos   
			if ($to_place==0){
			    $to_place=int(rand(4)+2); # de 2 a 6 objetos
			    $object="vehicles.stationary.Stationary\$Wagon".int(rand(6)+2); # 2 a 7 (1 y 8 son  explosivos)
			}
			$coord_p1x +=($wspan/2*$vector_x);
			$coord_p1y +=($wspan/2*$vector_y); 
			if (($this_city_objs+$this_city_objs_aaa) <90){
			    print MIS $s_obj_counter."_Static ".$object." ".$army." ".
				int($coord_p1x)." ".int($coord_p1y)." ".$angle." 0\n";
			    $s_obj_counter++;
			    $this_city_objs++;
			}
			$to_place--;
			$coord_p1x +=((1+$wspan/2)*$vector_x);
			$coord_p1y +=((1+$wspan/2)*$vector_y); 
			$m_usados+=$wspan+1;		    
		    }
		}
	    }
	}
    }
}

# calls poblate city and counts amount of static objects placed
sub static_on_city(){ # city code, se lee el army desde geo obj
    my $delta_obj;
    if ($red_tgt_code =~ m/^CT[0-9]{2}/) { 
	$delta_obj=$s_obj_counter;
	poblate_city(2,$red_tgtcx,$red_tgtcy,0); # atencion! check  se manda army opuesto!!
	$delta_obj=$s_obj_counter-$delta_obj;
	print DET "blue_objects=".$delta_obj."\n";
	
    }
    if ($blue_tgt_code =~ m/^CT[0-9]{2}/) {
	$delta_obj=$s_obj_counter;
	poblate_city(1,$blue_tgtcx,$blue_tgtcy,0); # atencion! check  se manda army opuesto!!
	$delta_obj=$s_obj_counter-$delta_obj;
	print DET "red_objects=".$delta_obj."\n";
    }
}

## @Heracles@20110710@
## Llama a poblate_city sólo para aaa en ciudades objetivo de suministro
sub static_aaa_on_sum_city() {
    my $myred_target = $red_tgt_code;
    my $myblue_target = $blue_tgt_code;
    
    ## @Heracles@20110710
    ## Si ambos bandos tienen el mismo objetivo, no poblar de nuevo la ciudad con AAA
    if (($red_tgt_code =~ m/^SUC[0-9]{2}/ && $blue_tgt_code =~ m/^CT[0-9]{2}/) || ($red_tgt_code =~ m/^CT[0-9]{2}/ && $blue_tgt_code =~ m/^SUC[0-9]{2}/)){
	$myred_target =~ m/^[A-Z]+([0-9]){2}/;
	$myred_target = $1;
	$myblue_target =~ m/^[A-Z]+([0-9]){2}/;
	$myblue_target = $1;
	
	printdebug("static_aaa_on_sum_city(): red target code: $myred_target blue target code: $myblue_target \n");
	
	if ($myred_target == $myblue_target) { return;}
    }
    
    if ($red_tgt_code =~ m/^SUC[0-9]{2}/) { 
	poblate_city(1,$red_tgtcx,$red_tgtcy,1);
    }
    if ($blue_tgt_code =~ m/^SUC[0-9]{2}/) {
	poblate_city(2,$blue_tgtcx,$blue_tgtcy,1);
    }    
}

# poblate possible airfields in use: 2 AF takeoff  + 2 AF landing  + 1 AF is enemy attack one 
sub static_on_afields() {
    my $delta_obj;
    
    if ($blue_tgt_code =~ m/AF/) { # si azul ataca un af rojo...
	$delta_obj=$s_obj_counter;
	poblate_airfield($blue_tgt_code);
	$delta_obj=$s_obj_counter-$delta_obj;
	if ($hora>=17 || $hora<=7 || $clima>90) {
	    $delta_obj-=20; # restamos los fuegos colocados, que no cuentan como tgts
	}
	$delta_obj-=1; # objetos - 2 sirenas + un avion marcador de color AF JU-52/LI-2
	print DET "red_objects=".$delta_obj."\n";
    }
    
    if ($red_af1_code ne "") {
	if ($red_af1_code ne $blue_tgt_code){
	    poblate_airfield($red_af1_code);
	}
    }
    if ($red_af2_code ne "") {
	if ( ($red_af2_code ne $red_af1_code) && 
	     ($red_af2_code ne $blue_tgt_code)){
	    poblate_airfield($red_af2_code);
	}
    }
    if ($red_af3_code ne "") {
	if (($red_af3_code ne $red_af1_code) && 
	    ($red_af3_code ne $red_af2_code) &&
	    ($red_af3_code ne $blue_tgt_code)){
	    poblate_airfield($red_af3_code);
	}
    }
    if ($red_af4_code ne "") {
	if (($red_af4_code ne $red_af1_code) && 
	    ($red_af4_code ne $red_af2_code) && 
	    ($red_af4_code ne $red_af3_code) && 
	    ($red_af4_code ne $blue_tgt_code)){
	    poblate_airfield($red_af4_code);
	}
    }
    
 # same for blue 

    if ($red_tgt_code =~  m/AF/) { # si rojos atacan un af azul
	$delta_obj=$s_obj_counter;
	poblate_airfield($red_tgt_code);
	$delta_obj=$s_obj_counter-$delta_obj;
	if ($hora>=17 || $hora<=7 || $clima>90) {
	    $delta_obj-=20; # restamos los fuegos colocados, que no cuentan como tgts
	}
	$delta_obj-=1; # objetos - 2 sirenas + un avion marcador de color AF JU-52/LI-2
	print DET "blue_objects=".$delta_obj."\n";
    }

    if ($blue_af1_code ne "") {
	if ($blue_af1_code ne $red_tgt_code){
	    poblate_airfield($blue_af1_code);
	}
    }
    if ($blue_af2_code ne "") {
	if (($blue_af2_code ne $blue_af1_code)&&
	    ($blue_af2_code ne $red_tgt_code) ){
	    poblate_airfield($blue_af2_code);
	}
    }
    if ($blue_af3_code ne "") {
	if (($blue_af3_code ne $blue_af1_code)&& 
	    ($blue_af3_code ne $blue_af2_code)&&
	    ($blue_af3_code ne $red_tgt_code) ){
	    poblate_airfield($blue_af3_code);
	}
    }

    if ($blue_af4_code ne "") {
	if (($blue_af4_code ne $blue_af1_code)&& 
	    ($blue_af4_code ne $blue_af2_code)&& 
	    ($blue_af4_code ne $blue_af3_code)&&
	    ($blue_af4_code ne $red_tgt_code) ){
	    poblate_airfield($blue_af4_code);
	}
    }
}

# prints only front markers close to the front line
sub print_fm(){
    my $fm_cx;
    my $fm_cy;
    my $army;
    my $opuesto;
    my $fm_order=0;
    my $line_back;
    seek FRONT,0,0;
    while(<FRONT>) {
	if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) ([12])/){
	    $fm_cx=$1;
	    $fm_cy=$2;
	    $army=$3;
	    $line_back=tell FRONT;                 #leemso la posicion en el archivo
	    if ($army==1){$opuesto=2;}
	    else {$opuesto=1;}
	    seek FRONT,0,0;
	    while(<FRONT>) {
		if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) $opuesto/){
		    if (distance($fm_cx,$fm_cy,$1,$2)<45000){
			print MIS "FrontMarker".$fm_order." ".$fm_cx." ".$fm_cy." ".$army."\n";
			last;
		    }
		}
	    }
	    seek FRONT,$line_back,0; # regrresamos una linea para atras
	}
    }
}

# selects  all possible targets to later pick a random one (for offline testing)
# later can be used for a online quick generation, where targets selection has
# to be selected from this list and based on previous human requested (on the DB)
# some places are listed 2 times to give more chances to be selected 
sub select_random_tagets(){
    my @possible=();
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/SEC[^,]+,([^,]+),([^,]+),([^,]+),[^:]*:2.*$/) { 
	    my $tgt_name=$1;
	    my $cxo=$2;
	    my $cyo=$3;
	    my $near=500000; # gran distancia para comenzar (500 km)
	    seek FRONT,0,0;
	    while(<FRONT>) {
		if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) 1/){
		    my $dist= distance($cxo,$cyo,$1,$2);
		    if ($dist < $near) {
			$near=$dist;
			if ($dist<5000) {last;}  #version 24 optim change
		    }
		}
	    }
	    if ($near <15000 && $cyo<140000 && $cyo>40000 ) { #tactico, no en los bordes
		push (@possible,$tgt_name);
	    }
	}
    }
    # seleccion de objetivos al azar ESTRATEGICOS ROJOS
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/(AF.{2}|CT[0-9]{2}),([^,]+),([^,]+),([^,]+),[^:]*:2.*$/) { 
	    $tgt_name=$2;
	    $cxo=$3;
	    $cyo=$4;
	    $near=500000; # gran distancia para comenzar (500 km)
	    seek FRONT,0,0;
	    while(<FRONT>) {
		if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) 1/){
		    $dist= distance($cxo,$cyo,$1,$2);
		    if ($dist < $near) {
			$near=$dist;
			if ($dist<80000) {last;}  #version 24 optim change
		    }
		}
	    }
	    if ($near <80000) {
		push (@possible,$tgt_name); 
		if ($tgt_name !~ m/aerodromo/) { # a las cuidades le damos 2 oportunidades
		    push (@possible,$tgt_name); 
		}
	    }
	}
    }
    #suministros rojos
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/(SUC[0-9]{2}),([^,]+),([^,]+),([^,]+),[^:]*:1.*$/) { 
	    $tgt_name=$2;
	    push (@possible,$2); 
	}
    }
    #print "Red possible targets : ".join(" ",@possible)."\n"; #debug check sacar
    $red_target=@possible[int(rand(scalar(@possible)))]; # get a random target

    
    # seleccion de objetivos al azar TACTICOS AZULES
    @possible=();
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/SEC[^,]+,([^,]+),([^,]+),([^,]+),[^:]*:1.*$/) {
	    $tgt_name=$1;
	    $cxo=$2;
	    $cyo=$3;
	    $near=500000; # gran distancia para comenzar (500 km)
	    seek FRONT,0,0;
	    while(<FRONT>) {
		if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) 2/){
		    $dist= distance($cxo,$cyo,$1,$2);
		    if ($dist < $near) {
			$near=$dist;
			if ($dist<5000) {last;}  #version 24 optim change
		    }
		}
	    }
	    if ($near <15000  && $cyo<150000 && $cyo>40000 ) { #tactico, no en los bordes
		push (@possible,$tgt_name);
	    }
	}
    }
    # seleccion de objetivos al azar ESTARTEGICOS AZULES
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/(AF.{2}|CT[0-9]{2}),([^,]+),([^,]+),([^,]+),[^:]*:1.*$/) {
	    $tgt_name=$2;
	    $cxo=$3;
	    $cyo=$4;
	    $near=500000; # gran distancia para comenzar (500 km)
	    seek FRONT,0,0;
	    while(<FRONT>) {
		if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) 2/){
		    $dist= distance($cxo,$cyo,$1,$2);
		    if ($dist < $near) {
			$near=$dist;
			if ($dist<80000) {last;}  #version 24 optim change
		    }
		}
	    }
	    if ($near <80000) {
		push (@possible,$tgt_name);
		if ($tgt_name !~ m/aerodromo/) { # a las cuidades le damos 2 oportunidades
		    push (@possible,$tgt_name); 
		}
	    }
	}
    }
    #suministros azules
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/(SUC[0-9]{2}),([^,]+),([^,]+),([^,]+),[^:]*:2.*$/) { 
	    $tgt_name=$2;
	    push (@possible,$2); 
	}
    }
    #print "blue possible targets: ".join(" ",@possible)." \n"; #debug 
    $blue_target=@possible[int(rand(scalar(@possible)))]; # get a random one
}


# Print information to the control file, so later parser can read information about this mission
sub print_details(){
    print DET "MAP_NAME_LOAD=".$MAP_NAME_LOAD."\n";
    print DET "MAP_NAME_LONG=".$MAP_NAME_LONG."\n";
    print DET "RED_ATTK_TACTIC=".$RED_ATTK_TACTIC."\n";
    print DET "BLUE_ATTK_TACTIC=".$BLUE_ATTK_TACTIC."\n";
    print DET "RED_RECON=".$RED_RECON."\n";
    print DET "BLUE_RECON=".$BLUE_RECON."\n";
    print DET "RED_SUM_TIME=".$RED_SUM_TIME."\n"; # timepo para recon en minutos 
    print DET "BLUE_SUM_TIME=".$BLUE_SUM_TIME."\n"; # timepo para recon en minutos
    print DET "RED_SUM=".$RED_SUM."\n";
    print DET "BLUE_SUM=".$BLUE_SUM."\n";
    print DET "RED_SUM_AI=".$RED_SUM_AI."\n"; # 0 o cantidad de aviones ai en suply
    print DET "BLUE_SUM_AI=".$BLUE_SUM_AI."\n"; # 0 o cantidad de aviones ai en suply
    print DET "RED_SUM_AI_LAND=".$RED_SUM_AI_LAND."\n"; # AFCODE donde aterrizan
    print DET "BLUE_SUM_AI_LAND=".$BLUE_SUM_AI_LAND."\n"; # AFCODE donde aterrizan
    print DET "red_target=".$red_target."\n";
    print DET "red_tgt_code=".$red_tgt_code."\n";
    print DET "red_tgtcx=".$red_tgtcx."\n";
    print DET "red_tgtcy=".$red_tgtcy."\n";
    print DET "blue_target=".$blue_target."\n";
    print DET "blue_tgt_code=".$blue_tgt_code."\n";
    print DET "blue_tgtcx=".$blue_tgtcx."\n";
    print DET "blue_tgtcy=".$blue_tgtcy."\n";
    print DET "red_af1_code=".$red_af1_code."\n";
    if ($red_af2_code ne "" && $red_af2_code ne $red_af1_code ) {
	print DET "red_af2_code=".$red_af2_code."\n";
    }
    print DET "blue_af1_code=".$blue_af1_code."\n";
    if ($blue_af2_code ne "" && $blue_af2_code ne $blue_af1_code ) {
	print DET "blue_af2_code=".$blue_af2_code."\n";
    }

    my $groups; 
    my ($i,$j);

    print DET "->grupos defensa rojos\n";
    $groups= (scalar(@red_def_grplst)/$grpentries);
    for ( $i=0; $i<$groups;  $i++){ 
	for ( $j=0; $j<$grpentries;  $j++){ 
	    print DET $red_def_grplst[$grpentries*$i+$j].",";
	}
	print DET "1,\n"; # con el army al final
    }
    print DET "->grupos ataque rojos\n";	
    $groups = (scalar(@red_attk_grplst)/$grpentries);
    for ( $i=0; $i<$groups;  $i++){ 
	for ( $j=0; $j<$grpentries;  $j++){ 
	    print DET $red_attk_grplst[$grpentries*$i+$j].",";
	}
	print DET "1,\n"; # army al final
    }
    print DET "->grupos defensa azules\n";
    $groups = (scalar(@blue_def_grplst)/$grpentries);
    for ( $i=0; $i<$groups;  $i++){ 
	for ( $j=0; $j<$grpentries;  $j++){ 
	    print DET $blue_def_grplst[$grpentries*$i+$j].",";
	}
	print DET "2,\n"; #army al final
    }
    print DET "->grupos ataque azules\n";
    $groups = (scalar(@blue_attk_grplst)/$grpentries);
    for ( $i=0; $i<$groups;  $i++){ 
	for ( $j=0; $j<$grpentries;  $j++){ 
	    print DET $blue_attk_grplst[$grpentries*$i+$j].",";
	}
	print DET "2,\n"; # army al final
    }
    print DET "---\n";

    print DET "Archivo de control de Mision:  badc".$extend.".mis \n";
    my $gen_date=scalar(localtime(time));
    print DET "time=$gen_date \n"; 
    print DET "mission time=".$mis_time."\n";  
    print DET "Download=$Dhost\n";
    print DET "Redhost=$Rhost\n";
    print DET "Bluehost=$Bhost\n";
    if ($unix_cgi){
	print DET "Redsolic=$red_solic\n";
	print DET "Bluesolic=$blue_solic\n";
    }
    print DET "ZipCode=$ZipCode\n";
}


#------------------------------------------------------------------------------------------------------
## MAIN 
#------------------------------------------------------------------------------------------------------

srand;  # randomize

open (GEN_LOG, ">>Gen_log.txt") || die "$0 : " .scalar(localtime(time)) ." Can't open File Gen_log.txt $!\n";


$Rhost="Rhost unknow";
$Bhost="Bhost unknow";
$Dhost="Dhost unknow";


if ($unix_cgi){

    open(STDERR, ">&GEN_LOG") or die;

    &ReadParse(*in);
    print &PrintHeader;


print &print_start_html();
    
    eval {fork and exit;};
    
    if ( -e "$gen_lock" ||  -e "$parser_lock" || -e "$gen_stop"){
	print "$big_red ERROR: <br>Please try to generate mission  in some minutes.<br>\n";
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ." ERROR: lock file found\n\n";
	exit(0);
    }
    else {
	open (LK,">$gen_lock"); #generamos uno
	print LK "$$\n"; #imprimimos PID en primera linea.
	close (LK);
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ." Lock created\n";
    }
    
    if (! open (LK,"<$gen_lock")) {
	print "<br> $big_red ERROR: Lock reopen fail.<br>\n";
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ." ERROR: lock reopen fail.\n\n";
	exit(0);
    }
    else {
	$_ =readline(LK);
	close(LK);
	if ($_ !~ m/$$/) {
	    print "<br> $big_red ERROR: Currently generating other mission. <br> Try again in a minute.<br>\n";
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ." ERROR: not my lock $$ $_ \n\n";
	    exit(0);
	}
    }



    $pwd=$in{'pwd'};
    $host=$in{'host'};
    $red_solic=$in{'red_solic'}; 
    $blue_solic=$in{'blue_solic'};

    $host =~ s/ //g;    
    $pwd  =~ s/ //g;    
    $host =~ s/\'//g;
    $host =~ s/\"//g;    
    $Dhost=$host;

    # verificar campos vacios 
    if ($host eq "" || $pwd eq "") {
	print "$big_red Error: </font>  Name or password is NULL<br>\n";
        
        print &print_end_html();
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ." ERROR: Name or password is NULL\n\n";
        exit(0);
    }

    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");

    if (! $dbh) { 

    print &PrintHeader;
    print &print_start_html();
    
    print "Can't connect to DB<br>\n";
    
    print &print_end_html();
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ." Cant connect to Mysql Server\n\n";
    die "$0: Can't connect to DB\n";
}


    # ver si el piloto esta en DB
    $sth = $dbh->prepare("SELECT COUNT(*) FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($host);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0]==0) { #pilot no existe
	print "$big_red Error: </font>  Pilot not found in database <br>\n";
        
        print &print_end_html();
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR:  Pilot not found in database $host\n\n";
        exit(0);
    }

    #verificar el pwd
    $sth = $dbh->prepare("SELECT password,in_sqd_name,sqd_accepted  FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($host);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $pwd) {
	print "$big_red Error: </font>  Name or password not valid<br>\n";
        
        print &print_end_html();
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR: Name or password not valid\n\n";
        exit(0);
    }

    # verificar que sea el game host del request
    $sth = $dbh->prepare("SELECT slot FROM $host_slots_tbl WHERE epoca=?");
    $sth->execute($red_solic);
    @row = $sth->fetchrow_array;
    $sth->finish;
    my $parent_slot = $row[0];
    $parent_slot=~ s/RR//; # cambiamos a host
    if ($parent_slot !~ m/BW[123456]/) {
	print "$big_red Error: </font> I cant find Mission.<br>\n";
	print "This problem usually is because you are trying to download a mission from a outdated page.<br>\n";
	print "or one request was deleted at same time you start mission creation. Reload and try again.Tnx.<br>\n";
        
        print &print_end_html();
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR: cant find parent slot redsolic: $red_solic\n\n";
        exit(0);
    }
    $sth = $dbh->prepare("SELECT hlname FROM $host_slots_tbl WHERE slot=?");
    $sth->execute($parent_slot);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $host){
	print "$big_red Error: </font> You are not allowed to generate this mission.<br>\n";
	print "Name Loged... please do not abuse.<br>\n";
	print "If you are the host and you think you have this message by mistake inform problem. Tnx.<br>\n";
        
        print &print_end_html();
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR:  $host not allowed to generate this mission. real hst: $row[0]\n\n";
        exit(0);
    }
}


if ( ! open (GEO_OBJ, "<$GEOGRAFIC_COORDINATES") ) {
    print "$big_red Error: </font> Cant open file  Geo objects<br>\n";
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR: Cant open File $GEOGRAFIC_COORDINATES: $!\n\n";
    exit(0);
}
if ( ! open (FRONT, "<$FRONT_LINE") ) {
    print "$big_red Error: </font> Cant open file frontline <br>\n";
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR: Cant open File $FRONT_LINE: $!\n\n";
    exit(0);
}
if ( ! open (FLIGHTS, "<$FLIGHTS_DEF") ) {
    print "$big_red Error: </font> Cant open file flights def <br>\n";
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR: Cant open File $FLIGHTS_DEF: $!\n\n";
    exit(0);
}
if ( ! open (RED_OBJ, "<$RED_OBJ_FILE") ) {
    print "$big_red Error: </font> Cant open file red objects <br>\n";
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR: Cant open File $RED_OBJ_FILE: $!\n\n";
    exit(0);
}
if ( ! open (BLUE_OBJ, "<$BLUE_OBJ_FILE") ) {
    print "$big_red Error: </font> Cant open file blue objects <br>\n";
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR: Cant open File $BLUE_OBJ_FILE: $!\n\n";
    exit(0);
}
if ( ! open (CITY, "<$CITY_PLACES") ) {
    print "$big_red Error: </font> Cant open file city_places <br>\n";
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ."  ERROR: Cant open File $CITY_PLACES: $!\n\n";
    exit(0);
}



$red_fig_attk_planes=4;
$red_fig_def_planes=4;
$blue_fig_attk_planes=4;
$blue_fig_def_planes=4;

$red_bom_attk_planes=6;
$red_bom_def_planes=4;
$blue_bom_attk_planes=6;
$blue_bom_def_planes=4;

$red_bom_attk_type="";
$red_bom_def_type="";
$blue_bom_attk_type="";
$blue_bom_def_type="";

$red_bom_attk_ai=0;
$red_bom_def_ai=0;
$blue_bom_attk_ai=0;
$blue_bom_def_ai=0;

$red_fig_attk_ai=0;
$red_fig_def_ai=0;
$blue_fig_attk_ai=0;
$blue_fig_def_ai=0;

$red_target="Red Target Unknow"; 
$blue_target="Blue Target Unknow";

# Antes de comenzar, verificamos que los dos bandos tengan ALGUN AF, sino terminar.
if (! aviable_af() ) {
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: No aviable Airfields. \n\n";
    exit (0);
}


#targets_areas
#-------------
if ($unix_cgi){
    if (! open(OPT,"<options.txt")){
	print "$big_red Error: </font>  Cant open options.txt file <br>\n";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: Cant open options.txt file \n\n";
	exit(0);
    }
    my $red_ok=0;
    my $blue_ok=0;
    my $red_req_planes=0;
    my $blue_req_planes=0;
    seek OPT, 0,0;
    while (<OPT>){
                     #1093586694,R,JG10r_Dutertre,4,SUM-Stalingrado-S,02,0,02,1,----,06,1,----,04,0,
	if ($_ =~ m/^$red_solic,R,([^,]+),([0-9]+),([^,]+),0?([0-9]),([01]),0?([0-9]),([01]),([^,]+),0?([0-9]),([01]),([^,]+),0?([0-9]),([01]),/){
	    $Rhost=$1;
	    $red_req_planes=$2;
	    $red_target=$3; 

	    $red_fig_attk_planes=$4;
	    $red_fig_attk_ai=$5;
	    $red_fig_def_planes=$6;
	    $red_fig_def_ai=$7;

	    $red_bom_attk_type=$8;
	    if ($red_bom_attk_type eq "----"){$red_bom_attk_type="";}
	    $red_bom_attk_planes=$9;
	    $red_bom_attk_ai=$10;

	    $red_bom_def_type=$11;
	    if ($red_bom_def_type eq "----"){$red_bom_def_type="";}
	    $red_bom_def_planes=$12;
	    $red_bom_def_ai=$13;

	    $red_ok=1;
	    print GEN_LOG "Pid $$ : RedReq: $_";
	    last;
	}
    }
    seek OPT, 0,0;
    while (<OPT>){

	if ($_ =~ m/^$blue_solic,B,([^,]+),([0-9]+),([^,]+),0?([0-9]),([01]),0?([0-9]),([01]),([^,]+),0?([0-9]),([01]),([^,]+),0?([0-9]),([01]),/){
	    $Bhost=$1;
	    $blue_req_planes=$2;
	    $blue_target=$3; 
	    $blue_fig_attk_planes=$4;
	    $blue_fig_attk_ai=$5;
	    $blue_fig_def_planes=$6;
	    $blue_fig_def_ai=$7;

	    $blue_bom_attk_type=$8;
	    if ($blue_bom_attk_type eq "----"){$blue_bom_attk_type="";}
	    $blue_bom_attk_planes=$9;
	    $blue_bom_attk_ai=$10;

	    $blue_bom_def_type=$11;
	    if ($blue_bom_def_type eq "----"){$blue_bom_def_type="";}
	    $blue_bom_def_planes=$12;
	    $blue_bom_def_ai=$13;
	    
	    $blue_ok=1;
	    print GEN_LOG "Pid $$ : BlueReq: $_"; #sacar
	    last;
	}
    }
    close(OPT);
    if ($red_ok==0) { 
	print "$big_red Error: </font> Sovietic request culd not be interpreted\n";
	
	print &print_end_html();
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: Sovietic request culd not be interpreted\n\n";
	exit(0);
    }
    if ($blue_ok==0) { 
	print "$big_red Error: </font> German request culd not be interpreted\n";
	
	print &print_end_html();
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: German request culd not be interpreted\n\n";
	exit(0);
    }

    $red_ok=0;
    $blue_ok=0;
    my $Options_R="Options_R.txt";
    my $Options_B="Options_B.txt";
    open (OPR,"<$Options_R");
    open (OPB,"<$Options_B");

    while(<OPR>) {
	if ($_ =~ m/$red_target/) { $red_ok=1; last;}
    }
    close(OPR);
    while(<OPB>) {
	if ($_ =~ m/$blue_target/) { $blue_ok=1; last;}
    }
    close(OPB);

    if ($blue_ok==0 || $red_ok==0) { 
	print " $big_red Error: </font> One of the requested targets  not aviable right now. This can be because a recent report.<br>\n";
	print " Please go <b>back</b> and remake request. Be sure to reload pages and not use a cached version.<br><br>\n";
	if ($red_ok==0)  {
	    print " $red_target in not aviable<br>\n";
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: Red tgt: $red_target  not aviable\n\n";
	}
	if ($blue_ok==0) {
	    print " $blue_target in not aviable<br>\n";
	    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: Blue tgt: $blue_target not aviable\n\n";
	}
	
	print &print_end_html();
	unlink $gen_lock;
	exit;
    }
}
else {
    select_random_tagets();
#    $red_target="LLovlya"; 
#    $blue_target="SUM-LLovlya";
}

if ($unix_cgi){
    if (! open(U_OPT,">>used_options.txt")){
	print "$big_red Error: </font>  Cant open used_options.txt file.\n";
	unlink $gen_lock;
	print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: Cant open used_options.txt file.\n\n";
	exit(0);	
    }
    else {
	my $gen_date=scalar(localtime(time));
	print U_OPT $red_solic." $Dhost $gen_date\n";
	print U_OPT $blue_solic." $Dhost $gen_date\n---------- ---\n";
	close (U_OPT);

	# Buscar el slot de BW y borrarlo
	$sth = $dbh->prepare("SELECT slot FROM $host_slots_tbl WHERE hlname=?");
	$sth->execute($host);
	@row = $sth->fetchrow_array;
	$sth->finish;
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=0,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"$row[0]\"");
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=1,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$row[0]."RR\"");
	$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=2,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$row[0]."BR\"");

	#  "limpiar DB " de pedidos que expiraron
	my $now_epoch=time;
	my @bw_slots = ("BW1","BW2","BW3","BW4","BW5","BW6");
	
	foreach my $look (@bw_slots) {
	    $sth = $dbh->prepare("SELECT epoca FROM $host_slots_tbl WHERE slot=?");
	    $sth->execute($look);
	    @row = $sth->fetchrow_array;
	    $sth->finish;
	    if ($row[0] < $now_epoch) { # si caduco
		$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=0,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"$look\"");
		$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=1,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$look."RR\"");
		$dbh->do("UPDATE $host_slots_tbl SET  status = 0,  hlname = '',  army=2,  epoca=0,  date='',  time='',  max_human=0,  tgt_name='',  fig_attk_nbr=0, fig_def_nbr=0,  bomb_attk_type='',  bomb_attk_nbr=0,  bomb_attk_ai=0,  bomb_def_type='',  bomb_def_nbr=0,  bomb_def_ai=0 WHERE slot=\"".$look."BR\"");
	    }
	}
    }
}

#establecemos los limites del mapa: creamos 2 variables globales.(total=10)

seek GEO_OBJ, 0, 0;
while(<GEO_OBJ>) {
    if ($_ =~ m/^MAP_RIGHT *= *([0-9]+)/) {
	$MAP_RIGHT=$1;
    }
    if ($_ =~ m/^MAP_TOP *= *([0-9]+)/) {
	$MAP_TOP=$1;
    }
    if ( defined $MAP_RIGHT && defined $MAP_TOP ) { last;} 
}
if ( (!defined $MAP_RIGHT) || (!defined $MAP_TOP) ) {  # revisar si anda bien esto
    print "$big_red Error: </font>  MAP_RIGHT anr/or MAP_TOP values not set on File $GEOGRAFIC_COORDINATES.\n";
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . "  ERROR: MAP_RIGHT anr/or MAP_TOP values not set on File $GEOGRAFIC_COORDINATES.\n\n";
    exit(0);
}

# somebody asked RECONS?  (Not implemented)
#----
$RED_RECON=0;
$BLUE_RECON=0;
if ($red_target =~ m/^REC-.*/){
    $RED_RECON=1;
}
if ($blue_target =~ m/^REC-.*/){
    $BLUE_RECON=1;
}
# Somebody asked SUPLY? 
#----
$RED_SUM=0;
$BLUE_SUM=0;
$RED_SUM_AI=0;
$BLUE_SUM_AI=0;
$RED_SUM_AI_LAND="";
$BLUE_SUM_AI_LAND="";
if ($red_target =~ m/^SUM-.*/){
    $RED_SUM=1;
    if ($red_bom_attk_ai==1) {$RED_SUM_AI=$red_bom_attk_planes;} # amount of AI suply planes
}
if ($blue_target =~ m/^SUM-.*/){
    $BLUE_SUM=1;
    if ($blue_bom_attk_ai==1) {$BLUE_SUM_AI=$blue_bom_attk_planes;} # amount of AI suply planes
}




# verify that targets are placed on enemy area, exeption is a suply
# aditionally set the target coordinates and the target code (internal name)
#------------
$red_tgt_code="";
$red_tgtcx=0;
$red_tgtcy=0;
$blue_tgt_code="";
$blue_tgtcx=0;
$blue_tgtcy=0;
check_targets_places();



# set_attacks_types() 
# Now determine if the objetives to attack are tatic or strategic.
# We need this to know what type of flight we have to build
# this determines and set values for BD and BA for each army
$RED_ATTK_TACTIC=0; 
$BLUE_ATTK_TACTIC=0;
$red_bomb_attk=0;
$red_bomb_defend=0;
$blue_bomb_attk=0;
$blue_bomb_defend=0;
set_attacks_types(); 


if ($RED_ATTK_TACTIC==1) {
    @red_tank_wp=();
    $red_tanks_groups=3; #  set to 3. warning on changing this, can impact on many places
}
if ($BLUE_ATTK_TACTIC==1){
    @blue_tank_wp=();
    $blue_tanks_groups=3;  # set to 3. warning on changing this, can impact on many places
}


# Before start build mission, get a mission number. it is called exted because
# number has a underscore at begining, so we use this variable as extension on mission name
$extend= get_mission_nbr();

# Zip code was a very first try to add a password to zip mission files.
# but latar i discart this and use .htaccess acces control.  Anyway, this zip code is used as random
# text for making temopary folders and reduce name guessing.

my @vocales = ("a","e","i","o","u"); # 5 vocales
my @consonantes = ("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","z"); # 20 cons (sin y)

$ZipCode= $extend . "_" . $consonantes[(int(rand(20)))] . $vocales[(int(rand(5)))] . $consonantes[(int(rand(20)))] .
    $vocales[(int(rand(5)))] . (chr(int(rand(10))+48)) . (chr(int(rand(10))+48)) ;

open (MIS, ">$PATH_TO_WEBROOT/gen/badc$extend.mis"); 
open (DET, ">$PATH_TO_WEBROOT/gen/det_badc$extend.txt");


# this initialize wheather to some random values. We will read values from the ones set on 
# last reported mission (created by parser), but just in case we leave this set to some values
$hora=int(rand(10)+7); # hour : 7 ~ 16
$minutos=int(rand(60)); # minutes:  0 ~ 59
$clima=int(rand(98)); #1..97 this is a number to set weather
$nubes=500+(int(rand(10))+1)*100; # 500 .. 1500 clouds


if (! open (CLIMA,"<clima.txt")){ # cant open weather file, we use random values
    print GEN_LOG "WARNING: CAN'T OPEN clima.txt, using rand values <br>\n";
    print "WARNING: CAN'T OPEN clima.txt, using rand values <br>\n"; }
else { # we read weather values from file (warning, not cheking for corrup data file)
    $hora=readline(CLIMA);
    chop($hora);
    $minutos=readline(CLIMA);
    chop($minutos);
    $clima=readline(CLIMA);
    chop($clima);
    $nubes=readline(CLIMA);
    chop($nubes);
    close(CLIMA);
}


$mis_time=$hora+(int($minutos/60*100)/100); # set time in decimal display (2 decimal points) 14:45 -> 14.75
if ($minutos<10) {
    $minutos="0$minutos"; # this is for later use in briefings to avoid display incorrect time
}

$tipo_clima="Bueno"; # just a initial value, on print_header() we set correct weather type
print_header(); # This prints the mission header, common to all missions.

# build group list flights
$grpentries=11;  # WARNING , if fileds  of group list is changed this value MUST be updated, if not a casacde of problems
@red_def_grplst=();
@red_attk_grplst=();
@blue_def_grplst=();
@blue_attk_grplst=();
build_grplsts(); # build the groups
print_grplsts(); # print groups into mission. The order they are printed will be the order on the runway


#ARMAR LOS WP para cada player y para cada GRPLIST  (ACA HAY QUE AGREGAR DEFEND WP, RECON WP etc.)
# Y  ademas estas funciones van a dejar seteados las coord de los AF en uso para poblar 
# (... globales mas), (total=muchas) porque puse mas af :(
#---------

$red_af_count=0; # this holds the amount of taking-off airfiels (not landing)
$blue_af_count=0; # same for blue

#there can be up to 4 airfiels, 2 starting (take off) and 2 landing.
$red_af1_code=""; $red_af1_cx=0; $red_af1_cy=0;
$red_af2_code=""; $red_af2_cx=0; $red_af2_cy=0;
$red_af3_code=""; $red_af3_cx=0; $red_af3_cy=0;
$red_af4_code=""; $red_af4_cx=0; $red_af4_cy=0;
# same for blue 
$blue_af1_code=""; $blue_af1_cx=0; $blue_af1_cy=0;
$blue_af2_code=""; $blue_af2_cx=0; $blue_af2_cy=0;
$blue_af3_code=""; $blue_af3_cx=0; $blue_af3_cy=0;
$blue_af4_code=""; $blue_af4_cx=0; $blue_af4_cy=0;

$RED_ATTK_TGT=0;   # distance AF  -> TGT
$RED_ATTK_HOME=0;  # distance TGT -> HOME
$BLUE_ATTK_TGT=0;  # distance AF  -> TGT
$BLUE_ATTK_HOME=0; # distance TGT -> HOME

$RED_SUM_TIME=0;   # time for red recon
$BLUE_SUM_TIME=0;  # time for blue recon

$red_ship_af=0;
@red_ship_chosed=();
$blue_ship_af=0;
@blue_ship_chosed=();

my $player; # 1=RED 2=BLUE CHECK
$player=1; # we start building red WP
if (scalar(@red_def_grplst)>0){ # if red has at least one defend group
    @grplst=@red_def_grplst;  	# bombers_wp and fighters_wp will use the flights defined in:  @grplst

    if ($BLUE_ATTK_TACTIC==1){ # if blue attack tactic (a red sector)
	# we send a bomber group defend to the pace blue is attacking (the red sector we defend)
	($RED_DEF_TGT,$RED_DEF_HOME)=bombers_wp($player,$blue_tgtcx,$blue_tgtcy,"BD"); 
    }
    else { # if blue attack strategic (BA or SUM) we send interceps
	# warning, using $blue_attk_grplst[1] as default enemy name
	fighters_wp($player,$blue_tgtcx,$blue_tgtcy,$blue_attk_grplst[1]); 
    }
}

if (scalar(@red_attk_grplst)>0){ # if red has at least one attack  group
    @grplst=@red_attk_grplst;
    if ($RED_ATTK_TACTIC==1){ # red atacks with tanks, we send ET 
	my $enemy_name="notgt"; # this will hold enemy BD group name if any.
	if (scalar(@blue_def_grplst)>0){
	    $enemy_name=$blue_def_grplst[1]; # warning, using $blue_attk_grplst[1] as default
	}
	fighters_wp($player,$red_tgtcx,$red_tgtcy,$enemy_name); 
    }
    else { # red is making a BA or a SUM
	my $mis_type="";
	if ($RED_SUM) {$mis_type="SUM";}
	else {$mis_type="BA";}

	if ($red_target =~ m/aerodromo/){
	    ($red_tgtcx,$red_tgtcy)=find_close_obj_area($red_tgtcx,$red_tgtcy); # CHECK, esto anda solo para AF
	}
	($RED_ATTK_TGT,$RED_ATTK_HOME)=bombers_wp($player,$red_tgtcx,$red_tgtcy,$mis_type);
	if ($RED_SUM) {$RED_SUM_TIME= int(20 + (($RED_ATTK_TGT+$RED_ATTK_HOME) * 1.4 * 60 / $VVS_TRP_SPEED ));} 
    }
}

$player=2; # now all the same, but for blue army

if (scalar(@blue_def_grplst)>0){ # if blue  has at least one defend group
    @grplst=@blue_def_grplst; # bombers_wp and fighters_wp will use the flights defined in:  @grplst

    if ($RED_ATTK_TACTIC==1){ # if red attack tactic (a blue sector)
	# we send a bomber group defend to the place red is attacking (the blue sector we defend)
	($BLUE_DEF_TGT,$BLUE_DEF_HOME)=bombers_wp($player,$red_tgtcx,$red_tgtcy,"BD");  
    }
    else { # if red attack strategic (BA or SUM) we send interceps
	# warning, using $red_attk_grplst[1] as enemy name
	fighters_wp($player,$red_tgtcx,$red_tgtcy,$red_attk_grplst[1]);
    }
}

if (scalar(@blue_attk_grplst)>0){ # if blue  has at least one attack group
    @grplst=@blue_attk_grplst;
    if ($BLUE_ATTK_TACTIC==1){  # blue attacks with tanks, we send ET
	my $enemy_name="notgt"; # this will hold enemy BD group name if any.
	if (scalar(@red_def_grplst)>0){
	    $enemy_name=$red_def_grplst[1]; # guarda, uso defaul value [1]
	}
	fighters_wp($player,$blue_tgtcx,$blue_tgtcy,$enemy_name);
    }
    else {
	my $mis_type="";
	if ($BLUE_SUM) {$mis_type="SUM";}
	else {$mis_type="BA";}

	if ($blue_target =~ m/aerodromo/){
	    ($blue_tgtcx,$blue_tgtcy)=find_close_obj_area($blue_tgtcx,$blue_tgtcy); # CHECK es para AF
	}
	($BLUE_ATTK_TGT,$BLUE_ATTK_HOME)=bombers_wp($player,$blue_tgtcx,$blue_tgtcy,$mis_type);
	if ($BLUE_SUM) {$BLUE_SUM_TIME= int(20 + (($BLUE_ATTK_TGT+$BLUE_ATTK_HOME) * 1.4 * 60 / $LW_TRP_SPEED ));}
    }
}

# Now we print chiefs
if ($RED_ATTK_TACTIC==1 || $BLUE_ATTK_TACTIC==1) {
#    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) . " Using champ type: $CHAMP_TYPE.\n";
    print MIS "[Chiefs]\n";
    $chief_counter=0;
    add_tanks();  # and we add tanks
}


# Now we print static objects
print MIS "[NStationary]\n";
$s_obj_counter=0;    # global counter of static objects
add_test_runways();  # runways that are static ships
obj_id_airfields();  # places basic static objects (a JU52 or LI2)in airfiles, so AF has correct color (not white bases). 
static_on_afields(); # poblates all 4 posible airfields for each army, and AF that are bombers targets
static_on_city();    # poblates city
add_tank_static();   # add static tanks, on filed champs
static_aaa_on_sum_city(); # poblates SUM citys with AAA

# Now we print buildings
print MIS "[Buildings]\n";
add_tank_biulding(); # add buldings on field champs

# place a recon target on each target (Disabled, used on betas)
print MIS "[Target]\n";
#print MIS "3 1 1 150 501 ".int($red_tgtcx)." ".int($red_tgtcy)." 1000\n";
#print MIS "3 1 1 150 501 ".int($blue_tgtcx)." ".int($blue_tgtcy)." 1000\n";


# place a camera on each target, so playing tracks will have a camera to see action :)
print MIS "[StaticCamera]\n";
if ($RED_ATTK_TACTIC==1){ print MIS int($red_tank_wp[2])." ".int($red_tank_wp[3])." 100\n";}
else{print MIS int($red_tgtcx)." ".int($red_tgtcy)." 100\n";}

if ($BLUE_ATTK_TACTIC==1){ print MIS int($blue_tank_wp[2])." ".int($blue_tank_wp[3])." 100\n";}
else{ print MIS int($blue_tgtcx)." ".int($blue_tgtcy)." 100\n";}


# place forntline markers
print MIS "[FrontMarker]\n";  # CHECK, despues imprimir solo los frontmarker de frontera.
print_fm();


# print the parser control file, with meta data of mission, so parser can know what was the target
# flights definition, amount of tanks, and other info.
print_details();
# print briefings 
print_briefing(); 


# close files
# ---------
close(MIS);
close(DET);
close (RED_OBJ);
close (BLUE_OBJ);
close(FLIGHTS);
close(FRONT);
close(GEO_OBJ);    
close(CITY);

if (! $unix_cgi){ # runing on comand line
    print "Mision generada:  badc".$extend." \n"; 

    if ($RED_ATTK_TACTIC) {print  "VVS ataca Tactico\n";}
    if ($RED_SUM) {print  "VVS hace suministro\n";}
    if ($RED_RECON) {print  "VVS hace reconocimiento\n";}
    if (!$RED_ATTK_TACTIC && !$RED_RECON && !$RED_SUM) {print  "VVS ataca Estrategico\n";}

    if ($BLUE_ATTK_TACTIC) {print  "LW ataca Tactico\n";}
    if ($BLUE_SUM) {print  "LW hace suministro\n";}
    if ($BLUE_RECON) {print  "LW hace reconocimiento\n";}
    if (!$BLUE_ATTK_TACTIC && !$BLUE_RECON && !$BLUE_SUM) {print  "LW ataca Estrategico\n";}
}
else { # runing as cgi: make zip, password and offer download, track mission date ant time on DB

    # we are going to use player name and player passwd as arguments to htpasswd program
    # so we need to use safe names and passwords (avoid string manupulation = hacking)
    my $safe_name=$Dhost;
    my $safe_pwd=$pwd;
    $safe_name =~ s/[\"&\'();<>\`|+*=?\[\]\$\%\/\\:]//g; #
    $safe_pwd =~ s/[\"&\'();<>\`|+*=?\[\]\$\%\/\\:]//g; #

    if ($WINDOWS) {
	eval `mkdir $PATH_TO_WEBROOT\\tmp\\$ZipCode`;       # temporay folder for download mission 
	open (HTACC,">$PATH_TO_WEBROOT/tmp/$ZipCode/.htaccess"); # create an htaccess file
	print HTACC "AuthName \"Enter your nickname and password.\"\n";
	print HTACC "AuthType \"basic\"\n"; 
	print HTACC "AuthUserFile $PATH_TO_WEBROOT\\tmp\\$ZipCode\\passwd\n";
	print HTACC "require valid-user\n";
	close (HTACC);
#	eval `$HTPASSWD_PROG $HTPASSWD_FLAGS $PATH_TO_WEBROOT\\tmp\\$ZipCode\\passwd $safe_name $safe_pwd`; # dunno why fails
	eval `$HTPASSWD_PROG -nb $safe_name $safe_pwd > $PATH_TO_WEBROOT\\tmp\\$ZipCode\\passwd `; # this works
	# make zip can copy to temp place:
	eval `$ZIP_PROG $ZIP_FLAGS $PATH_TO_WEBROOT\\gen\\badc$extend.zip $PATH_TO_WEBROOT\\gen\\badc$extend.mis $PATH_TO_WEBROOT\\gen\\badc$extend.properties`;
	eval `copy $PATH_TO_WEBROOT\\gen\\badc$extend.zip $PATH_TO_WEBROOT\\tmp\\$ZipCode\\badc$extend.zip`;
    }
    else {
	eval `mkdir $PATH_TO_WEBROOT/tmp/$ZipCode`;       # temporay folder for download mission 
	open (HTACC,">$PATH_TO_WEBROOT/tmp/$ZipCode/.htaccess"); # create an htaccess file
	print HTACC "AuthName \"Enter your nickname and password.\"\n";
	print HTACC "AuthType \"basic\"\n"; 
	print HTACC "AuthUserFile $PATH_TO_WEBROOT/tmp/$ZipCode/passwd\n";
	print HTACC "require valid-user\n";
	close (HTACC);
	eval `$HTPASSWD_PROG $HTPASSWD_FLAGS $PATH_TO_WEBROOT/tmp/$ZipCode/passwd $safe_name $safe_pwd`;
	# make zip can copy to temp place:
	eval `$ZIP_PROG $ZIP_FLAGS $PATH_TO_WEBROOT/gen/badc$extend.zip $PATH_TO_WEBROOT/gen/badc$extend.mis $PATH_TO_WEBROOT/gen/badc$extend.properties`;
	eval `cp $PATH_TO_WEBROOT/gen/badc$extend.zip $PATH_TO_WEBROOT/tmp/$ZipCode/badc$extend.zip`;
    }

    print "Mission generated ok.<br><br>\n";
    print "Save the mission with right mouse click and  \"save as\"<br>";
    print "Mission: <a href=\"/tmp/$ZipCode/badc".$extend.".zip\">badc".$extend.".zip</a><br><br>";
    print "On autorization window write:<br>\n";

    if ($Dhost eq $safe_name) {
	print "<b>Username:</b> <font color=\"blue\" size=\"+1\">$Dhost</font><br>\n";
    }
    else {
	print "<b>Username:</b> <font color=\"red\" size=\"+1\">$safe_name</font>(NOTE: is different from your campaign name)<br>\n";
    }

    if ($pwd eq $safe_pwd) {
	print "<b>Password:</b> <font color=\"blue\" size=\"+1\">Your pilot password</font><br><br>\n";
    }
    else {
	print "<b>Password:</b> <font color=\"red\" size=\"+1\">$safe_pwd</font> (NOTE: is different from your campaign password)<br><br>\n";
    }
    print "<br><font size=\"+1\"><a href=\"/create.php\">Return genaration page</a></font><br>\n";
    print "<br><font size=\"+1\"><a href=\"/index.html\">Return to index</a></font><br>\n";
    


    print "<head>\n";
    print "  <META HTTP-EQUIV=\'refresh\' CONTENT=\'1; URL=/tmp/$ZipCode/badc".$extend.".zip\'>";
    print "</head>\n";

    print &print_end_html();

    # date calculations: MP_date (Mission Progress date)
    my ($MP_dia,$MP_mes,$MP_anio)=(localtime)[3,4,5];
    $MP_mes+=1;
    $MP_anio+=1900;
    if ($MP_mes <10){ $MP_mes="0".$MP_mes;}
    if ($MP_dia <10){ $MP_dia="0".$MP_dia;}
    my $MP_date = $MP_anio."-".$MP_mes."-".$MP_dia;

    # time calculations:  MP_time (Mission Progress time)  
    my ($MP_sec,$MP_min,$MP_hour)=(localtime(time))[0,1,2];
    if ($MP_sec <10){ $MP_sec="0".$MP_sec;}
    if ($MP_min <10){ $MP_min="0".$MP_min;}
    if ($MP_hour <10){ $MP_hour="0".$MP_hour;}
    my $MP_time = $MP_hour.":".$MP_min.":".$MP_sec;

    my $epoca = time; # current epoch
    $dbh->do("INSERT INTO $mis_prog VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",undef,("badc".$extend),$Dhost,$red_target,$blue_target,$Rhost,$Bhost,0,"-",$MP_date,$MP_time,$epoca,"","",0,0,0,0,1,"","",0);
    unlink $gen_lock;
    print GEN_LOG "Pid $$ : " .scalar(localtime(time)) ." Mission: /tmp/$ZipCode/badc".$extend.".zip \n\n";
    $dbh->disconnect();
}
close(GEN_LOG);

# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;

$MAP_NAME_LONG=$MAP_NAME_LONG;
$MAX_FIGHTERS_DIST=$MAX_FIGHTERS_DIST;
$MIN_BOMBERS_DIST=$MIN_BOMBERS_DIST;
$MAX_BOMBERS_DIST=$MAX_BOMBERS_DIST;

$ZIP_PROG=$ZIP_PROG;
$ZIP_FLAGS=$ZIP_FLAGS;
$HTPASSWD_PROG=$HTPASSWD_PROG;
$HTPASSWD_FLAGS=$HTPASSWD_FLAGS;
$mis_prog=$mis_prog;
$WINDOWS=$WINDOWS;
$ALLIED_TANKS_ATTK=$ALLIED_TANKS_ATTK;
$AXIS_TANKS_ATTK=$AXIS_TANKS_ATTK;
$ALLIED_TANKS_DEF=$ALLIED_TANKS_DEF;
$AXIS_TANKS_DEF=$AXIS_TANKS_DEF;
$VVS_TRP_SPEED=$VVS_TRP_SPEED;
$LW_TRP_SPEED=$LW_TRP_SPEED;
$parser_lock=$parser_lock;
$gen_stop=$gen_stop;
