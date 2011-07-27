#!/usr/bin/perl 

require "config.pl";
require "ui.pl";

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

} # end unix_cgi


# MAIN START
sub distance ($$$$);
sub printdebug($);

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
my $red_stock_out=0;
my $blue_stock_out=0;
my %red_task_stock = (
	BA=>0,
	EBA=>0,
	SUM=>0,
	ESU=>0,
	BD=>0,
	EBD=>0,
	ET=>0,
	AT=>0,
	I=>0
    );
my %blue_task_stock = (
	BA=>0,
	EBA=>0,
	SUM=>0,
	ESU=>0,
	BD=>0,
	EBD=>0,
	ET=>0,
	AT=>0,
	I=>0
    );


#CLIMA para la proxima mision

my $hora;
my $minutos;
my $clima;
my $nubes;
srand;
$mission_of_day=(($rep_count+1) % $MIS_PER_VDAY); # MoD for NEXT mission
if ($mission_of_day==0) {$mission_of_day=$MIS_PER_VDAY;}

my $time_increase= int(720 / $MIS_PER_VDAY); # (12 hours * 60 minutes/hour) / $MIS_PER_VDAY
$hora=6;
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
    my $localt=`date`;
    open (CLIMACTL,">>clima_control.txt");
    print CLIMACTL "Manual change -  hora: $hora min: $minutos nubes: $nubes clima: $clima = ";    
    print CLIMACTL "$tipo_clima : $localt";
    close(CLIMACTL);
}


$MAP_FILE="$PATH_TO_WEBROOT/mapa.html";
my $Options_R="Options_R.txt";
my $Options_B="Options_B.txt";
my $Status="Status.txt";
my $Albaran="Albaran.txt";

#    no bakups
#    eval `cp $PATH_TO_WEBROOT/$Options_R $DATA_BKUP/$Options_R$ext_rep_nbr`; # windows cmd?
#    eval `cp $PATH_TO_WEBROOT/$Options_B $DATA_BKUP/$Options_B$ext_rep_nbr`; # windows cmd?

open (MAPA,">$MAP_FILE")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA MAPA</font>";
open (OPR,">$Options_R")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SRO</font>";
open (OPB,">$Options_B")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SBO</font>";
open (STA,">$Status")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SRS</font>";

print MAPA  &print_start_html;
print MAPA  "<font size=\"+1\">Siguiente misión del día:<b> $mission_of_day / $MIS_PER_VDAY</b><br>\n";
print STA   "<b>Siguiente misión del día:</b> $mission_of_day / $MIS_PER_VDAY - $hora h $minutos m.<br>\n";

print MAPA  "$hora h $minutos m - Clima: $tipo_clima_spa  - Nubes a $nubes metros. </font><br><br>\n\n";
print STA   "<b>Previsión:</b> $tipo_clima_spa  - Nubes a $nubes metros. <br><br>\n\n";

