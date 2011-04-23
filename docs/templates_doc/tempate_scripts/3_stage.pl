

sub distance ($$$$) {
    my ($x1,$y1,$x2,$y2)=@_;
    return (sqrt(($x1-$x2)**2+($y1-$y2)**2));
}



$INITIAL_LINE="initial.mis";
if (!open (INIT_FL, "<$INITIAL_LINE")){
    print "ERROR: Can't open File $INITIAL_LINE: $!\n";
    <>;
    exit(0);
}
$MAP_NAME="";
seek INIT_FL, 0, 0;
while(<INIT_FL>) {
    if ($_ =~ m/MAP (.*)$/ ) { $MAP_NAME="$1"; }
}

$GEOGRAFIC_COORDINATES="geo_obj.data";
if (!open (GEO_OBJ, "<$GEOGRAFIC_COORDINATES")) {
    die "ERROR: Can't open File $GEOGRAFIC_COORDINATES: $! on main proc\n";
}

$FRONT_LINE="frontline.mis";
open (FRONT, ">$FRONT_LINE");
    
my $sec;
my $cxo;
my $cyo;
my $ttl;
my $suply;
my $new_army;
my $orig_army;
my $near; 
my $dist;
my $fm_count=0;

print FRONT <<Head;
FRONT_LINE_VERSION=00000
[MAIN]
  MAP $MAP_NAME
  TIME 12.0
  CloudType 0
  CloudHeight 1000.0
  army 1
  playerNum 0
[NStationary]
[Buildings]
[Bridge]
[House]
[FrontMarker]
Head
    ;

seek GEO_OBJ,0,0;
while(<GEO_OBJ>) {
    if ($_ =~  m/(SEC[^,]+,[^,]+),([^,]+),([^,]+),([^,]+),([^:]+):([0123])/) {
	$sec=$1;
	$cxo=$2;
	$cyo=$3;
	$ttl=$4;
	$suply=$5;
	$orig_army=$6;
	$near=500000; # gran distancia para comenzar (500 km)
	seek INIT_FL,0,0;
	while(<INIT_FL>) {
	    if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) ([0-2])/){
		$dist= distance($cxo,$cyo,$1,$2);
		if ($dist < $near) {
		    $near=$dist;
		    $new_army=$3;
		}
	    }
	}
	$cxo= ((int($cxo/10000))*10000)+5000;
	$cyo= ((int($cyo/10000))*10000)+5000;
	if ($orig_army !=3) { 
	    print FRONT "FrontMarker".$fm_count." $cxo $cyo $new_army\n";
	    $fm_count++;
	}
    }
}
close(FRONT);
close(INIT_FL); 



#sincro GEO_FILE

if (!open (FRONT, "<$FRONT_LINE")){
    print "ERROR: Can't open File $FRONT_LINE: $! on main proc\n";
    <>;
    exit(0);
}
    
my $orig_data;
my $army;

open (TEMP, ">temp_geo_obj.data"); # CHECK.. verificar que no exista un temp..._obj.data de otro porceso!!
print TEMP "FRONT_LINE_VERSION=00000\n\n";

seek GEO_OBJ,0,0;
while(<GEO_OBJ>) {
    if ($_ =~  m/(AF.{2}|SEC[^,]+|CT[0-9]{2}|SUC[0-9]{2}),[^,]+,([^,]+),([^,]+),[^:]*:([0-2])/) {
	$orig_data=$_;
	$cxo=$2;
	$cyo=$3;
	$army=$4;
	$near=500000; # gran distancia para comenzar (500 km)
	seek FRONT,0,0;
	while(<FRONT>) {
	    if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) ([0-2])/){
		$dist= distance($cxo,$cyo,$1,$2);
		if ($dist < $near) {
		    $near=$dist;
		    $army=$3;
		}
	    }
	}
	$orig_data =~ s/^([^:]+):[0-3]/$1:$army/;
	print TEMP $orig_data;
    }
    else {
	print TEMP $_;
    }
}
close(TEMP); # cerramos para renombrar
close(GEO_OBJ); # cerramos para borrar/o hacer nkup
unlink $GEOGRAFIC_COORDINATES;  ##  backup en lugar de borrar?? si mejor --cambiar CHECK
rename "temp_geo_obj.data", $GEOGRAFIC_COORDINATES; ## renombramos
if (!open (GEO_OBJ, "<$GEOGRAFIC_COORDINATES")) { #reabrimos
    die "ERROR: Can't open File $GEOGRAFIC_COORDINATES: $! on sub check_geo_file\n"; 
}

close(FRONT); # cerramos para borrar/o hacer nkup
close(GEO_OBJ); # cerramos para borrar/o hacer nkup
