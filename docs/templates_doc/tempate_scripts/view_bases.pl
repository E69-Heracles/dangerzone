

$DIST_VEHICULOS="$0";

$MISION="initial.mis";
$SALIDA="preview_bases.mis";

$s_obj_counter=0; 
$army=2;

if (! open (VEH, "<$DIST_VEHICULOS")) {
    print "cant open file $DIST_VEHICULOS: $!\n";
    print "enter to end";
    <>; 
    exit(0); 
}
if (! open (MIS_IN, "<$MISION")) {
    print "cant open $MISION: $!\n";
    print "enter para finalizar";
    <>; 
    exit(0); 
}
if (! open (MIS_OUT, ">$SALIDA")) { 
    print "cant open $SALIDA: $!\n";
    print "enter to end";
    <>; 
    exit(0); 
}


my $linea=0;
seek MIS_IN, 0, 0;
while(<MIS_IN>) {
    $linea++;
    if ($_ !~ m/ *NORMFLY ([^ ]+) ([^ ]+)/){
	if ($_ =~ m/(?:MAIN|MAP|TIME|Cloud|army)/){
	    print MIS_OUT;
	}
	if ($_ =~ m/(?:player)/){
	    print MIS_OUT;
	    print MIS_OUT "[NStationary]\n"
	    }
    }
    else{
	$coord_p1x=$1;
	$coord_p1y=$2;	
	$_=readline(MIS_IN);
	$linea++;
	$_ =~ m/ *NORMFLY ([^ ]+) ([^ ]+) ([^ ]+)/;
	$coord_p2x=$1;
	$coord_p2y=$2;
	$vector_x = ($coord_p2x - $coord_p1x);
	$vector_y = ($coord_p2y - $coord_p1y);

	$modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
	if ($modulo==0) { 
	    print "Incorrect WP amount. Expected pair number of WP, read even.\n";
	    print "incorrect data in file $MISION on line: $linea \n\n";
            print "enter to end";
	    <>;
	    exit(0);
	}
	$vector_x/=$modulo;
	$vector_y/=$modulo;
	
	if ($vector_x==0){
	    if ($vector_y>=0){$angle=90;}
	    else {$angle=270;}
	}
	else {
	    $angle=atan2(abs($coord_p2y - $coord_p1y),abs($coord_p2x - $coord_p1x));
	    $angle=$angle * 57.3;
	    if ($vector_y<=0){ # 3ro y 4to cuad
		if ($vector_x>=0){$angle=360-$angle;} #4to cuad
		else {$angle+=180;} #3er cuad
	    }
	    else{ # 2do cuad o 1er quad (no hacemos nada)
		if ($vector_x<0){ $angle=180-$angle;} # 2do cuad
	    }
	}
	while ($angle >360){ $angle-=360;}
	$angle=360-$angle; # para los rusos es giro en otro sentido.
	$angle=int($angle); # el valor entero
	
	
	# aqui ya tenemos: el punto inicial, la direccion, el angulo del objeto
	# y la cantidad de espacio para ubicar los objetos, metros usados = 0;
	$m_usados=0;
	$angle+=90; # rotamos

	while ($m_usados<$modulo-5) {  # mientras no nos pasemos
	    $to_place=int(rand(3)+1);  # de 1 a 3 objetos
	    $obj_nr=int(rand(1000)+1); # objeto al azar de 1 a 1000 ;
	    
	    seek VEH,0,0;  
	    while(<VEH>) { 
		 if ( $_ =~ m/#ST2[0-9]{2},$army,[^,]+,([^,]+),([^,]+):([0-9]+)/){
		     if ($obj_nr<=$3){
			 $wspan=$2;
			 $object=$1;
			 last;
		     }
		 }
	     }
	     while ($to_place && $m_usados<$modulo-5) { # mientras no nos pasemos   
		 #avanzamos medio wingspan,
		 $coord_p1x +=($wspan/2*$vector_x);
		 $coord_p1y +=($wspan/2*$vector_y); 
		 #colocamos el vehiculo
		 print MIS_OUT $s_obj_counter."_Static ".$object." ".$army." ".
		     (int($coord_p1x*100)/100)." ".(int($coord_p1y*100)/100)." ".$angle." 0\n";
		 $s_obj_counter++;
		 $to_place--;
		 #avanzamos otro medio wingspan 
		 $coord_p1x +=(($wspan/2)*$vector_x);
		 $coord_p1y +=(($wspan/2)*$vector_y); 
		 $m_usados+=$wspan;		    
	     }
	 }
    }
}
print MIS_OUT "[Buildings]\n";
print MIS_OUT "[Bridge]\n";
print MIS_OUT "[House]\n";

print "\npress enter to end";
<>;

#do not remove:

#ST200,2,JU87b2,vehicles.planes.Plane$JU_87B2,25:150
#ST201,2,JU88,vehicles.planes.Plane$JU_88A4,30:250
#ST202,2,HE111,vehicles.planes.Plane$HE_111H2,30:400
#ST203,2,FW189,vehicles.planes.Plane$FW_189A2,25:500
#ST204,2,BF110,vehicles.planes.Plane$BF_110C4,25:600
#ST205,2,FW190a4,vehicles.planes.Plane$FW_190A4,15:700
#ST206,2,BF109g2,vehicles.planes.Plane$BF_109G2,15:800
#ST207,2,BF109E,vehicles.planes.Plane$BF_109E7,15:950
#ST208,2,Opel Fuel,vehicles.stationary.Stationary$OpelBlitz6700A_fuel,10:1000

