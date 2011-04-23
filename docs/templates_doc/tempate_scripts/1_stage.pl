
sub distance ($$$$);

# distance
sub distance ($$$$) {
    my ($x1,$y1,$x2,$y2)=@_;
    return (sqrt(($x1-$x2)**2+($y1-$y2)**2));
}



@letras=("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK","AL","AM","AN","AO","AP","AQ","AR","AS","AT","AU","AV","AW","AX","AY","AZ","BA","BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BO","BP","BQ","BR","BS","BT","BU","BV","BW","BX","BY","BZ");

$MISION="initial.mis";
if( ! open (MIS_IN, "<$MISION")){
    print  "cant open $MISION: $!\n";
    <>;
    exit(0);
}

$MAP_NAME="";
$MAP_RIGHT=0;
$MAP_TOP=0;

seek MIS_IN, 0, 0;
while(<MIS_IN>) {
    if ($_ =~ m/MAP (.*)$/ ) { $MAP_NAME="$1"; }
    if ($_ =~ m/Static vehicles\.stationary\.Campfire\$CampfireAirfield 0 ([^ ]+) ([^ ]+)/) {
	$MAP_RIGHT=$1;
	$MAP_TOP=$2;
    }
}
$MAP_RIGHT= (int($MAP_RIGHT/1000))*1000;
$MAP_TOP= (int($MAP_TOP/1000))*1000;


open (GEO, ">geo_obj.data");
print GEO "FRONT_LINE_VERSION=00000\n\n";
print GEO "MAP_RIGHT=$MAP_RIGHT\n";
print GEO "MAP_TOP=$MAP_TOP\n\n\n\n";

my $afcount=0;
my $parkcount=0;
my $linea=0;

seek MIS_IN, 0, 0;
while(<MIS_IN>) {
    if ($_ !~ m/ *TAKEOFF ([^ ]+) ([^ ]+)/){
	; # nada
    }
    else{ 
	$coord_p1x=$1;
	$coord_p1y=$2;	
	$_=readline(MIS_IN);
	$_ =~ m/ *LANDING ([^ ]+) ([^ ]+)/;
	$coord_p2x=$1;
	$coord_p2y=$2;
	$centro_x=int(($coord_p2x-$coord_p1x)/2) + $coord_p1x;
	$centro_y=int(($coord_p2y-$coord_p1y)/2) + $coord_p1y;
	$afcount++;
	$l = $letras[int($centro_x/10000)];
	$n = int($centro_y/10000)+1;
	if ($n<10) {$n = "0".$n;}
	my $afnbr=$afcount;
	if ($afcount<10) { $afnbr="0".$afcount; }
	print GEO "AF".$afnbr.",aerodromo--$l$n,$centro_x,$centro_y,2,-$l,$n,2,0:0\n";
	print GEO "AF".$afnbr.":H1,$coord_p1x,$coord_p1y,\n"; 
	print GEO "AF".$afnbr.":H2,$coord_p2x,$coord_p2y,\n";
	$line_back=tell MIS_IN;    # save las read pos place
	$linea=0;
	$parkcount=0;
	seek MIS_IN, 0, 0;
	while(<MIS_IN>) {
	    $linea++;
	    if ($_ !~ m/ *NORMFLY ([^ ]+) ([^ ]+)/){
		; # nothing
	    }
	    elsif (distance($centro_x,$centro_y,$1,$2)<3000) {
		$coord_p1x=$1;
		$coord_p1y=$2;			
		$_=readline(MIS_IN);
		$_ =~ m/ *NORMFLY ([^ ]+) ([^ ]+) ([^ ]+)/;
		$coord_p2x=$1;
		$coord_p2y=$2;
		$vector_x = ($coord_p2x - $coord_p1x);
		$vector_y = ($coord_p2y - $coord_p1y);
		$modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
		if ($modulo==0) { 
		    print "Incorrect WP amount. Expected pair number of WP, read even.\n";
		    print "incorrect data in file $MISION on line: $linea \n\n";
		    print "enter to end";
		    <>;
		    exit(0);
		}
		$vector_x/=$modulo;
		$vector_y/=$modulo;
		$parkcount++;

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
		$angle=360-$angle; # para los rusos es giro en otro sentido.
		$angle=int($angle); # el valor entero
		$angle+=90;
		if ($parkcount==10) {print GEO "# ------------------------------- WARNING, park count >9\n";}
		#AF06:P1,86532.39,27156.00,86761.66,27134.35,100,
		print GEO "AF".$afnbr.":P".$parkcount.",$coord_p1x,$coord_p1y,$coord_p2x,$coord_p2y,$angle,\n";
	    }
	}
	print GEO "#--- End AF".$afnbr." (aerodromo--$l$n)\n\n";
	seek MIS_IN,$line_back,0; # return to las read pos
    }
}
print GEO "\n\n";

