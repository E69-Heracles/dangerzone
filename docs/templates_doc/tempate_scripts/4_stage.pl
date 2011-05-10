## E69_Heracles @20110507@
## Script numero 4 para el diseno de campanas para la Danger Zone
## Este script valida el formato del fichero aircrafts.data generado para la campana
## y certifica que el contenido sea valido para ser cargado en el simulador IL-2 1946
## Se generan :
## - 1 fichero de informe.
## - n ficheros de mision para ser cargados y comprobados en el IL-2.
$FLIGHTS_DEF="KUR_aircrafts.data";
$MAP_NAME_LOAD="Kursk/load.ini";

$FLIGHTS_REP="aircraft.rep";

use IO::Handle;
$|=1;

# later update to include hungarian, finish, italian, etc..
@rusfig=();
@rusbom=();
@rusjab=();
@rustrp=();
@romfig=();
@rombom=();
@romjab=();
@gerfig=();
@gerbom=();
@gerjab=();
@gertrp=();
@hunfig=();
@hunbom=();
@hunjab=();
@usafig=();
@usabom=();
@usajab=();
@usatrp=();
@brifig=();
@bribom=();
@brijab=();
@britrp=();

@rusfigf=();
@rusbomf=();
@rusjabf=();
@rustrpf=();
@romfigf=();
@rombomf=();
@romjabf=();
@gerfigf=();
@gerbomf=();
@gerjabf=();
@gertrpf=();
@hunfigf=();
@hunbomf=();
@hunjabf=();
@usafigf=();
@usabomf=();
@usajabf=();
@usatrpf=();
@brifigf=();
@bribomf=();
@brijabf=();
@britrpf=();

@rusfigw=();
@rusbomw=();
@rusjabw=();
@rustrpw=();
@romfigw=();
@rombomw=();
@romjabw=();
@gerfigw=();
@gerbomw=();
@gerjabw=();
@gertrpw=();
@hunfigw=();
@hunbomw=();
@hunjabw=();
@usafigw=();
@usabomw=();
@usajabw=();
@usatrpw=();
@brifigw=();
@bribomw=();
@brijabw=();
@britrpw=();

@misba=();
@missum=();
@misbd=();
@miseba=();
@misesu=();
@misebd=();
@miset=();
@misint=();
@misat=();

$mis_file=0;

$errors=0;


sub borra_ficheros_mision() {
    
    unlink glob "*.mis";

}

sub print_header($) {
    my ($file) = shift @_;

    print $file "[MAIN]\n";
    print $file "  MAP $MAP_NAME_LOAD\n";
    print $file "  TIME 8.00\n";
    print $file "  CloudType 0\n";
    print $file "  CloudHeight 1000\n";
    print $file "  army 1\n";
    print $file "  playerNum 0\n";
}

sub print_grplsts($) {
    my ($file) = shift @_;
    
    print $file "[Wing]\n";
}

