require "config.pl";

use IO::Handle;   # because autoflush
use DBI();
use POSIX;

## @Heracles@20110827
## Calcula el valor de capacidad SUA diario para un bando. Ojo! Necesita para el calculo las variables globales $red_stock y $blue_stock
## Parametros: armada
sub calc_sua_capacity($) {
    my $army = shift @_;
    my $capacity = ($army == 1) ? $VDAY_PRODUCTION_RED : $VDAY_PRODUCTION_BLUE;
    
    return $capacity;
}

## @Heracles@20110827
## Da valor a la capacidad SUA de un bando.
## Parametros: capacidad, armada
sub set_sua_capacity($$){
    my $capacity = shift @_;
    my $army = shift @_;
    my $hq = ($army == 1) ? $RED_HQ : $BLUE_HQ;
    
    printdebug ("set_sua_capacity(): Entrando con capacidad $capacity\n");
    
    open (TEMPGEO, ">temp_geo.data"); #
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	$_ =~  s/^(SUC[0-9]{2},SUM-$hq,[^,]+,[^,]+),[^,]+,([^,]+,[^,]+,[^,]+,[^:]+):$army/$1,$capacity,$2:$army/;
	print TEMPGEO;
    }
    
    close(TEMPGEO);
    close(GEO_OBJ);
    unlink $GEOGRAFIC_COORDINATES;
    rename "temp_geo.data",$GEOGRAFIC_COORDINATES;
    if (!open (GEO_OBJ, "<$GEOGRAFIC_COORDINATES")) {
	print "$big_red FATAL ERROR: Can't open File $GEOGRAFIC_COORDINATES: $! on sub eventos_aire <br>\n";
	print "Please NOTIFY this error.\n";
	print &print_end_html();
	printdebug ("set_sua_capacity(): ERROR: Can't open File $GEOGRAFIC_COORDINATES: $!\n");
	exit(0);
    }    
}

