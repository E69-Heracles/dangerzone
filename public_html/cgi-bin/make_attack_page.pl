#!/usr/bin/perl 

require "config.pl";
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

sub distance ($$$$) {
    my ($x1,$y1,$x2,$y2)=@_;
    return (sqrt(($x1-$x2)**2+($y1-$y2)**2));
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
			if ($dist<40000) {last;}  #version 24 optim change
		    }
		}
	    }
	    if ($near <40000) {
		push (@red_possible,$tgt_name); # los ponemos al final
	    }
	}
    }


    ## seleccion de SUMINISTROS A CIUDADES ROJAS
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/^(SUC[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^:]+):1.*$/) {
	    $tgt_name=$2;
	    $cxo=$3;
	    $cyo=$4;
	    unshift (@red_possible,$tgt_name);
	}
    }


    ## seleccion de objetivos al azar ESTARTEGICOS rojos (SOLO CIUDADES)
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
			if ($dist<80000) {last;}  #version 24 optim change
		    }
		}
	    }
	    if ($near <80000) {
		unshift (@red_possible,$tgt_name);
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
			if ($dist<40000) {last;}  #version 24 optim change
		    }
		}
	    }
	    if ($near <40000) {
		push (@blue_possible,$tgt_name); 
	    }
	}
    }

    ## seleccion de SUMINISTROS a CIUDADES Azules
    seek GEO_OBJ,0,0;
    while(<GEO_OBJ>) {
	if ($_ =~  m/^(SUC[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^:]+):2.*$/) {
	    $tgt_name=$2;
	    $cxo=$3;
	    $cyo=$4;
	    unshift (@blue_possible,$tgt_name);
	}
    }


    ## seleccion de objetivos al azar ESTARTEGICOS AZULES (SOLO CIUDADES)
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
			if ($dist<80000) {last;}  #version 24 optim change
		    }
		}
	    }
	    if ($near <80000) {
		unshift (@blue_possible,$tgt_name);
	    }
	}
    }


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
if ($clima<=15){ # clima 1..15 -> 15% Clear
    $tipo_clima="Clear";
    $nubes=" -- "; # para  la pagina del generador. (ya esta guardado en disco).
}
if ($clima>15 && $clima<=85){ # clima 16..85 -> 70% Good
    $tipo_clima="Good";
}
if ($clima>85 && $clima<=93){ # clima 86..93 -> 8% Blind
    $tipo_clima="Low Visibility";
}
if ($clima>93 && $clima<=98){ # clima 94..98 -> 5% Rain/Snow
    $tipo_clima="Precipitations";
}
if ($clima>98 && $clima<=100){ # clima 99..100 -> 2% Thunder
    $tipo_clima="Storm";
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

#    no bakups
#    eval `cp $PATH_TO_WEBROOT/$Options_R $DATA_BKUP/$Options_R$ext_rep_nbr`; # windows cmd?
#    eval `cp $PATH_TO_WEBROOT/$Options_B $DATA_BKUP/$Options_B$ext_rep_nbr`; # windows cmd?

open (MAPA,">$MAP_FILE")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA MAPA</font>";
open (OPR,">$Options_R")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SRO</font>";
open (OPB,">$Options_B")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SBO</font>";
open (STA,">$Status")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SRS</font>";

print MAPA  "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">";
print MAPA  "<html>\n<head>\n    <META HTTP-EQUIV=\"PRAGMA\" CONTENT=\"no-cache\">\n";
print MAPA  "    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n";
print MAPA  "    <title>Front Map</title>\n";
print MAPA "  </head>\n<body background=\"/images/fondo_mapa.jpg\" bgcolor=\"#ccffff\">\n<center>\n";
print MAPA  "<a href=\"/\"><img alt=\"Return\" border=0 src=\"/images/tanks.gif\"></a><br><br>\n\n";

print MAPA  "<font size=\"+1\">Next Mission of Day (MoD): <b> $mission_of_day / $MIS_PER_VDAY</b><br>\n";
print STA   "<font size=\"+1\">Next Mission of Day (MoD): <b> $mission_of_day / $MIS_PER_VDAY</b><br>\n";

print MAPA  "$hora h $minutos m - Weather: $tipo_clima  - Clouds at $nubes meters. </font><br><br>\n\n";
print STA   "$hora h $minutos m - Weather: $tipo_clima  - Clouds at $nubes meters. </font><br><br>\n\n";

my $k;
for ($k=0; $k<scalar(@red_possible); $k++){
    print OPR "<option value=\"$red_possible[$k]\">$red_possible[$k]</option>\n";
}
for ($k=0; $k<scalar(@blue_possible); $k++){
    print OPB "<option value=\"$blue_possible[$k]\">$blue_possible[$k]</option>\n";
}

print MAPA  "<table border=1 ><tr><td valign=\"top\">\n";
print STA   "<table border=1 ><tr><td valign=\"top\">\n";

## informe de daños aerodormos
print MAPA  "<b>Damaged  VVS Airfields: </b><br>\n";
print STA   "<b>Damaged  VVS Airfields: </b><br>\n";
print MAPA  "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Airfield</td><td>Damage</td></tr>\n";
print STA   "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Airfield</td><td>Damage</td></tr>\n";

seek GEO_OBJ, 0, 0;
while(<GEO_OBJ>) { 
    if ($_ =~ m/^AF[0-9]+,([^,]+),.*,([^,]+):1/){
	my $afname=$1;
	my $afdam=$2;
	if ($afdam !~ m/\./) {$afdam.=".00";}
	if ($afdam !~ m/\.[0-9][0-9]/) {$afdam.="0";}
	if ($afdam > 20) {
	    if ($afdam>=80) {
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
print MAPA  "</table><br><br>\n";
print STA   "</table><br><br>\n";
print MAPA  "</td><td valign=\"top\">\n";
print STA   "</td><td valign=\"top\">\n";
print MAPA  "<b>Damaged LW Airfields: </b><br>\n";
print STA   "<b>Damaged LW Airfields: </b><br>\n";
print MAPA  "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Airfield</td><td>Damage</td></tr>\n";
print STA   "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Airfield</td><td>Damage</td></tr>\n";

seek GEO_OBJ, 0, 0;
while(<GEO_OBJ>) {
    if ($_ =~ m/^AF[0-9]+,([^,]+),.*,([^,]+):2/){
	my $afname=$1;
	my $afdam=$2;
	if ($afdam !~ m/\./) {$afdam.=".00";}
	if ($afdam !~ m/\.[0-9][0-9]/) {$afdam.="0";}
	if ($afdam > 20) {
	    if ($afdam>=80) {
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
print MAPA  "</table><br><br></td></tr></table>\n";
print STA   "</table><br><br></td></tr></table>\n";

## informe de daños Ciudades
print MAPA  "<table border=1 ><tr><td valign=\"top\">\n";
print STA   "<table border=1 ><tr><td valign=\"top\">\n";

print MAPA  "<b>State of cities under Soviet control:</b><br>\n";
print STA   "<b>State of cities under Soviet control:</b><br>\n";

print MAPA  "<table><tr><td>City</td><td>Damage</td><td>Suply radius</td></tr>";
print STA   "<table><tr><td>City</td><td>Damage</td><td>Suply radius</td></tr>";

seek GEO_OBJ, 0, 0;
while(<GEO_OBJ>) {
    if ($_ =~ m/^CT[0-9]+,([^,]+),.*,([^,]+),([^,]+):1/){
	print MAPA "<tr><td> $1 </td><td> $2% </td><td> $3 Km.</td></tr>\n";
	print STA "<tr><td> $1 </td><td> $2% </td><td> $3 Km.</td></tr>\n";
    }
}
print MAPA  "</table><br><br>\n";
print STA   "</table><br><br>\n";
print MAPA "<br><br>\n";
print STA   "<br><br>\n";
print MAPA  "</td><td valign=\"top\">\n";
print STA   "</td><td valign=\"top\">\n";
print MAPA  "<b>State of cities under German control:</b><br>\n";
print STA   "<b>State of cities under German control:</b><br>\n";
print MAPA  "<table><tr><td>City</td><td>Damage</td><td>Suply radius</td></tr>";
print STA   "<table><tr><td>City</td><td>Damage</td><td>Suply radius</td></tr>";

seek GEO_OBJ, 0, 0;
while(<GEO_OBJ>) {
    if ($_ =~ m/^CT[0-9]+,([^,]+),.*,([^,]+),([^,]+):2/){
	print  MAPA  "<tr><td> $1 </td><td> $2% </td><td> $3 Km.</td></tr>\n";
	print  STA   "<tr><td> $1 </td><td> $2% </td><td> $3 Km.</td></tr>\n";
    }
}
print MAPA  "</table><br><br></td></tr></table>\n";
print STA   "</table><br><br></td></tr></table>\n";
print MAPA  "<p><strong>Front Map:</strong><br>";
print STA   "<p><strong>Front Map:</strong><br>";

open (IMAP,"<$IMAP_DATA");
while(<IMAP>){
    print MAPA;
}
close(IMAP);

print MAPA "</center>\n</body>\n</html>\n";

close (MAPA);
close (STA);
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
