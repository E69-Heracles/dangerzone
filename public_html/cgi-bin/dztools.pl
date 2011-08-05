require "config.pl";

use IO::Handle;   # because autoflush
use DBI();
use POSIX;

# Heracles@20110423
# Retorn el numero de bases dentro de un radio con centro en cx, cy
# Parametros: coordenada x, coordenad y, radio
sub get_af_in_radius($$$$) {
    my $cx = shift @_;
    my $cy = shift @_;
    my $radius = shift @_;
    my $army = shift @_;
    
    my $bases = 0;
    
    my $line_back=tell GEO_OBJ; # pos del log        
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^AF[0-9]{2},[^,]+,([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,[^:]+:$army/){ 
	    if (distance($1, $2, $cx, $cy) <= $radius) {
		$bases++;
	    }
	}
    }
    seek GEO_OBJ,$line_back,0; # regresamos
    
    return $bases;        
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
    
    if (!open (FLIGHTS, "<$FLIGHTS_DEF")) {
	print "$big_red ERROR Can't open File $FLIGHTS_DEF: $! on get_flight()\n";
	print "Please NOTIFY this error.\n";
	print &print_end_html();
	printdebug (" ERROR: Can't open File $FLIGHTS_DEF: $! on get_flight()");
	exit(0);
    }    

    seek FLIGHTS,0,0;
    while (<FLIGHTS>) {
	if ($_ =~ m/^IR,([^,]+),([^,]+),([^,]+),([^,]+),/){ # $1: Modelo, $2: Stock inicial, $3:Sock actual, $4: aparacion en misiones
	    push(@redstock_matrix,[$1,$2,$3,$4]);
	}
	if ($_ =~ m/^IA,([^,]+),([^,]+),([^,]+),([^,]+),/){ # $1: Modelo, $2: Stock inicial, $3:Sock actual, $4: aparacion en misiones
	    push(@bluestock_matrix,[$1,$2,$3,$4]);
	}
    }
	
    close(FLIGHTS);

    ## Calculo de total de aviones iniciales rojos
    for ( my $i=0; $i < scalar(@redstock_matrix); $i++) {
	$planereal += $redstock_matrix[$i][2];
    }    
    
    $red_stock = $planereal;
    $planereal = 0;
    
    ## Calculo de total de aviones iniciales azules
    for ( my $i=0; $i < scalar(@bluestock_matrix); $i++) {
	$planereal += $bluestock_matrix[$i][2];
    }
    
    $blue_stock = $planereal;
    printdebug ("calc_stocks_plane(): rojos $red_stock azules $blue_stock");    
    return($red_stock, $blue_stock);
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
	    
    $CG_red_base_supply = ceil (($red_stock * $SUM_STOCK_RATE_CG_BASE)/100);
    $CG_blue_base_supply = ceil (($blue_stock * $SUM_STOCK_RATE_CG_BASE)/100);
    printdebug ("calc_daily_cg_bases_supply(): Suministro disponible para bases rojas $CG_red_base_supply");
    printdebug ("calc_daily_cg_bases_supply(): Suministro disponible para bases azules $CG_blue_base_supply");    
	    
    ($cg_blue_cx, $cg_blue_cy) = get_coord_city($BLUE_HQ);
    $cg_blue_sum_radius = get_sum_radius($BLUE_HQ);
    ($cg_red_cx, $cg_red_cy) = get_coord_city($RED_HQ);
    $cg_red_sum_radius = get_sum_radius($RED_HQ);
	    
    $cg_blue_bases = get_af_in_radius($cg_blue_cx, $cg_blue_cy, $cg_blue_sum_radius, 2);
    $cg_red_bases = get_af_in_radius($cg_red_cx, $cg_red_cy, $cg_red_sum_radius, 1);
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
	
    $sth = $dbh->prepare("select sum(blue_points), sum(red_points) from badc_mis_prog where reported=\'1\'");
    $sth->execute();
    @row = $sth->fetchrow_array;
    $sth->finish;
    $blue_points = $row[0];
    $red_points = $row[1];
    $dbh->disconnect();
    
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

1;