## @Heracles@20110827
## Retorna la capacidad SUA de un bando. Si la capacidad SUA no esta especificada en el geo_obj, se escribe el nuevo valor.
## Parametros: armada
sub get_sua_capacity($) {
    my $army = shift @_;
    my $hq = ($army == 1) ? $RED_HQ : $BLUE_HQ;
    my $capacity = 0;
    
    my $line_back=tell GEO_OBJ; 
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) { 
	if ($_ =~  m/^SUC[0-9]{2},SUM-$hq,[^,]+,[^,]+,([^,]+),[^,]+,[^,]+,[^,]+,[^:]+:$army/) {
	    $capacity = $1;
	    last;
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos
    
    return $capacity;     
}

## @Heracles@20110816
## Retorna las bases del cuartel general
## Parametros: armada
sub get_cg_bases($) {
    my $army = shift @_;
    my $cgcx;
    my $cgcy;
    my $cg_sum_radius;
    my $cg_bases = 0;
    my @bases=();
    
    my $hq = ($army == 1) ? $RED_HQ : $BLUE_HQ;
	
    # Buscar Af en radio de CG para cargar suministros
    ($cgcx, $cgcy) = get_coord_city($hq);
    $cg_sum_radius = get_sum_radius($hq);
    ($cg_bases, @bases) = get_af_in_radius($cgcx, $cgcy, $cg_sum_radius, $army);
    
    return ($cg_bases, @bases);
}

## @Heracles@20110728
## Obtiene el nombre amigable de un aerodromo
## Parametros : Clave de aerodromo (AF99)
sub get_af_name($) {
    my $afclave = shift @_;
    my $afname="NONE";
    my $aflarge="NONE";
    
    my $line_back=tell GEO_OBJ; 
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) { 
	if ($_ =~ m/^$afclave,([^,]+),[^,]+,[^,]+,[^,]+,([^,]+),([^,]+),[^,]+,[^,]+:[12]/) {
	    $aflarge=$1;
	    $afname = $2 . $3;
	    $afname =~ s/-//;
	    last;
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos         
    return ($aflarge, $afname);    
}

## @Heracles@20110816
## Obtiene el codigo de un aerodromo
## Parametros : Nombre largo de aerodromo
sub get_af_code($) {
    my $afname = shift @_;
    my $afclave="NONE";
    
    my $line_back=tell GEO_OBJ; 
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) { 
	if ($_ =~ m/^(AF[0-9]{2}),$afname,[^,]+,[^,]+,[^,]+,([^,]+),([^,]+),[^,]+,[^,]+:[12]/) {
	    $afclave=$1;
	    last;
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos         
    return ($afclave);    
}

# @Heracles@20110805
# Retorna el nombre de un AF a partir de sus coordenadas. Util para saber si un piloto aterrizo en un af
# Parametros: cx, cy, armada
sub get_af_by_coord($$$) {
    my $cx = shift @_;
    my $cy = shift @_;
    my $army = shift @_;
    my $land_af = "NONE";
    my $land_code = "NONE";
    my $af_cx = 0;
    my $af_cy = 0;

    my $line_back=tell GEO_OBJ; # pos del log        
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^(AF[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,[^:]+:$army/){ 
	    if (distance($3, $4, $cx, $cy) <= 2000) {
		$land_code = $1;
		$land_af = $2;
		$af_cx = $3;
		$af_cy = $4;
		last;
	    }
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos    
    
    return ($land_code, $land_af, $af_cx, $af_cy);
}

# @Heracles@20110807
# retorna el daño de un aerodromo
# Parametro: el nombre largo del aerodromo
sub get_af_damage($) {
    my $afname = shift @_;
    my $damage = -1;
    
    my $line_back=tell GEO_OBJ; # pos del log        
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^AF[0-9]{2},$afname,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^:]+):[12]/){ 
	    $damage = $1;
	    last;
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos
    
    return $damage;
}

# Heracles@20110423
# Retorna el numero de bases dentro de un radio con centro en cx, cy y una lista con el codigo de esas bases
# Parametros: coordenada x, coordenad y, radio, armada
sub get_af_in_radius($$$$) {
    my $cx = shift @_;
    my $cy = shift @_;
    my $radius = shift @_;
    my $army = shift @_;
    
    my $bases = 0;
    my @base_list = ();
    
    my $line_back=tell GEO_OBJ; # pos del log        
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^(AF[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,[^:]+:$army/){ 
	    if (distance($3, $4, $cx, $cy) <= $radius) {
		$bases++;
		push (@base_list, $2);
	    }
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos
    
    return ($bases, @base_list);        
}

# @Heracles@20110807
# Retorna las coordenadas de un aerodromo. Retorno -1 en caso de error.
# Parametros: El nombre del aerodromo tal cómo aparece en el segundo campo de un línea AF del geo_obj
sub get_coord_af($) {
    my ($my_af) = @_;
    
    my $cx = -1;
    my $cy = -1;
    my $code;
    
    my $line_back=tell GEO_OBJ; # pos del log        
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
        if ($_ =~ m/^(AF[0-9]{2}),$my_af,([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,[^:]+:[12]/){
	    $code = $1;
	    $cx = $2;
	    $cy = $3;	    
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos
    
    return ($cx, $cy);    
}

# @Heracles@20110805
# Retorna si un Af esta dentro del radio de suministro del CG
# Parametros: cx, cy, armada
sub is_coord_in_cg_radius($$$){
    my $cx = shift @_;
    my $cy = shift @_;
    my $army = shift @_;
    my $CG = ($army == 1) ? $RED_HQ : $BLUE_HQ;
    
    my $radius = get_sum_radius($CG);
    my ($cg_cx, $cg_cy) = get_coord_city($CG);
    
    if (distance($cx, $cy, $cg_cx, $cg_cy) <= $radius) {
	return 1;
    }
    else {
	return 0;
    }
}

# @Heracles@20110423
# Retorna las coordenadas de una ciudad. Retorno -1 en caso de error.
# Parametros: El nombre de la ciudad tal cómo aparece en el segundo campo de un línea CT del geo_obj
sub get_coord_city($) {
    my ($my_city) = @_;
    
    my $cx = -1;
    my $cy = -1;    
    
    my $line_back=tell GEO_OBJ; # pos del log        
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
        if ($_ =~ m/^CT[0-9]+,$my_city,([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,[^,]+:([12])/){
	    $cx = $1;
	    $cy = $2;	    
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos
    
    return ($cx, $cy);    
}

# @Heracles@20110423
# Retorna el radio de suministro de una ciudad. Retorna -1 en caso de error.
# Parámetros : El nombre de la ciudad tal cómo aparece en el segundo campo de un línea CT del geo_obj
sub get_sum_radius($) {
    my ($my_city) = @_;
    
    my $my_radius = -1;
    
    my $line_back=tell GEO_OBJ; # pos del log        
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
        if ($_ =~ m/^CT[0-9]+,$my_city,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+):([12])/){
	    $my_radius = $1 * 1000;
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos
    
    return $my_radius;
}


# @Heracles@20110730
# Calcula el número de aviones de inventario para cada bando
sub calc_stocks_plane() {
    my @redstock_matrix=();
    my @bluestock_matrix=();
    my $planereal = 0;
    my $red_stock = 0;
    my $blue_stock = 0;
    my $red_losts = 0;
    my $blue_losts =0;
    
    if (!open (FLIGHTS, "<$FLIGHTS_DEF")) {
	print "$big_red ERROR Can't open File $FLIGHTS_DEF: $! on get_flight()\n";
	print "Please NOTIFY this error.\n";
	print &print_end_html();
	printdebug (" ERROR: Can't open File $FLIGHTS_DEF: $! on get_flight()\n");
	exit(0);
    }    

    seek FLIGHTS,0,0;
    while (<FLIGHTS>) {
	if ($_ =~ m/^IR,([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),/){ # $1: Modelo, $2: Stock inicial, $3:Sock actual, $4: aparacion en misiones, $5:perdidas
	    push(@redstock_matrix,[$1,$2,$3,$4,$5]);
	}
	if ($_ =~ m/^IA,([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),/){ # $1: Modelo, $2: Stock inicial, $3:Sock actual, $4: aparacion en misiones, $5:perdidas
	    push(@bluestock_matrix,[$1,$2,$3,$4,$5]);
	}
    }
	
    close(FLIGHTS);

    ## Calculo de total de aviones iniciales rojos
    for ( my $i=0; $i < scalar(@redstock_matrix); $i++) {
	$planereal += $redstock_matrix[$i][2];
	$red_losts += $redstock_matrix[$i][4];
    }    
    
    $red_stock = $planereal;
    $planereal = 0;
    
    ## Calculo de total de aviones iniciales azules
    for ( my $i=0; $i < scalar(@bluestock_matrix); $i++) {
	$planereal += $bluestock_matrix[$i][2];
	$blue_losts += $bluestock_matrix[$i][4];
    }
    
    $blue_stock = $planereal;
    printdebug ("calc_stocks_plane(): rojos/perdidas $red_stock/$red_losts azules/perdidas $blue_stock/$blue_losts\n");    
    return($red_stock, $blue_stock, $red_losts, $blue_losts);
}

# @Heracles@20110730@
# Calcula el suministro a aerodromo por avion SUM
# Parámetros: stock rojo, stock azul
sub calc_sum_plane_supply($$) {
    my $red_stock = shift @_;
    my $blue_stock = shift @_;

    my $red_supply = 0;
    my $blue_supply = 0;
    
    $red_supply = ceil (($red_stock * $SUM_STOCK_RATE_PLANE)/100);
    $blue_supply = ceil (($blue_stock * $SUM_STOCK_RATE_PLANE)/100);
    
    printdebug ("calc_sum_plane_supply(): Suministro avión rojo $red_supply");
    printdebug ("calc_sum_plane_supply(): Suministro avión azul $blue_supply");    
    return ($red_supply, $blue_supply);
}

# @Heracles@20110730
# Calcula el suministro diario a bases del CG
# Parámetros: stock rojo, stock azul
sub calc_daily_cg_bases_supply($$) {
    my $red_stock = shift @_;
    my $blue_stock = shift @_;

    my $CG_red_base_supply = 0;
    my $CG_blue_base_supply = 0;
    
    my $cg_blue_cx = 0;
    my $cg_blue_cy = 0;
    my $cg_blue_sum_radius = 0;
    my $cg_red_cx = 0;
    my $cg_red_cy = 0;
    my $cg_red_sum_radius = 0;
    my $cg_blue_bases = 0;
    my $cg_red_bases = 0;
    my @blue_bases = ();
    my @red_bases = ();
	    
    $CG_red_base_supply = get_sua_capacity(1);
    $CG_blue_base_supply = get_sua_capacity(2);
    printdebug ("calc_daily_cg_bases_supply(): Suministro disponible para bases rojas $CG_red_base_supply");
    printdebug ("calc_daily_cg_bases_supply(): Suministro disponible para bases azules $CG_blue_base_supply");    
	    
    ($cg_blue_cx, $cg_blue_cy) = get_coord_city($BLUE_HQ);
    $cg_blue_sum_radius = get_sum_radius($BLUE_HQ);
    ($cg_red_cx, $cg_red_cy) = get_coord_city($RED_HQ);
    $cg_red_sum_radius = get_sum_radius($RED_HQ);
	    
    ($cg_blue_bases, @blue_bases) = get_af_in_radius($cg_blue_cx, $cg_blue_cy, $cg_blue_sum_radius, 2);
    ($cg_red_bases, @red_bases) = get_af_in_radius($cg_red_cx, $cg_red_cy, $cg_red_sum_radius, 1);
    printdebug ("calc_daily_cg_bases_supply(): Bases rojas de CG $cg_red_bases");
    printdebug ("calc_daily_cg_bases_supply(): Bases azules de CG $cg_blue_bases");

    $CG_blue_base_supply = ( $cg_blue_bases == 0 ) ? 0 : floor ($CG_blue_base_supply/$cg_blue_bases);
    $CG_red_base_supply = ($cg_red_bases == 0) ? 0 :floor ($CG_red_base_supply/$cg_red_bases);
    printdebug ("calc_daily_cg_bases_supply(): Suministro por bases roja de CG $CG_red_base_supply");
    printdebug ("calc_daily_cg_bases_supply(): Suministro por bases azul de CG $CG_blue_base_supply");
    
    return ($CG_red_base_supply, $CG_blue_base_supply);
}

# @Heracles@20110730@
# Calcula los puntos de campaña
sub calc_map_points() {

    my $blue_points = 0;
    my $red_points = 0;
    
    my @row;
    my $dbh;
    my $sth;
    
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    if (! $dbh) { 
        print "Can't connect to DB\n";
        die "$0: Can't connect to DB\n";
    }    
	
    $sth = $dbh->prepare("select sum(blue_points), sum(red_points) from $mis_prog where reported=\'1\' and campanya=\"$CAMPANYA\" and mapa=\"$MAP_NAME_LONG\"");
    $sth->execute();
    @row = $sth->fetchrow_array;
    $sth->finish;
    $blue_points = $row[0];
    $red_points = $row[1];
    $dbh->disconnect();
    
    $blue_points = ($blue_points eq "") ? 0 : $blue_points;
    $red_points = ($red_points eq "") ? 0 : $red_points;    
    
    return ($red_points, $blue_points);
}

# @Heracles@20110731
# Calcula cuantos sectores pertenece a cada bando 
sub calc_sectors_owned() {
    my $red_sectors = 0.0;
    my $blue_sectors = 0.0;
    my $total_sectors = 0.0;
    
    my $line_back=tell GEO_OBJ;                 ##lemos la posicion en el archivo
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/SEC[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^:]+:([12])/){
	    if ($1 == 1) { $red_sectors++; $total_sectors++;}
	    if ($1 == 2) { $blue_sectors++; $total_sectors++;}
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos
    
    printdebug ("calc_sectors_owned(): sectores rojos $red_sectors sectores azules $blue_sectors totales $total_sectors");
    
    $red_sectors = ($red_sectors/$total_sectors);
    $blue_sectors = ($blue_sectors/$total_sectors);
    
    printdebug ("calc_sectors_owned(): sectores rojos $red_sectors sectores azules $blue_sectors totales $total_sectors");
    
    my $red_supply_city = int (($red_sectors * $SUM_CITY_RATE_PLANE) + 0.5 );
    my $blue_supply_city = int (($blue_sectors * $SUM_CITY_RATE_PLANE) + 0.5);
    
    $red_sectors = int (($red_sectors*100) + 0.5);
    $blue_sectors = int (($blue_sectors*100) + 0.5);    
    
    printdebug ("calc_sectors_owned(): suministro terrestre rojo $red_supply_city suministro terrestre azul $blue_supply_city ");    
    
    return ( $red_sectors, $blue_sectors, $red_supply_city, $blue_supply_city);
}

## @Heracles@20110912
## Obtiene el dia virtual del mapa accediendo al fichero dia.txt
sub get_map_vday(){

    my $dia;
    
    if (!(open (VER,"<dia.txt"))){
	print "$big_red ERROR: Can't open map vday file : $! (read)<br>\n";
	print "Please NOTIFY this error.\n";
	print &print_end_html();
	unlink $parser_lock;
	print PAR_LOG " Pid $$ : " .scalar(localtime(time)) ." ERROR: Can't open map vday file : $!\n\n";
	exit(0);
    }

    $dia=<VER>;
    close(VER);
    return($dia);
}

# @Heracles@20110912
## Suma un dia al dia virtual del mapa accediendo al fichero dia.txt
sub set_map_vday(){

    my $dia;
    
    if (!(open (VER,"<dia.txt"))){
	print "$big_red ERROR: Can't open map vday file : $! (read)<br>\n";
	print "Please NOTIFY this error.\n";
	print &print_end_html();
	unlink $parser_lock;
	print PAR_LOG " Pid $$ : " .scalar(localtime(time)) ." ERROR: Can't open map vday file : $!\n\n";
	exit(0);
    }

    $dia=<VER>;
    close(VER);
    
    if (!(open (VER,">dia.txt"))){
	print "$big_red ERROR:  Can't open map vday file : $! (update)<br>\n";
	print "Please NOTIFY this error.\n";
	print &print_end_html();
	unlink $parser_lock;
	print PAR_LOG " Pid $$ : " .scalar(localtime(time)) ." ERROR: Can't open map vday file : $!\n\n";
	exit(0);
    }
    
    print VER $dia+1;
    close(VER);
}

# @Heracles@20110920
# Retorna si un sector con centro en sx,sy es suministrado por una ciudad con centro cx,cy y radio r
# Parametros: sx,sy,cx,cy,r
sub is_in_radius($$$$$) {
    my $sx = $_[0];
    my $sy = $_[1];
    my $cx = $_[2];
    my $cy = $_[3];
    my $r = $_[4];
    
    for (my $i = $sx - 5000; $i <= $sx + 5000; $i+=5000) {
	for (my $j = $sy - 5000; $j <= $sy + 5000; $j+=5000) {
	    if (distance($i,$j,$cx,$cy) < ($r * 1000)) {
		return 1;
	    }
	}
    }
    
    return 0;  
}

## @Heracles@20170815
## Print to two files
sub print_map_and_sta($$$) {
    my $map = shift @_;
    my $sta = shift @_;
    my $text = shift @_;

    print $map $text;
    print $sta $text;
}

## @Heracles@20170816
## Get army HQ
sub get_hq($) {
    my $army = shift @_;

    return ($army == 1) ? $RED_HQ : $BLUE_HQ;
}

## @Heracles@20170816
## Print a text to a log if we are in debug mode
sub print_log($$) {
    
    if ($DZDEBUG) 
    {
        my $log = shift (@_);
        my $msg = shift (@_);
        
        print $log " Pid $$ : " .scalar(localtime(time)) . $msg . "\n";  
    }
}

## @Heracles@20170816
## Read the current mission number without locking rep_counter.data
sub get_report_nbr_for_read() {
    if (!(open (COU,"<rep_counter.data")))
    {
        die "ERROR: Can't open report counter file : $!\n";
    }
    
    $ext_rep_nbr=<COU>;
    $rep_count=$ext_rep_nbr;
    $rep_count =~ s/_//;
    close (COU);    

    return $rep_count;
}

## @Heracles@20170816
## Read and increment the current mission number locking rep_counter.data
sub get_report_nbr(){

    my $extend="_";
    my $counter;
    my $ret=0;
    
    if (!(open (COU,"<rep_counter.data")))
    {
        print "$big_red ERROR: Can't open report counter file : $! (read)<br>\n";
        print "Please NOTIFY this error.\n";
        print &print_end_html();
        unlink $parser_lock;
        print PAR_LOG " Pid $$ : " .scalar(localtime(time)) ." ERROR: Can't open report counter file : $!\n\n";
        exit(0);
    }

    $counter=<COU>;
    close(COU);
    
    if (!(open (COU,">rep_counter.data")))
    {
        print "$big_red ERROR:  Can't open report counter file : $! (update)<br>\n";
        print "Please NOTIFY this error.\n";
        print &print_end_html();
        unlink $parser_lock;
        print PAR_LOG " Pid $$ : " .scalar(localtime(time)) ." ERROR: Can't open report counter file : $!\n\n";
        exit(0);
    }

    $extend=$counter;
    $counter =~ s/_//;
    printf COU ("_%05.0f",$counter+1);
    close(COU);
    
    return($extend); ## retorna:   _%05.0f
}

1;