print MAPA  "<table border=1 ><tr><td valign=\"top\">\n";
print STA   "<table border=1 ><tr><td valign=\"top\">\n";

    ## informe de daños aerodormos
    print MAPA  "<b>Aeródromos rojos: </b><br>\n";
    print STA   "<b>Aeródromos rojos: </b><br>\n";
    print MAPA  "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Aeródromo</td><td>Daño</td></tr>\n";
    print STA   "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Aeródromo</td><td>Daño</td></tr>\n";

    ## variables para control de colapso de AF
    my $af_num=0;
    my $af_colapsed=0;
    
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) { 
	if ($_ =~ m/^AF[0-9]+,([^,]+),.*,([^,]+):1/){
	    $af_num++;
	    my $afname=$1;
	    my $afdam=$2;
	    if ($afdam !~ m/\./) {$afdam.=".00";}
	    if ($afdam !~ m/\.[0-9][0-9]/) {$afdam.="0";}
	    if ($afdam > 20) {
		if ($afdam>=80) {
		    $af_colapsed++;
		    if ($afdam<100) {$afdam="&nbsp;".$afdam;}
		    print MAPA "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"red\"><b>$afdam%</b></font></td></tr>\n";
		    print STA  "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"red\"><b>$afdam%</b></font></td></tr>\n";
		}
		else {
		    $afdam="&nbsp;".$afdam;
		    print MAPA "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"blue\"><b>$afdam%</b></font></td></tr>\n";
		    print STA  "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"blue\"><b>$afdam%</b></font></td></tr>\n";
		}
	    }
	    else {
		$afdam="&nbsp;".$afdam;
		print MAPA "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"green\"><b>$afdam%</b></font></td></tr>\n";
		print STA  "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"green\"><b>$afdam%</b></font></td></tr>\n";
	    }
	}
    }
    
    if ($af_num == $af_colapsed) {$af_red_colapsed = 1;}
    
    print MAPA  "</table><br><br>\n";
    print STA   "</table><br><br>\n";
    print MAPA  "</td><td valign=\"top\">\n";
    print STA   "</td><td valign=\"top\">\n";
    print MAPA  "<b>Aeródromos azules: </b><br>\n";
    print STA   "<b>Aeródromos azules: </b><br>\n";
    print MAPA  "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Aeródromo</td><td>Daño</td></tr>\n";
    print STA   "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Aeródromo</td><td>Daño</td></tr>\n";
    
    $af_num = 0;
    $af_colapsed=0;
    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^AF[0-9]+,([^,]+),.*,([^,]+):2/){
	    $af_num++;
	    my $afname=$1;
	    my $afdam=$2;
	    if ($afdam !~ m/\./) {$afdam.=".00";}
	    if ($afdam !~ m/\.[0-9][0-9]/) {$afdam.="0";}
	    if ($afdam > 20) {
		if ($afdam>=80) {
		    $af_colapsed++;
		    if ($afdam<100) {$afdam="&nbsp;".$afdam;}
		    print MAPA "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"red\"><b>$afdam%</b></font></td></tr>\n";
		    print STA  "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"red\"><b>$afdam%</b></font></td></tr>\n";
		}
		else {
		    $afdam="&nbsp;".$afdam;
		    print MAPA "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"blue\"><b>$afdam%</b></font></td></tr>\n";
		    print STA  "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"blue\"><b>$afdam%</b></font></td></tr>\n";
		}
	    }
	    else {
		$afdam="&nbsp;".$afdam;
		print MAPA "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"green\"><b>$afdam%</b></font></td></tr>\n";
		print STA  "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"green\"><b>$afdam%</b></font></td></tr>\n";
	    }
	}
    }
    
    if ($af_num == $af_colapsed) {$af_blue_colapsed = 1;}
    
    print MAPA  "</table><br><br></td></tr></table><br><br>\n";
    print STA   "</table><br><br></td></tr></table><br><br>\n";

    if ($INVENTARIO) {
	
	if (!open (FLIGHTS, "<$FLIGHTS_DEF")) {
	    print "$big_red ERROR Can't open File $FLIGHTS_DEF: $! on get_flight()\n";
	    print "Please NOTIFY this error.\n";
	    print &print_end_html();
	    print PAR_LOG " Pid $$ : " .scalar(localtime(time)) ." ERROR: Can't open File $FLIGHTS_DEF: $! on get_flight()\n\n";
	    exit(0);
	}    	
	
        ## informe de inventario de aviones rojos
        print MAPA  "<table border=1 ><tr><td valign=\"top\">\n";
        print STA   "<table border=1 ><tr><td valign=\"top\">\n";

        print MAPA  "<b>Inventario de aviones rojos:</b><br>\n";
        print STA   "<b>Inventario de aviones rojos:</b><br>\n";

        print MAPA  "<table><tr><td>Modelo</td><td>Tipo</td><td>Existencias</td></tr>";
        print STA   "<table><tr><td>Modelo</td><td>Tipo</td><td>Existencias</td></tr>";
	
	seek FLIGHTS, 0, 0;
	while (<FLIGHTS>) {
	    if ($_ =~ m/^IR,([^,]+),([^,]+),([^,]+),([^,]+),/){
		my $plane_model = $1;
		my $plane_number = $3;
		
		print MAPA "<tr><td> $plane_model </td><td>"; 
		print STA "<tr><td> $plane_model </td><td>"; 
		
		my $line_back = tell FLIGHTS;
		seek FLIGHTS,0,0;
	        while (<FLIGHTS>){
		    if ($_ =~ m/^1,[^,]+,$plane_model,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+:([^,]+),/){
			print MAPA "$1,";
			print STA "$1,";
			$red_task_stock{$1} += $plane_number;
		    }
		}
		
		if ($plane_number <= 10) { 
		    print MAPA "</td><td align=\"right\"><font color=\"red\"><b>$plane_number</b></font></td></tr>\n";
		    print STA "</td><td align=\"right\"><font color=\"red\"><b>$plane_number</b></font></td></tr>\n";
		}
		else {
		    if ( $plane_number <= 50 ) {
			print MAPA "</td><td align=\"right\"><font color=\"blue\"><b>$plane_number</b></font></td></tr>\n";
			print STA "</td><td align=\"right\"><font color=\"blue\"><b>$plane_number</b></font></td></tr>\n";			
		    }
		    else {
			print MAPA "</td><td align=\"right\"><font color=\"green\"><b>$plane_number</b></font></td></tr>\n";
			print STA "</td><td align=\"right\"><font color=\"green\"><b>$plane_number</b></font></td></tr>\n";			
		    }
		}
		seek FLIGHTS, $line_back, 0;
	    }
	}
	
	if ($red_task_stock{BD} == 0 || $red_task_stock{EBD} == 0 || $red_task_stock{ET} == 0 || $red_task_stock{AT} == 0 || $red_task_stock{I} == 0) {$red_stock_out = 1;}
	
	print MAPA  "</table><br><br>\n";
	print STA   "</table><br><br>\n";

	print MAPA "<br><br>\n";
	print STA   "<br><br>\n";

	print MAPA  "</td><td valign=\"top\">\n";
	print STA   "</td><td valign=\"top\">\n";
        
	## informe de inventario de aviones azules
        print MAPA  "<b>Inventario de aviones azules:</b><br>\n";
        print STA   "<b>Inventario de aviones azules:</b><br>\n";

        print MAPA  "<table><tr><td>Modelo</td><td>Tipo</td><td>Existencias</td></tr>";
        print STA   "<table><tr><td>Modelo</td><td>Tipo</td><td>Existencias</td></tr>";
	
	seek FLIGHTS, 0, 0;
	while (<FLIGHTS>) {
	    if ($_ =~ m/^IA,([^,]+),([^,]+),([^,]+),([^,]+),/){
		my $plane_model = $1;
		my $plane_number = $3;
		
		print MAPA "<tr><td> $plane_model </td><td>"; 
		print STA "<tr><td> $plane_model </td><td>"; 
		
		my $line_back = tell FLIGHTS;
		seek FLIGHTS,0,0;
	        while (<FLIGHTS>){
		    if ($_ =~ m/^2,[^,]+,$plane_model,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+:([^,]+),/){
			print MAPA "$1,";
			print STA "$1,";
			$blue_task_stock{$1} += $plane_number;			
		    }
		}
		
		if ($plane_number <= 10) { 
		    print MAPA "</td><td align=\"right\"><font color=\"red\"><b>$plane_number</b></font></td></tr>\n";
		    print STA "</td><td align=\"right\"><font color=\"red\"><b>$plane_number</b></font></td></tr>\n";
		}
		else {
		    if ( $plane_number <= 50 ) {
			print MAPA "</td><td align=\"right\"><font color=\"blue\"><b>$plane_number</b></font></td></tr>\n";
			print STA "</td><td align=\"right\"><font color=\"blue\"><b>$plane_number</b></font></td></tr>\n";			
		    }
		    else {
			print MAPA "</td><td align=\"right\"><font color=\"green\"><b>$plane_number</b></font></td></tr>\n";
			print STA "</td><td align=\"right\"><font color=\"green\"><b>$plane_number</b></font></td></tr>\n";			
		    }
		}
		seek FLIGHTS, $line_back, 0;
	    }
	}
	
	if ($blue_task_stock{BD} == 0 || $blue_task_stock{EBD} == 0 || $blue_task_stock{ET} == 0 || $blue_task_stock{AT} == 0 || $blue_task_stock{I} == 0) {$blue_stock_out = 1;}	

	print MAPA  "</table><br><br></td></tr></table><br><br>\n";
	print STA   "</table><br><br></td></tr></table><br><br>\n";
	
	close (FLIGHTS);
	
	if ($PRODUCCION) {
	    if (open (ALB, "<$Albaran")) {
		seek ALB, 0, 0;
		while (<ALB>) {
		    print MAPA;
		    print STA;
		}
		close (ALB);
	    }    		    
	}
	
    }
    
    ## informe de daños Ciudades
    print MAPA  "<br><br><table border=1 ><tr><td valign=\"top\">\n";
    print STA   "<br><br><table border=1 ><tr><td valign=\"top\">\n";

    print MAPA  "<b>Estado de las ciudades rojas:</b><br>\n";
    print STA   "<b>Estado de las ciudades rojas:</b><br>\n";

    print MAPA  "<table><tr><td>Ciudad</td><td>Daño</td><td>Suministros</td></tr>";
    print STA   "<table><tr><td>Ciudad</td><td>Daño</td><td>Suministros</td></tr>";

    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^(CT[0-9]+),([^,]+),.*,([^,]+),([^,]+):1/){
	    if ($3 > $CITY_DAM) {
		print MAPA "<tr><td> $2 </td><td><font color=\"red\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";
		print STA "<tr><td> $2 </td><td><font color=\"red\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";
	    }
	    else {
		if ( $3 > 25) {
		    print MAPA "<tr><td> $2 </td><td><font color=\"blue\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";
		    print STA "<tr><td> $2 </td><td><font color=\"blue\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";		    
		}
		else {
		    print MAPA "<tr><td> $2 </td><td><font color=\"green\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";
		    print STA "<tr><td> $2 </td><td><font color=\"green\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";		    
		}
	    }
	    if ( $2 eq $BLUE_HQ ) { $blue_hq_captured = 1;}
	}
    }
    print MAPA  "</table><br><br>\n";
    print STA   "</table><br><br>\n";

    print MAPA "<br><br>\n";
    print STA   "<br><br>\n";

    print MAPA  "</td><td valign=\"top\">\n";
    print STA   "</td><td valign=\"top\">\n";

    print MAPA  "<b>Estado de las ciudades azules:</b><br>\n";
    print STA   "<b>Estado de las ciudades azules:</b><br>\n";

    print MAPA  "<table><tr><td>Ciudad</td><td>Daño</td><td>Suministro</td></tr>";
    print STA   "<table><tr><td>Ciudad</td><td>Daño</td><td>Suministro</td></tr>";

    seek GEO_OBJ, 0, 0;
    while(<GEO_OBJ>) {
	if ($_ =~ m/^(CT[0-9]+),([^,]+),.*,([^,]+),([^,]+):2/){
	    if ($3 > $CITY_DAM) {
		print MAPA "<tr><td> $2 </td><td><font color=\"red\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";
		print STA "<tr><td> $2 </td><td><font color=\"red\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";
	    }
	    else {
		if ( $3 > 25) {
		    print MAPA "<tr><td> $2 </td><td><font color=\"blue\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";
		    print STA "<tr><td> $2 </td><td><font color=\"blue\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";		    
		}
		else {
		    print MAPA "<tr><td> $2 </td><td><font color=\"green\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";
		    print STA "<tr><td> $2 </td><td><font color=\"green\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n";		    
		}
	    }
	    if ( $2 eq $RED_HQ ) { $red_hq_captured = 1;}
	}
    }
    print MAPA  "</table><br><br></td></tr></table>\n";
    print STA   "</table><br><br></td></tr></table>\n";

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
