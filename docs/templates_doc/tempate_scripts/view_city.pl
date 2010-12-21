
use POSIX;

$DIST_VEHICULOS="$0";
$MISION="city.mis";
$SALIDA="preview_city.mis";

$s_obj_counter=0; 
$army=1; # red es 1 ...   blue es 2

if (! open (VEH, "<$DIST_VEHICULOS")) {
    print "cant open file  $DIST_VEHICULOS: $!\n";
    print "press enter to end";
    <>; 
    exit(0); 
}
if (! open (MIS_IN, "<$MISION")) {
    print "cant open file  $MISION: $!\n";
    print "press enter to end";
    <>; 
    exit(0); 
}
if (! open (MIS_OUT, ">$SALIDA")) { 
    print "cant open file  $SALIDA: $!\n";
    print "press enter to end";
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
	$type=$3;
	$vector_x = ($coord_p2x - $coord_p1x);
	$vector_y = ($coord_p2y - $coord_p1y);

	$modulo =(sqrt($vector_x ** 2 + $vector_y ** 2));
	if ($modulo==0) { 
	    print "Incorrect WP amount. Expected pair number of WP, read even.\n";
	    print "incorrect data in file $MISION on line: $linea \n\n";
            print "press enter to end";
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
	    $angle=POSIX::atan2(abs($coord_p2y - $coord_p1y),abs($coord_p2x - $coord_p1x));
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
	
	if ($type==2000) { # si es typo aaa 
	    if ($army==1) {
		$object="vehicles.artillery.Artillery\$Zenit85mm_1939";
		if (rand(100)<50){
		    $object="vehicles.artillery.Artillery\$Zenit25mm_1940";
		}
	    }
	    else { # blue
		$object="vehicles.artillery.Artillery\$Flak18_88mm";
		if (rand(100)<50){
		    $object="vehicles.artillery.Artillery\$Flak30_20mm";
		}
	    }
	    #colocamos solo una aaa
	    print MIS_OUT $s_obj_counter."_Static ".$object." ".$army." ".int($coord_p1x)
		." ".int($coord_p1y)." ".$angle." 0\n";
	    $s_obj_counter++;
	}
	
	## Vehiculos: tipo 500 angulo normal y tipo 1000 son vehiculos rotados 90 a derecha (+90 en rusia?)
	if ($type==500 || $type==1000) {

	    if ($type==1000) {$angle+=90;} # rotamos

	    while ($m_usados<$modulo-5) {  # mientras no nos pasemos
		$to_place=int(rand(3)+1);  # de 1 a 3 objetos
		$obj_nr=int(rand(1000)+1); # objeto al azar de 1 a 1000 ;

		if ($army==1) {  # objetos  rojos
		    seek VEH,0,0;
		    while(<VEH>) {
			if ( $_ =~ m/SV1[0-9]{2},$army,[^,]+,([^,]+),([^,]+):([0-9]+)/){
			    if ($obj_nr<=$3){
				$wspan=$2;
				$object=$1;
				last;
			    }
			}
		    }
		}
		else { #  objetos  azules
		    seek VEH,0,0;  
		    while(<VEH>) {
			if ( $_ =~ m/SV2[0-9]{2},$army,[^,]+,([^,]+),([^,]+):([0-9]+)/){
			    if ($obj_nr<=$3){
				$wspan=$2;
				$object=$1;
				last;
			    }
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
	
	if ($type==1500) { #trenes
	    $angle+=180; # porque primero colocamos la locomotora, asi no queda mirando alreves
	    if ($army==1){ $object="vehicles.stationary.Stationary\$Wagon9";}
	    else { $object="vehicles.stationary.Stationary\$Wagon11";}
	    $wspan=15;
	    $coord_p1x +=($wspan/2*$vector_x);
	    $coord_p1y +=($wspan/2*$vector_y); 
	    print MIS_OUT $s_obj_counter."_Static ".$object." ".$army." ".
		(int($coord_p1x*100)/100)." ".(int($coord_p1y*100)/100)." ".$angle." 0\n";
	    $s_obj_counter++;
	    $coord_p1x +=((1+$wspan/2)*$vector_x);
	    $coord_p1y +=((1+$wspan/2)*$vector_y); 
	    $m_usados+=$wspan+1;		    
	    #ahora colocamos el vagon de carbon
	    if ($army==1){$object="vehicles.stationary.Stationary\$Wagon10";}
	    else {$object="vehicles.stationary.Stationary\$Wagon12";}
	    $wspan=9;
	    $coord_p1x +=($wspan/2*$vector_x);
	    $coord_p1y +=($wspan/2*$vector_y); 
	    print MIS_OUT $s_obj_counter."_Static ".$object." ".$army." ".
		(int($coord_p1x*100)/100)." ".(int($coord_p1y*100)/100)." ".$angle." 0\n";
	    $s_obj_counter++;
	    $coord_p1x +=((1+$wspan/2)*$vector_x);
	    $coord_p1y +=((1+$wspan/2)*$vector_y); 
	    $m_usados+=$wspan+1;		    
	    $angle-=180;
	    $wspan=15;
	    $to_place=0;
	    # el resto del espacio es para vagones
	    while ($m_usados<=$modulo-$wspan) { # mientras no nos pasemos   
		if ($to_place==0){
		    $to_place=int(rand(5)+2); # de 2 a 6 objetos
		    # seleccionamos wagon 2 a 7 (evitamos 1 y 8 son explosivos)
		    $object="vehicles.stationary.Stationary\$Wagon".int(rand(6)+2); 
		}
		$coord_p1x +=($wspan/2*$vector_x);
		$coord_p1y +=($wspan/2*$vector_y); 
		print MIS_OUT $s_obj_counter."_Static ".$object." ".$army." ".
		    (int($coord_p1x*100)/100)." ".(int($coord_p1y*100)/100)." ".$angle." 0\n";
		$s_obj_counter++;
		$to_place--;
		$coord_p1x +=((1+$wspan/2)*$vector_x);
		$coord_p1y +=((1+$wspan/2)*$vector_y); 
		$m_usados+=$wspan+1;		    
	    }
	}
    }
}

print MIS_OUT "[Buildings]\n";
print MIS_OUT "[Bridge]\n";
print MIS_OUT "[House]\n";

print "\npress enter to end";
<>;


#SV101,1,GAZ67,vehicles.stationary.Stationary$GAZ67,10:100
#SV102,1,GAZ67t,vehicles.stationary.Stationary$GAZ67t,10:200
#SV103,1,GAZ_M1,vehicles.stationary.Stationary$GAZ_M1,10:300
#SV104,1,ZIS5_PC,vehicles.stationary.Stationary$ZIS5_PC,10:400
#SV105,1,StudebeckerTruck,vehicles.stationary.Stationary$StudebeckerTruck,10:550
#SV106,1,StudebeckerRocket,vehicles.stationary.Stationary$StudebeckerRocket,10:650
#SV107,1,Katyusha,vehicles.stationary.Stationary$Katyusha,10:750
#SV109,1,ZIS5_AA,vehicles.stationary.Stationary$ZIS5_AA,10:825
#SV112,1,BA_10,vehicles.stationary.Stationary$BA_10,10:900
#SV108,1,ZIS6_fuel,vehicles.stationary.Stationary$ZIS6_fuel,10:940
#SV113,1,ZIS5_radio,vehicles.stationary.Stationary$ZIS5_radio,10:970
#SV114,1,ZIS5_medic,vehicles.stationary.Stationary$ZIS5_medic,10:1000
#SV201,2,VW82,vehicles.stationary.Stationary$VW82,10:80
#SV202,2,VW82t,vehicles.stationary.Stationary$VW82t,10:160
#SV203,2,OpelKadett,vehicles.stationary.Stationary$OpelKadett,10:260
#SV204,2,OpelBlitz36S,vehicles.stationary.Stationary$OpelBlitz36S,10:340
#SV205,2,OpelBlitz6700A,vehicles.stationary.Stationary$OpelBlitz6700A,10:440
#SV206,2,Kettenkrad,vehicles.stationary.Stationary$Kettenkrad,10:500
#SV207,2,RSO,vehicles.stationary.Stationary$RSO,10:580
#SV208,2,OpelBlitzMaultier,vehicles.stationary.Stationary$OpelBlitzMaultier,10:680
#SV209,2,OpelBlitzMaultierRocket,vehicles.stationary.Stationary$OpelBlitzMaultierRocket,10:820
#SV210,2,OpelBlitzMaultierAA,vehicles.stationary.Stationary$OpelBlitzMaultierAA,10:900
#SV211,2,OpelBlitz6700A_fuel,vehicles.stationary.Stationary$OpelBlitz6700A_fuel,10:940
#SV212,2,OpelBlitz6700A_radio,vehicles.stationary.Stationary$OpelBlitz6700A_radio,10:970
#SV213,2,OpelBlitz6700A_medic,vehicles.stationary.Stationary$OpelBlitz6700A_medic,10:1000
