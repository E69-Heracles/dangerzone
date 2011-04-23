
sub distance ($$$$);

sub distance ($$$$) {
    my ($x1,$y1,$x2,$y2)=@_;
    return (sqrt(($x1-$x2)**2+($y1-$y2)**2));
}


$MISION="initial.mis";
if( ! open (MIS_IN, "<$MISION")){
    print  "cant open $MISION: $!\n";
    <>;
    exit(0);
}

$MAP_RIGHT=0;
$MAP_TOP=0;

seek MIS_IN, 0, 0;
while(<MIS_IN>) {
    if ($_ =~ m/Static vehicles\.stationary\.Campfire\$CampfireAirfield 0 ([^ ]+) ([^ ]+)/) {
	$MAP_RIGHT=$1;
	$MAP_TOP=$2;
    }
}
$MAP_RIGHT= (int($MAP_RIGHT/1000))*1000;
$MAP_TOP= (int($MAP_TOP/1000))*1000;
close (MIS_IN);


open (GEO, ">>geo_obj.data");
print GEO "\n\n";

my $TANKS_WP="tank_wp.mis";  

if (! (open (TKWP, "<$TANKS_WP"))){
    print "Can't open File : $TANKS_WP : $!\n";
    <>;
    exit(0);
}


my @letras=("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK","AL","AM","AN","AO","AP","AQ","AR","AS","AT","AU","AV","AW","AX","AY","AZ","BA","BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BO","BP","BQ","BR","BS","BT","BU","BV","BW","BX","BY","BZ");

for (my $tgt_cx=5000; $tgt_cx<$MAP_RIGHT; $tgt_cx+=10000) {   # coord X
    for (my $tgt_cy=5000; $tgt_cy<$MAP_TOP; $tgt_cy+=10000) { # coord Y
	my $count=0;
	seek TKWP,0,0;
	while (<TKWP>) {
	    if ($_=~ m/ *[0-9]+_Static [^ ]+ [12] ([^ ]+) ([^ ]+) [^ ]+ [^ ]+/) {
		if ( $1<($tgt_cx+5000) && $1>($tgt_cx-5000) && 
		     $2<($tgt_cy+5000) && $2>($tgt_cy-5000)){ #encontramos un wp
		    $count++;
		}
	    }
	}
	my $l = $letras[int($tgt_cx/10000)];
	my $n = int($tgt_cy/10000)+1;
	if ($n<10) {$n = "0".$n;}
	#SEC-A01,sector--A01,5000,5000,30,1:3
	my $army=0;
	if ($count==0 || $count==1) {$army=3} # no attack
	if ($count==1) {print "Warning, only 1 tank wp on sector--$l$n , I set to un-atacable\n"} 
	print GEO "SEC-$l$n,sector--$l$n,$tgt_cx,$tgt_cy,30,1:$army\n";
    }
}


print GEO "\n\n";



# MAIN 
#----------------------------------

if (! open (CITY, "<city.mis")){
    print "cant open city.mis\n";
    <>;
    exit(0);
}

my $city_count=0;
my $place_count=0;
my $line_back=0;


seek CITY, 0, 0;
while(<CITY>) {
    if ($_ =~ m/ vehicles.aeronautics.Aeronautics[^ ]+ [012] ([^ ]+) ([^ ]+) /){ # maracador de ciudad
	$city_count++;

	$coord_cx=$1;	
	$coord_cy=$2;	
	my $l = $letras[int($coord_cx/10000)];
	my $n = int($coord_cy/10000)+1;
	if ($n<10) {$n = "0".$n;}

	print GEO "# Name  $l$n\n";
	print GEO "SUC";
	if ($city_count<10) {print GEO "0";}
	print GEO $city_count .",SUM-city-$l$n,".$1.",".$2.",-,-,-,-,-:0\n";

	print GEO "CT";
	if ($city_count<10) {print GEO "0";}
	print GEO $city_count .",city-$l$n,".$1.",".$2.",25,tipo,TOTAL_ZONES_HERE,0,25:0\n";

	$place_count=0;
	$line_back=tell CITY;                 ##leemos la posicion en el archivo
	seek CITY, 0, 0;
	while(<CITY>) {
	    if ($_ =~  m/ vehicles.stationary.Campfire[^ ]+ [012] ([^ ]+) ([^ ]+) /){ # maracador de attack place
		if (distance($coord_cx,$coord_cy,$1,$2)<5000){
		    print GEO "CT";
		    if ($city_count<10) {print GEO "0";}
		    print GEO $city_count ."Z".$place_count.":".$1.",".$2.",1\n";
		    $place_count++;
		}
	    }
	}
	print GEO "\n";

	seek CITY,$line_back,0; # regrresamos una linea para atras
    }
}




seek CITY, 0, 0;
while(<CITY>) {
    if ($_ =~ m/ vehicles.aeronautics.Aeronautics[^ ]+ [012] ([^ ]+) ([^ ]+) /){ # maracador de ciudad
	$coord_cx=$1;	
	$coord_cy=$2;	
	my $l = $letras[int($coord_cx/10000)];
	my $n = int($coord_cy/10000)+1;
	if ($n<10) {$n = "0".$n;}
	print GEO "poblado,city-$l$n,sector--$l$n\n";
    }
}
print GEO "\n\n";


close(CITY);