sub create_sqdarray(){

    seek FLIGHTS,0,0;
    while (<FLIGHTS>){
	if ($_ =~ m/^rusfig=(.*);/) {
	    push (@rusfig ,(split /,/,$1));
	}
	if ($_ =~ m/^rusjab=(.*);/) {
	    push (@rusjab ,(split /,/,$1));
	}
	if ($_ =~ m/^rusbom=(.*);/) {
	    push (@rusbom ,(split /,/,$1));
	}
	if ($_ =~ m/^rustrp=(.*);/) {
	    push (@rustrp ,(split /,/,$1));
	}
	if ($_ =~ m/^romfig=(.*);/) {
	    push (@romfig ,(split /,/,$1));
	}
	if ($_ =~ m/^romjab=(.*);/) {
	    push (@romjab ,(split /,/,$1));
	}
	if ($_ =~ m/^rombom=(.*);/) {
	    push (@rombom ,(split /,/,$1));
	}
	if ($_ =~ m/^gerfig=(.*);/) {
	    push (@gerfig ,(split /,/,$1));
	}
	if ($_ =~ m/^gerjab=(.*);/) {
	    push (@gerjab ,(split /,/,$1));
	}
	if ($_ =~ m/^gerbom=(.*);/) {
	    push (@gerbom ,(split /,/,$1));
	}
	if ($_ =~ m/^gertrp=(.*);/) {
	    push (@gertrp ,(split /,/,$1));
	}
	if ($_ =~ m/^hunfig=(.*);/) {
	    push (@hunfig ,(split /,/,$1));
	}
	if ($_ =~ m/^hunjab=(.*);/) {
	    push (@hunjab ,(split /,/,$1));
	}
	if ($_ =~ m/^hunbom=(.*);/) {
	    push (@hunbom ,(split /,/,$1));
	}
	if ($_ =~ m/^usafig=(.*);/) {
	    push (@usafig ,(split /,/,$1));
	}
	if ($_ =~ m/^usajab=(.*);/) {
	    push (@usajab ,(split /,/,$1));
	}
	if ($_ =~ m/^usabom=(.*);/) {
	    push (@usabom ,(split /,/,$1));
	}
	if ($_ =~ m/^usatrp=(.*);/) {
	    push (@usatrp ,(split /,/,$1));
	}
	if ($_ =~ m/^brifig=(.*);/) {
	    push (@brifig ,(split /,/,$1));
	}
	if ($_ =~ m/^brijab=(.*);/) {
	    push (@brijab ,(split /,/,$1));
	}
	if ($_ =~ m/^bribom=(.*);/) {
	    push (@bribom ,(split /,/,$1));
	}
	if ($_ =~ m/^britrp=(.*);/) {
	    push (@britrp ,(split /,/,$1));
	}
    }
}


