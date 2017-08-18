require "config.pl";
require "dztools.pl";

sub print_log($$);

## @Heracles@20170816
## Mission weather generator
sub compute_time_and_weather($$$) {

    my $weather_for_next_mission = shift @_; #allowed values 0 or 1
    my $log = shift @_;
    my $rep_nbr = shift @_;

    my $hora;
    my $minutos;
    my $clima;
    my $nubes;
    srand;
    
    $mission_of_day=(($rep_nbr + $weather_for_next_mission) % $MIS_PER_VDAY); # MoD for NEXT mission
    
    if ($mission_of_day==0) {$mission_of_day=$MIS_PER_VDAY;}

    my $map_vday = get_map_vday();

    my $time_increase= int((($SUNSET - $SUNRISE)*60) / $MIS_PER_VDAY); # (12 hours * 60 minutes/hour) / $MIS_PER_VDAY
    $hora=$SUNRISE;
    $minutos=0;
    
    $min_diff=($rep_count % $MIS_PER_VDAY) * $time_increase;
    $min_diff+=int(rand($min_diff));  # 0 ~ ($min_diff -1) random extra time.
    
    $hora+= int($min_diff / 60);
    $minutos+= int($min_diff % 60);

    print_log($log, "compute_time_and_weather(): SUNRISE " . $SUNRISE . " SUNSET " . $SUNSET);
    print_log($log, "compute_time_and_weather(): Hora " . $hora);

    $clima=int(rand(98))+1; #1..98 ( no storms and less precipitations)
    $nubes=500+(int(rand(10))+1)*100; # 500 .. 1500

    my $new_clima=0;
    if ((! open (CLIMA,"<clima.txt")) || $weather_for_next_mission == 1)
    {
        open (CLIMA,">clima.txt");
        print CLIMA $hora."\n";
        print CLIMA $minutos."\n";
        print CLIMA $clima."\n";
        print CLIMA $nubes."\n";
        close(CLIMA);
        print_log($log, "WARNING: CAN'T OPEN clima.txt, creating one <br>\n");
        $new_clima=1;
    }
    else
    {
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
    
    if ($clima<=20)
    { # clima 1..20 -> 20% Clear
        $tipo_clima="Clear";
        $tipo_clima_spa="Despejado";
        $nubes=" -- "; # para  la pagina del generador. (ya esta guardado en disco).
    }
    elsif ($clima>20 && $clima<=90)
    { # clima 21..90 -> 70% Good
        $tipo_clima="Good";
        $tipo_clima_spa="Bueno";    
    }
    elsif ($clima>90 && $clima<=95)
    { # clima 91..95 -> 5% Blind
        $tipo_clima="Low Visibility";
        $tipo_clima_spa="Baja visibilidad"; 
    }
    elsif ($clima>95 && $clima<=99)
    { # clima 96..99 -> 4% Rain/Snow
        $tipo_clima="Precipitations";
        $tipo_clima_spa="Lluvia";   
    }
    elsif ($clima>99 && $clima<=100)
    { # clima only 100 -> 1% Strom
        $tipo_clima="Storm";
        $tipo_clima_spa="Tormenta"; 
    }

    if ($new_clima){
        my $localt=`date`; 
        open (CLIMACTL,">>clima_control.txt");
        
        if (weather_for_next_mission == 1)
        {
            print CLIMACTL "Al reportar $MIS_TO_REP ( rep $rep_nbr ) hora: $hora min: $minutos nubes: $nubes clima: $clima = ";
        }
        else
        {
            print CLIMACTL "Manual change -  hora: $hora min: $minutos nubes: $nubes clima: $clima = ";    
        }
        print CLIMACTL "$tipo_clima : $localt";
        close(CLIMACTL);
    }

    return ($map_vday, $mission_of_day, $hora, $minutos, $tipo_clima_spa, $nubes);
}