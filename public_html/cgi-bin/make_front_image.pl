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
      <title>Front image update output</title> 
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
    
    
    $hlname=$in{'hlnameF'};
    $pwd=$in{'pwdF'};
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

my @front_img=();

sub distance ($$$$) {
    my ($x1,$y1,$x2,$y2)=@_;
    return (sqrt(($x1-$x2)**2+($y1-$y2)**2));
}


sub draw_1pix ($$$$$) {
    my ($cx,$cy,$r,$g,$b)=@_;
    if ($cy<$ALTO && $cy>=0 && $cx<$ANCHO && $cx>=0){
	$cx*=3;
	$front_img[$cy][$cx]=$b;
	$front_img[$cy][$cx+1]=$g;
	$front_img[$cy][$cx+2]=$r;
    }
}

sub draw_octants ($$$$$$$) {
    my ($Xcenter,$Ycenter,$x,$y,$r,$g,$b)=@_;
    draw_1pix(($Xcenter+$x),($Ycenter+$y),$r,$g,$b);
    draw_1pix(($Xcenter-$x),($Ycenter+$y),$r,$g,$b);
    draw_1pix(($Xcenter+$x),($Ycenter-$y),$r,$g,$b);
    draw_1pix(($Xcenter-$x),($Ycenter-$y),$r,$g,$b);
    draw_1pix(($Xcenter+$y),($Ycenter+$x),$r,$g,$b);
    draw_1pix(($Xcenter-$y),($Ycenter+$x),$r,$g,$b);
    draw_1pix(($Xcenter+$y),($Ycenter-$x),$r,$g,$b);
    draw_1pix(($Xcenter-$y),($Ycenter-$x),$r,$g,$b);
}

sub draw_circle ($$$$) {
    my ($cx,$cy,$rad,$army)=@_;
    my $x=0;
    my $y=$rad;
    my $p=1-$rad;
    my ($b,$g,$r)= (0,0,0);
    if ($army==1) {$r=255; $g=0; $b=0;}
    if ($army==2) {$r=0; $g=0; $b=255;}
    draw_octants($cx,$cy,$x,$y,$r,$g,$b);
    while ($x<$y){
	if ($p<0){
	    $x++;
	    $p+=2*$x+1;
	}
	else {
	    $x++;
	    $y--;
	    $p+=2*($x-$y)+1;
	}
	draw_octants($cx,$cy,$x,$y,$r,$g,$b);
    }
}



my $HEAD=54;  #BMP header  size
my $METERS_PER_PIX=int(10000/$H_BLOCK_PIX); # using Horzintal scale. shuld be very simmilar to Vertical scale
my @sector_army=();
my @sector_ttl=();
my @city=();
my $ciudades;

chdir $CGI_BIN_PATH; 

if (! open (GEO_OBJ, "<$GEOGRAFIC_COORDINATES")) { print "Can't open File GEOGRAFIC_COORDINATES: $!\n"; exit(0)}
if (! open (FRONT, "<$FRONT_LINE")){ print "Can't open File FRONT LINE FILE: $!\n"; exit(0)}
if (! open (IMG_IN,"<$FRONT_IMAGE")){ print "Can't open File FRONT BASE IMAGE : $!\n"; exit(0)}
if (! open (IMG_OUT,">front.bmp")){ print "Can't open File FRONT OUTPUT IMAGE: $!\n"; exit(0)}
binmode IMG_IN;
binmode IMG_OUT;

if ($unix_cgi){
    print "<p> Actualizando, esperar hasta un mensage de terminado o error.<br><br>\n";
}

print "wait ";
## 54 bytes de header.
##-----
for (my $i=0; $i<$HEAD; $i++) {
    my $char=getc IMG_IN;
    print IMG_OUT $char;
}

my $B_PAD=($ANCHO*3)%4;
if ($B_PAD) {$B_PAD=4-$B_PAD;}

for (my $i=0; $i<$ALTO; $i++) {
    read(IMG_IN, my $read,($ANCHO*3+$B_PAD));
    push (@front_img,[(unpack "C*",$read)]);
}
close (IMG_IN);
print "wait ";

seek GEO_OBJ,0,0;
while(<GEO_OBJ>) {
    if ($_ =~  m/CT[0-9]{2},[^,]+,([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^,]+):([12]).*$/) { 
	push (@city,[int($1/$METERS_PER_PIX),int($2/$METERS_PER_PIX),int(1000*$3/$METERS_PER_PIX),$4]);
    }
}
$ciudades=int(scalar(@city));