sub create_mis_array() {
    seek FLIGHTS,0,0;
    while (<FLIGHTS>){
        if ($_ =~ m/^(1|2),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+):([^,]+),([0-9]+),/){
		if ($10 eq "BA") {
		    push (@misba,[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
		}
		if ($10 eq "SUM") {
		    push (@missum,[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
		}
		if ($10 eq "BD") {
		    push (@misbd,[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
		}
		if ($10 eq "EBA") {
		    push (@miseba,[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
		}	
		if ($10 eq "ESU") {
		    push (@misesu,[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
		}
		if ($10 eq "EBD") {
		    push (@misebd,[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
		}
		if ($10 eq "ET") {
		    push (@miset,[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
		}	
		if ($10 eq "I") {
		    push (@misint,[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
		}
		if ($10 eq "AT") {
		    push (@misat,[$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
		}			
	}
    }    
}

sub create_role_array(){
    seek FLIGHTS,0,0;
    while (<FLIGHTS>){
        if ($_ =~ m/^(1|2),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+):([^,]+),([0-9]+),/){
	    if ($2 eq "rusfig") {
		push (@rusfigf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }
	    if ($2 eq "rusbom") {
		push (@rusbomf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }
	    if ($2 eq "rusjab") {
		push (@rusjabf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }
	    if ($2 eq "rustrp") {
		push (@rustrpf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "romfig") {
		push (@romfigf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }
	    if ($2 eq "rombom") {
		push (@rombomf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }
	    if ($2 eq "romjab") {
		push (@romjabf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "gerfig") {
		push (@gerfigf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "gerbom") {
		push (@gerbomf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "gerjab") {
		push (@gerjabf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "gertrp") {
		push (@gertrpf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "hunfig") {
		push (@hunfigf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "hunbom") {
		push (@hunbomf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "hunjab") {
		push (@hunjabf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "usafig") {
		push (@usafigf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "usabom") {
		push (@usabomf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "usajab") {
		push (@usajabf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "usatrp") {
		push (@usatrpf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "brifig") {
		push (@brifigf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "bribom") {
		push (@bribomf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	    if ($2 eq "brijab") {
		push (@brijabf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }
	    if ($2 eq "britrp") {
		push (@britrpf,[$1,$3,$4,$5,$6,$7,$8,$9,$10,$11]);
	    }	
	}
    }    
}


sub print_mis_type(@) {
    my $my_army = shift @_;
    my $my_mistypename = shift @_;
    my $my_mistype = shift @_;
    
    my $my_anterior=0;
    my $my_lineas=0;
    my $index=0;
    print REP "\n";
    print REP "###############################################\n";    
    print REP "## $my_mistypename\n";
    foreach (@$my_mistype) {
        if ($$my_mistype[$index][0] eq $my_army){
		$my_lineas++;
        }
	$index++;
    }
    print REP "## Numero de linias : " . $my_lineas . ".\n";
    
    $index=0;
    foreach (@$my_mistype) {
        if ($$my_mistype[$index][0] eq $my_army) {
		my $my_plane = sprintf("%15s", $$my_mistype[$index][2]);
		my $my_number = sprintf("%4s", $$my_mistype[$index][10]);
		print REP "$$my_mistype[$index][1] -  $my_plane Total: $my_number\n";
		if ($$my_mistype[$index][10] < $my_anterior) {
		    print REP "***ERROR*** Numero total de aviones $$my_mistype[$index][10] es inferior a la linea anterior con $my_anterior aviones.\n";
		    print REP "\n";
		    $errors++;
		}
		$my_anterior = $$my_mistype[$index][10];
        }
	$index++;
    }    
}

sub analiza_formato() {
    print REP "###############################################\n";
    print REP "## Analizando formato de $FLIGHTS_DEF\n";
    print REP "###############################################\n";

    my $spaces=0;
    my $flights=0;
    my $comments=0;
    my $vehicles=0;
    my $static_air=0;
    my $squadrons=0;
    my $noiden=0;

    seek FLIGHTS,0,0;
    while (<FLIGHTS>){
        if ($_ =~ m/^\s+/) {
        	$spaces++;
        	next;
        }
        if ($_ =~ m/^#.*/) {
		$comments++;
		next;	
        }	
        if ($_ =~ m/^(1|2),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+):(BA|SUM|BD|EBD|ESU|I|EBA|ET|AT),([0-9]+),/){
        	$flights++;
		next;	
        }
        if ($_ =~ m/^SV[\d]*,([^,]+),([^,]+),([^,]+),([^,]+):([0-9]+)/){
		$vehicles++;
		next;	
        }
        if ($_ =~ m/^ST[\d]*,([^,]+),([^,]+),([^,]+),([^,]+):([0-9]+)/){
		$static_air++;
		next;	
        }
        if ($_ =~ m/^([^,]+)=/ && $_ =~ m/;$/) {
		$squadrons++;
		next;	
        }
        $noiden++;
        print REP $_;
        print REP "***ERROR*** Linia no identificada.\n";
        print REP "\n";
	$errors++;
}

print REP "## Numero de lineas no identificadas: " . sprintf("%3s",$noiden) . "\n";
print REP "## Numero de lineas en blanco: " . sprintf("%10s",$spaces) . "\n";
print REP "## Numero de lineas de aviones: " . sprintf("%8s",$flights) . "\n";
print REP "## Numero de lineas de comentarios: " . sprintf("%5s",$comments) . "\n";
print REP "## Numero de lineas de vehiculos: " . sprintf("%6s",$vehicles) . "\n";
print REP "## Numero de lineas de aviones staticos: " . sprintf("%2s",$static_air) . "\n";
print REP "## Numero de lineas de escuadrones: " . sprintf("%5s",$squadrons) . "\n";
print REP "###############################################\n";
print REP "\n";    
}

sub create_mis_file($$$) {
    my @rol = @{ $_[0] };
    my @rolflight = @{ $_[1] };
    my $filename = $_[2];
    my $mis_num=1;
    my $my_flight=0;
    
    if (scalar(@rol) == 0) {
        print REP "***ERROR*** No se encontro ningun escuadron para este rol.\n";
	$errors++;
	return;
    }
    if (scalar(@rolflight) == 0) {
        print REP "***ERROR*** No se encontro ninguna linea de avion para este rol.\n";
	$errors++;
	return;
    }    
    if (scalar(@rol) >= scalar(@rolflight)) {
        my $printed_head = ( -e $filename . "$mis_num.mis");
        if ( ! open ($mis_file, ">>$filename" . "$mis_num.mis") ) {
            print "Error: Cant open file flights mis\n";
            exit(0);
        }

	select($mis_file);
	if ($printed_head == 0){        
	    print_header($mis_file);
	    print_grplsts($mis_file);
	}
        
        
	for (my $i = 0; $i < scalar(@rolflight); $i++){
	    print $mis_file " " . $rol[$i]. "00" . "\n";
	}
	
        foreach my $my_sqd (@rol) {
            print $mis_file "[" . $my_sqd . "00]\n";
	    print $mis_file "  Planes 1\n";
	    print $mis_file "  Skill 1\n";
	    print $mis_file "  Class $rolflight[($my_flight % scalar(@rolflight))][3]\n";
	    print $mis_file "  Fuel $rolflight[($my_flight % scalar(@rolflight))][5]\n";
	    print $mis_file "  weapons $rolflight[($my_flight % scalar(@rolflight))][4]\n";
	    print $mis_file "[" . $my_sqd . "00_Way]\n";
	    print $mis_file "NORMFLY 5000 5000 " . $rolflight[($my_flight % scalar(@rolflight))][6] . " " . $rolflight[($my_flight % scalar(@rolflight))][7] . " &0\n";
	    print $mis_file "NORMFLY 5000 10000 " . $rolflight[($my_flight % scalar(@rolflight))][6] . " " . $rolflight[($my_flight % scalar(@rolflight))][7] . " &0\n";
	    $my_flight++;
	}
	close($mis_file);

    }
    else {
        while ($my_flight < scalar(@rolflight)) {
	    my $printed_head = ( -e $filename . "$mis_num.mis");
            if ( ! open ($mis_file, ">>$filename" . "$mis_num.mis") ) {
                print "Error: Cant open file flights mid\n";
                exit(0);
            }

	    select($mis_file);
	    if ($printed_head == 0){
		print_header($mis_file);
		print_grplsts($mis_file);
	    }

	    $i = $my_flight;
	    do {
	        print $mis_file " " . $rol[$i % scalar(@rol)] . "00\n";
	        $i++;
	    } until ( ($i == (scalar(@rolflight)) ) || (($i % scalar(@rol)) == 0));
	    do  {
		    print $mis_file "[" . $rol[($my_flight % scalar(@rol))] . "00]\n";
		    print $mis_file "  Planes 1\n";
		    print $mis_file "  Skill 1\n";
		    print $mis_file "  Class $rolflight[$my_flight][3]\n";
		    print $mis_file "  Fuel $rolflight[$my_flight][5]\n";
		    print $mis_file "  weapons $rolflight[$my_flight][4]\n";
		    print $mis_file "[" . $rol[($my_flight % scalar(@rol))] . "00_Way]\n";
		    print $mis_file "NORMFLY 5000 5000 " . $rolflight[$my_flight][6] . " " . $rolflight[$my_flight][7] . " &0\n";
		    print $mis_file "NORMFLY 5000 10000 " . $rolflight[$my_flight][6] . " " . $rolflight[$my_flight][7] . " &0\n";		
		    $my_flight++;
		    if ($my_flight == scalar(@rolflight)) { last;}
	    } until ((($my_flight % scalar(@rol)) == 0));
	    $mis_num++;
	    close($mis_file)
	}

    }    
}

## MAIN


if ( ! open (FLIGHTS, "<$FLIGHTS_DEF") ) {
    print "Error: Cant open file flights def\n";
    exit(0);
}

if ( ! open (REP, ">$FLIGHTS_REP") ) {
    print "Error: Cant open file flights rep\n";
    exit(0);
}


borra_ficheros_mision();
analiza_formato();
create_sqdarray();
create_role_array();
create_mis_array();

print REP "###############################################\n";
print REP "## Tipos de misiones bando ROJO\n";
print REP "###############################################\n";
print_mis_type(1, "BA", \@misba);
print_mis_type(1, "SUM", \@missum);
print_mis_type(1, "BD", \@misbd);
print_mis_type(1, "EBA", \@miseba);
print_mis_type(1, "ESU", \@misesu);
print_mis_type(1, "EBD", \@misebd);
print_mis_type(1, "ET", \@miset);
print_mis_type(1, "INT", \@misint);
print_mis_type(1, "AT", \@misat);
print REP "\n";
print REP "###############################################\n";
print REP "## Tipos de misiones bando AZUL\n";
print REP "###############################################\n";
print_mis_type(2, "BA", \@misba);
print_mis_type(2, "SUM", \@missum);
print_mis_type(2, "BD", \@misbd);
print_mis_type(2, "EBA", \@miseba);
print_mis_type(2, "ESU", \@misesu);
print_mis_type(2, "EBD", \@misebd);
print_mis_type(2, "ET", \@miset);
print_mis_type(2, "INT", \@misint);
print_mis_type(2, "AT", \@misat);
print REP "\n";

print REP "###############################################\n";
print REP "## Numero de escuadrones y aviones ROJOS\n";
print REP "###############################################\n";
## Creamos los ficheros de mision para validar si cargan en el IL-2 todos los escuadrones y los aviones
## rusfig
if (scalar(@rusfig) > 0) {
    print REP "\n";
    print REP "Escua. de cazas rusos:" . scalar(@rusfig) . "\n";
    print REP "Lineas de cazas rusos:" . scalar(@rusfigf) . "\n";
    create_mis_file(\@rusfig, \@rusfigf, "rusfig");
}
## rusbom
if (scalar(@rusbom) > 0) {
    print REP "\n";
    print REP "Escua. de bomber rusos:" . scalar(@rusbom) . "\n";
    print REP "Lineas de bomber rusos:" . scalar(@rusbomf) . "\n";
    create_mis_file(\@rusbom, \@rusbomf, "rusbom");
}
## rusjab
if (scalar(@rusjab) > 0) {
    print REP "\n";
    print REP "Escua. de jabos rusos:" . scalar(@rusjab) . "\n";
    print REP "Lineas de jabos rusos:" . scalar(@rusjabf) . "\n";
    create_mis_file(\@rusjab, \@rusjabf, "rusjab");
}
## rustrp
if (scalar(@rustrp) > 0) {
    print REP "\n";
    print REP "Escua. de transporte rusos:" . scalar(@rustrp) . "\n";
    print REP "Lineas de transporte rusos:" . scalar(@rustrpf) . "\n";
    create_mis_file(\@rustrp, \@rustrpf, "rustrp");
}
## usafig
if (scalar(@usafig) > 0) {
    print REP "\n";
    print REP "Escua. de cazas USA:" . scalar(@usafig) . "\n";
    print REP "Lineas de cazas USA" . scalar(@usafigf) . "\n";
    create_mis_file(\@usafig, \@usafigf, "usafig");
}
## usabom
if (scalar(@usabom) > 0) {
    print REP "\n";
    print REP "Escua. de bomber USA:" . scalar(@usabom) . "\n";
    print REP "Lineas de bomber USA:" . scalar(@usabomf) . "\n";
    create_mis_file(\@usabom, \@usabomf, "usabom");
}
## usajab
if (scalar(@usajab) > 0) {
    print REP "\n";
    print REP "Escua. de jabos USA:" . scalar(@usajab) . "\n";
    print REP "Lineas de jabos USA:" . scalar(@usajabf) . "\n";
    create_mis_file(\@usajab, \@usajabf, "usajab");
}
## usatrp
if (scalar(@usatrp) > 0) {
    print REP "\n";
    print REP "Escua. de transporte USA:" . scalar(@usatrp) . "\n";
    print REP "Lineas de transporte USA:" . scalar(@usatrpf) . "\n";
    create_mis_file(\@usatrp, \@usatrpf, "usatrp");
}
## brifig
if (scalar(@brifig) > 0) {
    print REP "\n";
    print REP "Escua. de cazas RAF:" . scalar(@brifig) . "\n";
    print REP "Lineas de cazas RAF:" . scalar(@brifigf) . "\n";
    create_mis_file(\@brifig, \@brifigf, "brifig");
}
## bribom
if (scalar(@bribom) > 0) {
    print REP "\n";
    print REP "Escua. de bomber RAF:" . scalar(@bribom) . "\n";
    print REP "Lineas de bomber RAF:" . scalar(@bribomf) . "\n";
    create_mis_file(\@bribom, \@bribomf, "bribom");
}
## brijab
if (scalar(@brijab) > 0) {
    print REP "\n";
    print REP "Escua. de jabos RAF:" . scalar(@brijab) . "\n";
    print REP "Lineas de jabos RAF:" . scalar(@brijabf) . "\n";
    create_mis_file(\@brijab, \@brijabf, "brijab");
}
## britrp
if (scalar(@britrp) > 0) {
    print REP "\n";
    print REP "Escua. de transporte RAF:" . scalar(@britrp) . "\n";
    print REP "Lineas de transporte RAF:" . scalar(@britrpf) . "\n";
    create_mis_file(\@britrp, \@britrpf, "britrp");
}
print REP "###############################################\n";
print REP "## Numero de escuadrones y aviones AZULES\n";
print REP "###############################################\n";
## romfig
if (scalar(@romfig) > 0) {
    print REP "\n";
    print REP "Escua. de cazas rumanos:" . scalar(@romfig) . "\n";
    print REP "Lineas de cazas rumanos:" . scalar(@romfigf) . "\n";
    create_mis_file(\@romfig, \@romfigf, "romfig");
}
## rombom
if (scalar(@rombom) > 0) {
    print REP "\n";
    print REP "Escua. de bomber rumanos:" . scalar(@rombom) . "\n";
    print REP "Lineas de bomber rumanos:" . scalar(@rombomf) . "\n";
    create_mis_file(\@rombom, \@rombomf, "rombom");
}
## romjab
if (scalar(@romjab) > 0) {
    print REP "\n";
    print REP "Escua. de jabos rumanos:" . scalar(@romjab) . "\n";
    print REP "Lineas de jabos rumanos:" . scalar(@romjabf) . "\n";
    create_mis_file(\@romjab, \@romjabf, "romjab");
}
## gerfig
if (scalar(@gerfig) > 0) {
    print REP "\n";
    print REP "Escua. de cazas Luftwaffe:" . scalar(@gerfig) . "\n";
    print REP "Lineas de cazas Luftwaffe:" . scalar(@gerfigf) . "\n";
    create_mis_file(\@gerfig, \@gerfigf, "gerfig");
}
## gerbom
if (scalar(@gerbom) > 0) {
    print REP "\n";
    print REP "Escua. de bomber Luftwaffe:" . scalar(@gerbom) . "\n";
    print REP "Lineas de bomber Luftwaffe:" . scalar(@gerbomf) . "\n";
    create_mis_file(\@gerbom, \@gerbomf, "gerbom");
}
## gerjab
if (scalar(@gerjab) > 0) {
    print REP "\n";
    print REP "Escua. de jabos Luftwaffe:" . scalar(@gerjab) . "\n";
    print REP "Lineas de jabos Luftwaffe:" . scalar(@gerjabf) . "\n";
    create_mis_file(\@gerjab, \@gerjabf, "gerjab");
}
## gertrp
if (scalar(@gertrp) > 0) {
    print REP "\n";
    print REP "Escua. de transporte Luftwaffe:" . scalar(@gertrp) . "\n";
    print REP "Lineas de transporte Luftwaffe:" . scalar(@gertrpf) . "\n";
    create_mis_file(\@gertrp, \@gertrpf, "gertrp");
}
## hunfig
if (scalar(@hunfig) > 0) {
    print REP "\n";
    print REP "Escua. de cazas hungaros:" . scalar(@hunfig) . "\n";
    print REP "Lineas de cazas hungaros:" . scalar(@hunfigf) . "\n";
    create_mis_file(\@hunfig, \@hunfigf, "hunfig");
}
## hunbom
if (scalar(@hunbom) > 0) {
    print REP "\n";
    print REP "Escua. de bomber hungaros:" . scalar(@hunbom) . "\n";
    print REP "Lineas de bomber hungaros:" . scalar(@hunbomf) . "\n";
    create_mis_file(\@hunbom, \@hunbomf, "hunbom");
}
## hunjab
if (scalar(@hunjab) > 0) {
    print REP "\n";
    print REP "Escua. de jabos hungaros:" . scalar(@hunjab) . "\n";
    print REP "Lineas de jabos hungaros:" . scalar(@hunjabf) . "\n";
    create_mis_file(\@hunjab, \@hunjabf, "hunjab");
}

print STDOUT "Analisis de $FLIGHTS_DEF finalizado.\n";
if ($errors > 0) {
    print STDOUT "Errores encontrados : $errors.\n";
    print STDOUT "$FLIGHTS_DEF no valido para la Danger Zone.\n";
    print STDOUT "Ver el informe de errores en $FLIGHTS_REP para resolverlos.\n"
}

close(FLIGHTS);
unlink glob "*.body";
exit(0);