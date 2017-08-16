#!/usr/bin/perl 

require "config.pl";
require "ui.pl";
require "dztools.pl";
require "dzmap.pl";

use IO::Handle;   # because autoflush
use DBI();
use POSIX;

$|=1; #STDOUT HOT

if (! defined $ENV{'HTTP_USER_AGENT'}) { $unix_cgi=0;}  

if ($unix_cgi){

    require "cgi-lib.pl";
    use DBI();
    
    print &PrintHeader;
    #print &HtmlTop;
    print <<TOP;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
      <META HTTP-EQUIV="PRAGMA" CONTENT="no-cache">
      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      <link rel="stylesheet" type="text/css" href="/badc.css">
      <title>Suply image update output</title> 
</head>
<body>


<div id="hoja">

  <a href="/index.html"><img border="0" src="/images/logo.gif"  alt="Home" style="margin-left: 40px; margin-top: 0px" ></a>
  <br><br><br><br>

<div id="central">

TOP
    ;
    my @row;
    my $dbh;
    my $sth;
    
    # sqd data
    my $hlname="";
    my $pwd="";
    my $succeed=1;
    

    # Limit upload size: para evitar intentos de buffer overflow.
    $cgi_lib::maxdata = 512; 
    $cgi_lib::maxdata = 512; 
    
    &ReadParse(%in); # Read data
    
    
    $hlname=$in{'hlname'};
    $pwd=$in{'pwd'};
    $hlname=~ s/^ *//g;
    $hlname=~ s/ *$//g;
    
    if ($hlname =~ m/ / || $hlname eq "" || $pwd eq "" ){ 
	print "Error: Name or password not valid<br>\n";
	print &HtmlBot;
	exit(0);
    }
    
    # verificar user/pwd en DB
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    if (! $dbh) { 
        print "Can't connect to DB\n";
        die "$0: Can't connect to DB\n";
    }    
    $sth = $dbh->prepare("SELECT password  FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $pwd) {
	print "Error: Name or password invalid <br>\n";
	print &HtmlBot;
	exit(0);
    }

    if ( $hlname ne $super_user) {
	print "Error: Unautorized user<br>\n";
	print &HtmlBot;
	exit(0);
    }

}


# MAIN START
sub distance ($$$$);
sub printdebug($);
sub get_af_in_radius($$$$);
sub get_coord_city($);
sub get_sum_radius($);
sub get_map_vday();
sub print_map_and_points($);
sub print_time_and_weather($$$$$$$$);
sub print_headquarter($$);
sub print_plane_inventory($$$);
sub print_airfield_damage($$$);
sub print_city_damage($$$);

sub distance ($$$$) {
    my ($x1,$y1,$x2,$y2)=@_;
    return (sqrt(($x1-$x2)**2+($y1-$y2)**2));
}

sub printdebug($) {
    my $log = shift (@_);
    if ($DZDEBUG) {
       print scalar(localtime(time)) . $log . "\n";	
    }
}

chdir $CGI_BIN_PATH; 

if (!(open (COU,"<rep_counter.data"))){
    die "ERROR: Can't open report counter file : $!\n";
}
$ext_rep_nbr=<COU>;
$rep_count=$ext_rep_nbr;
$rep_count =~ s/_//;
close (COU);


if (!open (GEO_OBJ, "<$GEOGRAFIC_COORDINATES")) {
    print "$big_red ERROR: Can't open File $GEOGRAFIC_COORDINATES: $! on main proc <br>\n";
    print "Please NOTIFY this error.\n";
    die "ERROR: Can't open File $GEOGRAFIC_COORDINATES: $! on main proc\n";
}

if (!open (FRONT, "<$FRONT_LINE")){
    print "$big_red ERROR: Can't open File $FRONT_LINE: $! on main proc <br> \n";
    print "Please NOTIFY this error.\n";
    die "ERROR: Can't open File $FRONT_LINE: $! on main proc\n";
}

# Condiciones de victoria
my $af_red_colapsed=0;
my $af_blue_colapsed=0;
my $red_hq_captured=0;
my $blue_hq_captured=0;