close (GEO);


open (TANK, ">tank_wp.mis");
print TANK "[MAIN]\n";
print TANK "MAP $MAP_NAME\n";
print TANK "  TIME 12.0\n";
print TANK "  CloudType 0\n";
print TANK "  CloudHeight 1000.0\n";
print TANK "  army 1\n";
print TANK "  playerNum 0\n";
print TANK "[NStationary]\n";

my $num=0;
for ($j=0; $j<$MAP_RIGHT; $j+=10000){
    for ($i=0; $i<$MAP_TOP; $i+=10000){

	print TANK $num."_Static vehicles.artillery.Artillery\$PzVA 2 ".($j+5000)." ".($i+5000)." 0 0\n";
	$num++;
	print TANK $num."_Static vehicles.artillery.Artillery\$PzVA 2 ".($j+1400)." ".($i+1200)." 0 0\n";
	$num++;
	print TANK $num."_Static vehicles.artillery.Artillery\$PzVA 2 ".($j+9100)." ".($i+1200)." 0 0\n";
	$num++;
	print TANK $num."_Static vehicles.artillery.Artillery\$PzVA 2 ".($j+9100)." ".($i+9200)." 0 0\n";
	$num++;
	print TANK $num."_Static vehicles.artillery.Artillery\$PzVA 2 ".($j+1100)." ".($i+8800)." 0 0\n";
	$num++;

    }

}
close (TANK);


open (RED_OBJ, ">red_obj.mis");
open (BLUE_OBJ, ">blue_obj.mis");
print RED_OBJ "[MAIN]\n";
print RED_OBJ "MAP $MAP_NAME\n";
print RED_OBJ "  TIME 12.0\n";
print RED_OBJ "  CloudType 0\n";
print RED_OBJ "  CloudHeight 1000.0\n";
print RED_OBJ "  army 1\n";
print RED_OBJ "  playerNum 0\n";
print RED_OBJ "[NStationary]\n";

print BLUE_OBJ "[MAIN]\n";
print BLUE_OBJ "MAP $MAP_NAME\n";
print BLUE_OBJ "  TIME 12.0\n";
print BLUE_OBJ "  CloudType 0\n";
print BLUE_OBJ "  CloudHeight 1000.0\n";
print BLUE_OBJ "  army 1\n";
print BLUE_OBJ "  playerNum 0\n";
print BLUE_OBJ "[NStationary]\n";


my $red_obj_nbr=0;
my $blue_obj_nbr=10000;
seek MIS_IN, 0, 0;
while(<MIS_IN>) {
    if ($_ =~ m/Static vehicles\.planes\.Plane\$JU_52_3MG4E [12] ([^ ]+) ([^ ]+) ([^ ]+)/) {
	print RED_OBJ " ".$red_obj_nbr."_Static vehicles.planes.Plane\$LI_2 1 $1 $2 $3 0.0\n";
	$red_obj_nbr++;
	print BLUE_OBJ " ".$blue_obj_nbr."_Static vehicles.planes.Plane\$JU_52_3MG4E 2 $1 $2 $3 0.0\n";
	$blue_obj_nbr++;
    }
}

print RED_OBJ "[Buildings]\n";
print RED_OBJ "[Bridge]\n";
print RED_OBJ "[House]\n";

print BLUE_OBJ "[Buildings]\n";
print BLUE_OBJ "[Bridge]\n";
print BLUE_OBJ "[House]\n";

close (RED_OBJ);
close (BLUE_OBJ);



open (CITY, ">city.mis");
print CITY "[MAIN]\n";
print CITY "MAP $MAP_NAME\n";
print CITY "  TIME 12.0\n";
print CITY "  CloudType 0\n";
print CITY "  CloudHeight 1000.0\n";
print CITY "  army 1\n";
print CITY "  playerNum 0\n";
print CITY "[NStationary]\n";
print CITY "[Buildings]\n";
print CITY "[Bridge]\n";
print CITY "[House]\n";
close(CITY);
