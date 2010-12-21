#!/usr/bin/perl 

#chdir "SET_YOUR_HOME_DIR_HERE"; # this is a chdir when run by cron

require "config.pl";
$|=1; #STDOUT HOT

if (! defined $ENV{'HTTP_USER_AGENT'}) { 
    $unix_cgi=0;
}  

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

  <a href="/index.html"><img border="0" src="/images/logo.gif"  alt="regresar" style="margin-left: 40px; margin-top: 0px" ></a>
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


$HEAD=54;  #BMP header  size
$METERS_PER_PIX=int(10000/$H_BLOCK_PIX); # using Horzintal scale. shuld be very simmilar to Vertical scale

$prn_blue=0;
$alt=0;

chdir $CGI_BIN_PATH; 

if (! $unix_cgi) {
    if (! open (DOI,"<doimage")){
	exit(0);
    }
    else {
	close (DOI);
	unlink "doimage";
    }
}

if (! open (GEO_OBJ, "<$GEOGRAFIC_COORDINATES")) { print "Can't open File GEOGRAFIC_COORDINATES: $!\n"; exit(0)}
if (! open (FRONT, "<$FRONT_LINE")){ print "Can't open File FRONT LINE FILE: $!\n"; exit(0)}
if (! open (IMG_IN,"<$FRONT_IMAGE")){ print "Can't open File FRONT BASE IMAGE : $!\n"; exit(0)}
if (! open (IMG_OUT,">suply.bmp")){ print "Can't open File SUPLY OUTPUT IMAGE: $!\n"; exit(0)}

binmode IMG_IN;
binmode IMG_OUT;

sub distance ($$$$);
sub pix_dist ($$$$);

					  
sub distance ($$$$) {
    my ($x1,$y1,$x2,$y2)=@_;
    return (sqrt(($x1-$x2)**2+($y1-$y2)**2));
}


sub pix_dist ($$$$) {
    my ($px,$xc,$yc,$r)=@_;
    my $pcx= ($px % $ANCHO);
    my $pcy= abs($px/$ANCHO);
    my $dpx = sqrt(($pcx-$xc)**2+($pcy-$yc)**2);  

    if ($dpx <5){
	return (1);
    }
    if (abs(($dpx) - ($r/$METERS_PER_PIX))<=1 ){
	return (1);
    } 

    return (0);
}

### MAIN

## 54 bytes de header.
##-----
for ($h=1; $h<=$HEAD; $h++) {
    $char=getc IMG_IN;
    print IMG_OUT $char;
}

$cx_blo=0;
$cy_blo=0;
$dist=0;
$near=0;

@line_sectors=();
@suply_sectors=();

$pixel=0;

seek GEO_OBJ,0,0;
while(<GEO_OBJ>) {
                #CT02      ,Kalac, 34789 , 89027 , 50  ,  3  , 3   , 43.2,  28   : 2
    if ($_ =~  m/CT[0-9]{2},[^,]+,([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^,]+):([12]).*$/) { 
	#print "$1 $2 $3 $4 \n";
	push (@city,int($1/$METERS_PER_PIX),int($2/$METERS_PER_PIX),int(1000*$3),$4);
    }
}


if ($unix_cgi){
    print "<p> Actualizando, esperar hasta un mensage de terminado o error.<br><br>\n";
}

$ciudades=int(scalar(@city)/4);