#CLIMA para la proxima mision

my $hora;
my $minutos;
my $clima;
my $nubes;
srand;
$mission_of_day=(($rep_count) % $MIS_PER_VDAY); # MoD for NEXT mission
if ($mission_of_day==0) {$mission_of_day=$MIS_PER_VDAY;}

my $map_vday = get_map_vday();

my $time_increase= int((($SUNSET - $SUNRISE)*60) / $MIS_PER_VDAY); # (12 hours * 60 minutes/hour) / $MIS_PER_VDAY
$hora=$SUNRISE;
$minutos=0;
$min_diff=($rep_count % $MIS_PER_VDAY) * $time_increase;
$min_diff+=int(rand($min_diff));  # 0 ~ ($min_diff -1) random extra time.
$hora+= int($min_diff /60);
$minutos+= int($min_diff % 60);

$clima=int(rand(100))+1; #1..100 
$nubes=500+(int(rand(10))+1)*100; # 500 .. 1500

my $new_clima=0;
if (! open (CLIMA,"<clima.txt")) { # cant open weather file, we use random values
    open (CLIMA,">clima.txt");
    print CLIMA $hora."\n";
    print CLIMA $minutos."\n";
    print CLIMA $clima."\n";
    print CLIMA $nubes."\n";
    close(CLIMA);
    print "WARNING: CAN'T OPEN clima.txt, creating one <br>\n";
    $new_clima=1;
}
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

    my $tipo_clima;
    my $tipo_clima_spa;
    if ($clima<=20){ # clima 1..20 -> 20% Clear
	$tipo_clima="Clear";
	$tipo_clima_spa="Despejado";
	$nubes=" -- "; # para  la pagina del generador. (ya esta guardado en disco).
    }
    if ($clima>20 && $clima<=90){ # clima 21..90 -> 70% Good
	$tipo_clima="Good";
	$tipo_clima_spa="Bueno";	
    }
    if ($clima>90 && $clima<=95){ # clima 91..95 -> 5% Blind
	$tipo_clima="Low Visibility";
	$tipo_clima_spa="Baja visibilidad";	
    }
    if ($clima>95 && $clima<=99){ # clima 96..99 -> 4% Rain/Snow
	$tipo_clima="Precipitations";
	$tipo_clima_spa="Lluvia";	
    }
    if ($clima>99 && $clima<=100){ # clima only 100 -> 1% Strom
	$tipo_clima="Storm";
	$tipo_clima_spa="Tormenta";	
    }

    if ($new_clima){
        my $localt="";
        if ($WINDOWS) {
    	$localt=localtime(time);
        }
        else {
    	$localt=`date`;	
        }
        open (CLIMACTL,">>clima_control.txt");
        print CLIMACTL "Manual change -  hora: $hora min: $minutos nubes: $nubes clima: $clima = ";    
        print CLIMACTL "$tipo_clima : $localt";
        close(CLIMACTL);
    }


    $MAP_FILE="$PATH_TO_WEBROOT/mapa.html";
    my $Options_R="Options_R.txt";
    my $Options_B="Options_B.txt";
    my $Status="Status.txt";

#    no bakups
#    eval `cp $PATH_TO_WEBROOT/$Options_R $DATA_BKUP/$Options_R$ext_rep_nbr`; # windows cmd?
#    eval `cp $PATH_TO_WEBROOT/$Options_B $DATA_BKUP/$Options_B$ext_rep_nbr`; # windows cmd?

    open (MAPA,">$MAP_FILE")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA MAPA</font>";
    open (OPR,">$Options_R")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SRO</font>";
    open (OPB,">$Options_B")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SBO</font>";
    open (STA,">$Status")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SRS</font>";

    print_map_and_points(MAPA);    
    print_time_and_weather(MAPA, STA, $map_vday, $mission_of_day, $hora, $minutos, $tipo_clima_spa, $nubes);
    
    ($red_capacity, $blue_capacity, $red_plane_supply, $blue_plane_supply) = print_headquarter(MAPA, STA);
    
    ($red_task_stock, $red_stock_out, $blue_task_stock, $blue_stock_out) = print_plane_inventory(MAPA, STA, STDOUT);
    my %red_task_stock = %$red_task_stock;
    my %blue_task_stock = %$blue_task_stock;

    ($cg_red_bases, $af_red_colapsed, $cg_blue_bases, $af_blue_colapsed) = print_airfield_damage(MAPA, STA, GEO_OBJ);
    my @cg_red_bases = @$cg_red_bases;
    my @cg_blue_bases = @$cg_blue_bases;

    ($red_hq_captured, $blue_hq_captured) = print_city_damage(MAPA, STA, GEO_OBJ);

    print MAPA  "<p><strong>Mapa del Frente:</strong><br>";
    print STA   "<p><strong>Mapa del Frente:</strong><br>";

    open (IMAP,"<$IMAP_DATA");
    while(<IMAP>){
	print MAPA;
    }
    close(IMAP);