for (my $i=0; $i<$ciudades; $i++){
    draw_circle($city[$i][0], $city[$i][1], $city[$i][2], $city[$i][3]);
#    draw_circle($city[$i][0], $city[$i][1], $city[$i][2]-1, $city[$i][3]);
}

for (my $n=0; $n<$NUMEROS; $n++) { ## para cada coordenada NUMERO
    for (my $l=0; $l<$LETRAS; $l++ ) { ## para cada letra 
	$sector_army[$n][$l]=3;
	$sector_ttl[$n][$l]=0;
    }
}

seek FRONT,0,0;
while(<FRONT>) {
    if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) ([0-3])/){
	my $n=int($2/10000);
	my $l=int($1/10000);
	$sector_army[$n][$l]=$3;
    }
}

seek GEO_OBJ,0,0;
while(<GEO_OBJ>) {
    if ($_ =~  m/SEC.{4},[^,]+,([^,]+),([^,]+),([^,]+),[^:]+:[12]/){
	my $n=int($2/10000);
	my $l=int($1/10000);
	my $ttl=$3;
	if ($ttl==1) { $ttl=2;} # para que se imprima por lo menos un pixel
	$sector_ttl[$n][$l]=int($ttl/2);
    }
}

for (my $n=0; $n<$NUMEROS; $n++) { ## para cada coordenada NUMERO
    my $cy_blo=10000*$n+5000;
    for (my $l=0; $l<$LETRAS; $l++ ) { ## para cada letra 
	if($sector_army[$n][$l]!=3) {next;}
	my $cx_blo=10000*$l+5000;
	my $near=100000;
	my $army=0;
	my $dist=0;
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
	$sector_army[$n][$l]=$army;
    }
}

for (my $n=($NUMEROS-1); $n>=0;  $n--) { ## para cada coordenada NUMERO
    if (! ($n%3)){print "wait ";}
    for (my $l=0; $l<$LETRAS; $l++ ) { ## para cada letra 
	
	#sector square:
	my $ttl=$sector_ttl[$n][$l];
	my $army=$sector_army[$n][$l];
	my $v_limit=$ALTO-($n*$V_BLOCK_PIX);
	my $h_limit=$ANCHO-($l*$H_BLOCK_PIX);
	
	my $pix_y=$n*$V_BLOCK_PIX;
	my $pix_x;
        my ($rb,$rg,$rr)= (0,0,0);
	
	for (my $cy=0; $cy<$V_BLOCK_PIX && $cy<$v_limit; $cy++) {
	    $pix_x=$l*$H_BLOCK_PIX*3;
	    for (my $cx=0; $cx<$H_BLOCK_PIX && $cx<$h_limit; $cx++) {
		if ( ($cy==3 || $cy==4) && $cx>5 && $ttl>($cx-5)) {
		    $front_img[$pix_y][$pix_x]=0;
		    $front_img[$pix_y][$pix_x+1]=int(($cx-5)<<4);
		    $front_img[$pix_y][$pix_x+2]=int(250-(($cx-5)<<4));
		}
		else {
		    $rg=$front_img[$pix_y][$pix_x+1];
		    if ( $rg>210) {
			$rr=$front_img[$pix_y][$pix_x+2];
			$rb=$front_img[$pix_y][$pix_x];
			if ( $rr>210 && $rb>150 ) {
			    if ($army==1){
				$front_img[$pix_y][$pix_x]-=40;
				$front_img[$pix_y][$pix_x+1]-=40;
				if ($rr <240){
				    $front_img[$pix_y][$pix_x+2]+=15;
				}
			    }
			    else {
				$front_img[$pix_y][$pix_x+1]-=40;
				$front_img[$pix_y][$pix_x+2]-=40;
				if ($rb <240){
				    $front_img[$pix_y][$pix_x]+=15;
				}
			    }
			}
		    }
		}
		$pix_x+=3;
	    }
	    $pix_y++;
	}
    }
}


for (my $i=0; $i<$ALTO; $i++) {
    print IMG_OUT pack "C*",@{$front_img[$i]};
}

print "\n";
close (IMG_OUT);


if ($WINDOWS) {
    eval `$CJPEG_PROG $CJPEG_FLAGS front.bmp > $PATH_TO_WEBROOT\\images\\front.jpg`; # win
}
else {
    eval `$CJPEG_PROG $CJPEG_FLAGS front.bmp > $PATH_TO_WEBROOT/images/front.jpg`;
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
unlink "front.bmp";
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
$H_BLOCK_PIX=$H_BLOCK_PIX;
$V_BLOCK_PIX=$V_BLOCK_PIX;
$ALTO=$ALTO;
$ANCHO=$ANCHO;