for ($k=0; $k<$NUMEROS; $k++) { ## para cada coordenada NUMERO
    if ($unix_cgi) {print "<br>";}
    print "\n";

    $cy_blo=10000 * $k+5000;
    for ($cl=0; $cl<$LETRAS; $cl++ ) { ## para cada letra 
	$cx_blo=10000*$cl+5000;
	$near=500000;
	seek FRONT,0,0;
	while(<FRONT>) {
	    if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) ([0-3])/){
		$dist= distance($cx_blo,$cy_blo,$1,$2);
		if ($dist < $near) {
		    $near=$dist;
		    $army=$3;
		}
	    }
	}
	$line_sectors[$cl]=$army;
	my $ttl=0;
	seek GEO_OBJ,0,0;
	while(<GEO_OBJ>) {
	    if ($_ =~  m/SEC.{4},[^,]+,([^,]+),([^,]+),([^,]+),[^:]+:[12]/){
		$dist= distance($cx_blo,$cy_blo,$1,$2);
		if ($dist < 2000) {
		    $ttl=$3;
		}
	    }
	}
	if ($ttl==1) { $ttl=2;} # para que se imprima por lo menos un pixel
	$suply_sectors[$cl]=int($ttl/2);
    }
    
    for ($j=0; $j<$V_BLOCK_PIX; $j++) { ## altura de bloque
	print "+";
	$i=0; $alt++;
	for ($cl=0; $cl<$LETRAS; $cl++ ) { 
	    $prn_blue=3; # neutral
	    if (($line_sectors[$cl]) eq "2") {$prn_blue=1;}
	    else {
		if (($line_sectors[$cl]) eq "1") {$prn_blue=2;}
	    }
	    my $pix_out;
	    for ($l=0; $l<$H_BLOCK_PIX && $i<$ANCHO &&$alt<=$ALTO; $l++){ ## ancho de bloque
		###--------------------------------------------
		$b=ord(getc IMG_IN);
		$g=ord(getc IMG_IN);
		$r=ord(getc IMG_IN);

		$pix_out=0;

		for (my $pl=0; $pl<$ciudades; $pl++){
		    if ( pix_dist($pixel,$city[4*$pl+0],$city[4*$pl+1],$city[4*$pl+2])){
			my $tono=int(255-(4*$pl));
			if ($city[4*$pl+3]==1) {
			    print IMG_OUT  chr 0;
			    print IMG_OUT  chr int(255-$tono);
			    print IMG_OUT  chr $tono;
			}
			else {
			    print IMG_OUT  chr $tono;
			    print IMG_OUT  chr int(255-$tono);
			    print IMG_OUT  chr 0;
			}
			$pix_out=1;
			last;
		    }
		}
		if (!$pix_out && ($j==3 || $j==4) && $l>=5 && $k<($NUMEROS-1)) {
#		if (!$pix_out && $j==3 && $l>=5 && $k<($NUMEROS-1)) {
		    if ($suply_sectors[$cl]> ($l-5)){
			print IMG_OUT  chr 0;
			print IMG_OUT  chr int((16*($l-5))% 255);
			print IMG_OUT  chr int(200-(($l-5)*10));
#			$suply_sectors[$cl]--;
			$pix_out=1;
		    }
		}
		if (!$pix_out) {
		    if (($g+$r)>450 && $b>100) {
			if ($prn_blue==1) {
			    print IMG_OUT  chr 255;
			    print IMG_OUT  chr int($g * 0.85);
			    print IMG_OUT  chr int($r * 0.85);
			}
			if ($prn_blue==2) {
			    print IMG_OUT  chr int($b * 0.9);
			    print IMG_OUT  chr int($g * 0.9);
			    print IMG_OUT  chr 255;
			}
			if ($prn_blue==3) {
			    print IMG_OUT  chr int($b/2);
			    print IMG_OUT  chr int($g/2);
			    print IMG_OUT  chr int($r/2);
			    
			}
		    }
		    else {
			print IMG_OUT  chr $b;
			print IMG_OUT  chr $g;
			print IMG_OUT  chr $r;
		    }
		}
		$i++;
		$pixel++;
		###--------------------------------------------
	    }
	}
    }
}


#llenar hasta comp 702.000

close (IMG_IN);
close(IMG_OUT);
close(GEO_OBJ);


if ($WINDOWS) {
    eval `$CJPEG_PROG $CJPEG_FLAGS suply.bmp > $PATH_TO_WEBROOT\\images\\suply.jpg`; # win
}
else {
    eval `$CJPEG_PROG $CJPEG_FLAGS suply.bmp > $PATH_TO_WEBROOT/images/suply.jpg`;
}


if ($unix_cgi) {
    print "<p>Terminado, recargando pagina front map, aguarde....<br>\n";
    print <<HDPR;
    <head>
      <META HTTP-EQUIV='refresh' CONTENT='3; URL=/mapa.html'>
    </head>
HDPR
    ;
    print &HtmlBot;
}
unlink "suply.bmp";
exit(0);



# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
$pilot_file_tbl=$pilot_file_tbl;
$super_user=$super_user;
$CGI_BIN_PATH=$CGI_BIN_PATH;
$CJPEG_PROG=$CJPEG_PROG;
$CJPEG_FLAGS=$CJPEG_FLAGS;
$FRONT_LINE=$FRONT_LINE;
$FRONT_IMAGE=$FRONT_IMAGE;
$GEOGRAFIC_COORDINATES=$GEOGRAFIC_COORDINATES;
$PATH_TO_WEBROOT=$PATH_TO_WEBROOT;
$WINDOWS=$WINDOWS;
$V_BLOCK_PIX=$V_BLOCK_PIX;
$ALTO=$ALTO;