#    print MAPA "<br><br><IMG SRC=\"/images/suply.jpg\" WIDTH=900 HEIGHT=780 BORDER=0 alt=\"Suply Radius\"><br><br>\n";
    print MAPA  &print_end_html;

    close (MAPA);
    close (STA);
    
    my @red_possible=();
    my $line_back;
    ## seleccion de objetivos al azar TACTICOS ROJOS
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/SEC[^,]+,([^,]+),([^,]+),([^,]+),[^:]*:2.*$/) {
	    $tgt_name=$1;
	    $cxo=$2;
	    $cyo=$3;
	    $near=500000; # gran distancia para comenzar (500 km)
	    $line_back=tell GEO_OBJ;                 ##lemos la posicion en el archivo
	    seek GEO_OBJ,0,0;
	    while(<GEO_OBJ>) {
		if ($_ =~ m/SEC[^,]+,[^,]+,([^,]+),([^,]+),[^,]+,[^:]+:1/){ #sectores rojos
		    $dist= distance($cxo,$cyo,$1,$2);
		    if ($dist<16000) {
			my $cityname="NONE";
			seek GEO_OBJ,0,0;
			while(<GEO_OBJ>) {
			    if  ($_ =~ m/poblado,([^,]+),$tgt_name/ ) { # si es un sec con city: poblado,Obol,sector--A15
				$cityname=$1;
			    }
			}
			if ($cityname ne "NONE") {
			    seek GEO_OBJ,0,0;
			    while(<GEO_OBJ>) {
				if ( $_ =~ m/^CT[0-9]{2},$cityname,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),[^:]+:[12].*$/) {
				    # print "valor da~nos $cityname = $1 \n";
				    if ($1 >50) {
					push (@red_possible,$tgt_name);
					last;
				    }
				}
			    }
			}
			else {
			    push (@red_possible,$tgt_name);
			    last;
			}
		    }
		}
	    }
	    seek GEO_OBJ,$line_back,0; # regrresamos a la misma sig linea	    
	}
    }
    ## seleccion de objetivos al azar ESTARTEGICOS rojos (SOLO AF)
    ## @Heracles@20110727
    ## Solo seleccionar AF para misión BA si quedan aviones BA
    if ($red_task_stock{BA} >= $MIN_STOCK_FOR_FLYING) {
	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/(AF.{2}),([^,]+),([^,]+),([^,]+),[^:]*:2.*$/) {
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
			    if ($dist<$MAX_DIST_AF_BA) {last;}  #version 24 optim change
			}
		    }
		}
		if ($near <$MAX_DIST_AF_BA) {
		    push (@red_possible,$tgt_name); # los ponemos al final
		}
	    }
	}
    }

    ## seleccion de SUMINISTROS A AERODROMOS ROJOS
    ## @Heracles@20110805
    ## Solo seleccionar suministro si quedan aviones SUM  y existen bases de CG con suficiente capacidad
    if ($red_task_stock{SUM} >= $MIN_STOCK_FOR_FLYING && ($red_capacity >= $red_plane_supply)) {
	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/(AF[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^,]+):1/) {
		$tgt_name= "SUA-" . $2;
		$cxo=$3;
		$cyo=$4;
		$damage=$5;
		my $cg_base=0;
		foreach my $af_cg (@cg_red_bases) {
		    if ($af_cg eq $2) {
		        $cg_base = 1;
		    }
		}		
		if ($damage > 0 && $damage < 100 && !$cg_base) {
		    unshift (@red_possible,$tgt_name);
		}
	    }
	}
    }        

    ## seleccion de SUMINISTROS A CIUDADES ROJAS
    ## @Heracles@20110727
    ## Solo seleccionar suministro si quedan aviones SUM    
    if ($red_task_stock{SUM} >= $MIN_STOCK_FOR_FLYING) {    
	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/^(SUC[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^:]+):1.*$/) {
		$tgt_name=$2;
		$cxo=$3;
		$cyo=$4;
	    
		## @Heracles@20110719@
		## No se pueden seleccionar como objetivo las ciudades con el 100% de suministro
		my $my_city = $1;
		$my_city =~ m/SUC([0-9]+)/;
		$my_city = $1;
		$line_back=tell GEO_OBJ;                 ##lemos la posicion en el archivo	    
		seek GEO_OBJ,0,0;
		while(<GEO_OBJ>) {
		    if ( $_ =~ m/^CT$my_city,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),[^:]+:[1].*$/) {
			if ($1 > 0) {
			    unshift (@red_possible,$tgt_name);
			}
			printdebug ("make_attack_page(): Suministro a ciudad $tgt_name con daño $1");
		    }
		}
		seek GEO_OBJ,$line_back,0; # regresamos a la misma sig linea	    
	    }
	}
    }

    ## seleccion de objetivos al azar ESTARTEGICOS rojos (SOLO CIUDADES)    
    ## @Heracles@20110727
    ## Solo seleccionar AF para misión BA si quedan aviones BA
    if ($red_task_stock{BA} >= $MIN_STOCK_FOR_FLYING) {
	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/^(CT[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^:]+):2.*$/) {
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
			    if ($dist<$MAX_DIST_CITY_BA) {last;}  #version 24 optim change
			}
		    }
		}
		if ($near <$MAX_DIST_CITY_BA) {
		    unshift (@red_possible,$tgt_name);
		}
	    }
	}
    }


