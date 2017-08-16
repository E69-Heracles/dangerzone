#!/usr/bin/perl 

require "config.pl";
require "ui.pl";
require "dztools.pl";
require "dzmap.pl";
require "dzoptions.pl";

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

sub get_report_nbr_for_read();
sub print_map_page($$$$);

sub tactical_targets($$$);

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

my $rep_nbr = get_report_nbr_for_read();
($red_capacity, $blue_capacity, $red_plane_supply, $blue_plane_supply, $red_task_stock, $red_stock_out, $blue_task_stock, $blue_stock_out, $cg_red_bases, $af_red_colapsed, $cg_blue_bases, $af_blue_colapsed, $red_hq_captured, $blue_hq_captured) = print_map_page(GEO_OBJ, STDOUT, 0, $rep_nbr);
my %red_task_stock = %$red_task_stock;
my %blue_task_stock = %$blue_task_stock;
my @cg_red_bases = @$cg_red_bases;
my @cg_blue_bases = @$cg_blue_bases;


my $Options_R="Options_R.txt";
my $Options_B="Options_B.txt";

open (OPR,">$Options_R")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SRO</font>";
open (OPB,">$Options_B")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SBO</font>";
 
    my @red_possible=();
    ## seleccion de objetivos al azar TACTICOS ROJOS
    $possible = tactical_targets(1, 2, GEO_OBJ);
    push(@red_possible, @$possible);

    ## seleccion de objetivos al azar ESTARTEGICOS rojos (SOLO AF)
    ## @Heracles@20110727
    ## Solo seleccionar AF para misi�n BA si quedan aviones BA
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
			printdebug ("make_attack_page(): Suministro a ciudad $tgt_name con da�o $1");
		    }
		}
		seek GEO_OBJ,$line_back,0; # regresamos a la misma sig linea	    
	    }
	}
    }

    ## seleccion de objetivos al azar ESTARTEGICOS rojos (SOLO CIUDADES)    
    ## @Heracles@20110727
    ## Solo seleccionar AF para misi�n BA si quedan aviones BA
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


    ## seleccion de objetivos al azar TACTICOS AZULES
    my @blue_possible=();
    $possible = tactical_targets(2, 1, GEO_OBJ);
    push(@blue_possible, @$possible);

    ## seleccion de objetivos al azar ESTARTEGICOS AZULES (SOLO AF)
    ## @Heracles@20110727
    ## Solo seleccionar AF para misi�n BA si quedan aviones BA
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
			printdebug ("make_attack_page(): Suministro a ciudad $tgt_name con da�o $1");
		    }
		}
		seek GEO_OBJ,$line_back,0; # regresamos a la misma sig linea	    
	    }
	}
    }

    ## seleccion de objetivos al azar ESTARTEGICOS AZULES (SOLO CIUDADES)
    ## @Heracles@20110727
    ## Solo seleccionar ciudad para misi�n BA si quedan aviones BA
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