#------------------------------------------------------

    ## seleccion de objetivos al azar TACTICOS AZULES
    my @blue_possible=();
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/SEC[^,]+,([^,]+),([^,]+),([^,]+),[^:]*:1.*$/) {
	    $tgt_name=$1;
	    $cxo=$2;
	    $cyo=$3;
	    $line_back=tell GEO_OBJ;                 ##lemos la posicion en el archivo
	    seek GEO_OBJ,0,0;
	    while(<GEO_OBJ>) {
		if ($_ =~ m/SEC[^,]+,[^,]+,([^,]+),([^,]+),[^,]+,[^:]+:2/){ #sectores azules
		    $dist= distance($cxo,$cyo,$1,$2);
		    if ($dist<16000) {
			my $cityname="NONE";
			seek GEO_OBJ,0,0;
			while(<GEO_OBJ>) {
			    if  ($_ =~ m/poblado,([^,]+),$tgt_name/ ) { # si es un sec con city: poblado,Obol,sector--A15
				$cityname=$1;
			    }
			}
			if ($cityname ne "NONE") {
			    seek GEO_OBJ,0,0;
			    while(<GEO_OBJ>) {
				if ( $_ =~ m/^CT[0-9]{2},$cityname,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),[^:]+:[12].*$/) {
				   # print "valor da~nos $cityname = $1 \n";
				    if ($1 >50) {
					push (@blue_possible,$tgt_name);
					last;
				    }
				}
			    }
			}
			else {
			    push (@blue_possible,$tgt_name);
			    last;
			}
		    }
		}
	    }
	    seek GEO_OBJ,$line_back,0; # regrresamos a la misma sig linea	    
	}
    }
    ## seleccion de objetivos al azar ESTARTEGICOS AZULES (SOLO AF)
    ## @Heracles@20110727
    ## Solo seleccionar AF para misión BA si quedan aviones BA
    if ($blue_task_stock{BA} >= $MIN_STOCK_FOR_FLYING) {    
	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/(AF.{2}),([^,]+),([^,]+),([^,]+),[^:]*:1.*$/) {
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
			    if ($dist<$MAX_DIST_AF_BA) {last;}  #version 24 optim change
			}
		    }
		}
		if ($near <$MAX_DIST_AF_BA) {
		    push (@blue_possible,$tgt_name); 
		}
	    }
	}
    }

    ## seleccion de SUMINISTROS A AERODROMOS AZULES
    ## @Heracles@20110805
    ## Solo seleccionar suministro si quedan aviones SUM
    if ($blue_task_stock{SUM} >= $MIN_STOCK_FOR_FLYING && ($blue_capacity >= $blue_plane_supply)) {
	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/(AF[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^,]+):2/) {
		$tgt_name= "SUA-" . $2;
		$cxo=$3;
		$cyo=$4;
		$damage=$5;
		my $cg_base=0;
		foreach my $af_cg (@cg_blue_bases) {
		    if ($af_cg eq $2) {
		        $cg_base = 1;
		    }
		}		
		if ($damage > 0 && $damage < 100 && !$cg_base) {
		    unshift (@blue_possible,$tgt_name);
		}
	    }
	}
    }    

    ## seleccion de SUMINISTROS a CIUDADES Azules
    ## @Heracles@20110727
    ## Solo seleccionar suministro si quedan aviones SUM    
    if ($blue_task_stock{SUM} >= $MIN_STOCK_FOR_FLYING) {        
	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/^(SUC[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^:]+):2.*$/) {
		$tgt_name=$2;
		$cxo=$3;
		$cyo=$4;

		## @Heracles@20110719@
		## No se pueden seleccionar como objetivo las ciudades con el 100% de suministro
		my $my_city = $1;
		$my_city =~ m/SUC([0-9]+)/;
		$my_city = $1;
		printdebug ("make_attack_page(): Buscando ciudad $tgt_name con codigo $my_city");	    
		$line_back=tell GEO_OBJ;                 ##lemos la posicion en el archivo	    
		seek GEO_OBJ,0,0;
		while(<GEO_OBJ>) {
		    if ( $_ =~ m/^CT$my_city,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),[^:]+:[2].*$/) {
			if ($1 > 0) {
			    unshift (@blue_possible,$tgt_name);
			}
			printdebug ("make_attack_page(): Suministro a ciudad $tgt_name con daño $1");
		    }
		}
		seek GEO_OBJ,$line_back,0; # regresamos a la misma sig linea	    
	    }
	}
    }

    ## seleccion de objetivos al azar ESTARTEGICOS AZULES (SOLO CIUDADES)
    ## @Heracles@20110727
    ## Solo seleccionar ciudad para misión BA si quedan aviones BA
    if ($blue_task_stock{BA} >= $MIN_STOCK_FOR_FLYING) {    
	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/^(CT[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^:]+):1.*$/) {
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
			    if ($dist<$MAX_DIST_CITY_BA) {last;}  #version 24 optim change
			}
		    }
		}
		if ($near <$MAX_DIST_CITY_BA) {
		    unshift (@blue_possible,$tgt_name);
		}
	    }
	}
    }

my $k;
for ($k=0; $k<scalar(@red_possible); $k++){
    print OPR "<option value=\"$red_possible[$k]\">$red_possible[$k]</option>\n";
}
for ($k=0; $k<scalar(@blue_possible); $k++){
    print OPB "<option value=\"$blue_possible[$k]\">$blue_possible[$k]</option>\n";
}

close (OPR);
close (OPB);

print "Done\n";
if ($unix_cgi){print &HtmlBot;}

# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;

$pilot_file_tbl=$pilot_file_tbl;
$super_user=$super_user;
$CGI_BIN_PATH=$CGI_BIN_PATH;
$GEOGRAFIC_COORDINATES=$GEOGRAFIC_COORDINATES;
$PATH_TO_WEBROOT=$PATH_TO_WEBROOT;
$IMAP_DATA=$IMAP_DATA;
