require "config.pl";

## @Heracles@20170816
## Tactical target generation
sub tactical_targets($$$) {
    
    my $army =  shift @_;
    my $army_target = shift @_;
    my $geo = shift @_;

    my @possible = ();
    my $line_back;
    
    seek $geo,0,0;
    while(<$geo>) 
    {
        if ($_ =~  m/SEC[^,]+,([^,]+),([^,]+),([^,]+),[^:]*:\Q$army_target\E.*$/) 
        {
            $tgt_name=$1;
            $cxo=$2;
            $cyo=$3;
            $near=500000; # gran distancia para comenzar (500 km)
            $line_back=tell $geo; 

            seek $geo,0,0;
            while(<$geo>) 
            {
                if ($_ =~ m/SEC[^,]+,[^,]+,([^,]+),([^,]+),([^,]+),[^:]+:\Q$army\E/)
                {
                    # @Heracles@20110920
                    # Si el TTL=0 no se pueda atacar desde este sector
                    if ($3 == 0) 
                    { 
                        next;
                    }
                    
                    $dist= distance($cxo,$cyo,$1,$2);
                    
                    if ($dist<16000) 
                    {
                        my $cityname="NONE";
                        seek $geo,0,0;
                        while(<$geo>) {
                            if  ($_ =~ m/poblado,([^,]+),$tgt_name/ ) 
                            { # si es un sec con city: poblado,Obol,sector--A15
                                $cityname=$1;
                            }
                        }

                        if ($cityname ne "NONE") 
                        {
                            seek $geo,0,0;
                            while(<$geo>) 
                            {
                                if ( $_ =~ m/^CT[0-9]{2},$cityname,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),[^:]+:[12].*$/) 
                                {
                                    if ($1 > $CITY_DAM) 
                                    {
                                        push (@possible,$tgt_name);
                                        last;
                                    }
                                }
                            }
                        }
                        else 
                        {
                            push (@possible,$tgt_name);
                            last;
                        }
                    }
                }
            }
            seek $geo,$line_back,0; # regrresamos a la misma sig linea       
        }
    }

    return \@possible;
}

## @Heracles@20170816
## Strategic airfield target generation
sub strategic_airfield_targets($$$$$) {
    
    my $army =  shift @_;
    my $army_target = shift @_;
    my $geo = shift @_;
    my $front = shift @_;
    my $task_stock_BA = shift @_;

    my @possible = ();

    ## @Heracles@20110727
    ## Solo seleccionar AF para misión BA si quedan aviones BA
    if ($task_stock_BA >= $MIN_STOCK_FOR_FLYING) 
    {
        seek $geo,0,0;
        while(<$geo>) {
            if ($_ =~  m/(AF.{2}),([^,]+),([^,]+),([^,]+),[^:]*:\Q$army_target\E.*$/) 
            {
                $tgt_name=$2;
                $cxo=$3;
                $cyo=$4;
                $near=500000; # gran distancia para comenzar (500 km)
                
                seek $front,0,0;
                while(<$front>) 
                {
                    if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) \Q$army\E/)
                    {
                        $dist= distance($cxo,$cyo,$1,$2);
                        if ($dist < $near) 
                        {
                            $near=$dist;
                            if ($dist<$MAX_DIST_AF_BA) 
                            {
                                last;
                            }
                        }
                    }
                }
                if ($near <$MAX_DIST_AF_BA) {
                    push (@possible,$tgt_name); # los ponemos al final
                }
            }
        }
    }

    return \@possible;
}

## @Heracles@20170817
## Strategic airfield target generation
sub strategic_city_targets($$$$$) {
    
    my $army =  shift @_;
    my $army_target = shift @_;
    my $geo = shift @_;
    my $front = shift @_;
    my $task_stock_BA = shift @_;

    my @possible = ();

    ## @Heracles@20110727
    ## Solo seleccionar ciudad para misión BA si quedan aviones BA
    if ($task_stock_BA >= $MIN_STOCK_FOR_FLYING) 
    {
        seek $geo,0,0;
        while(<$geo>) 
        {
            if ($_ =~  m/^(CT[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^:]+):\Q$army_target\E.*$/) 
            {
                $tgt_name=$2;
                $cxo=$3;
                $cyo=$4;
                $near=500000; # gran distancia para comenzar (500 km)
                
                seek $front,0,0;
                while(<$front>) 
                {
                    if ($_ =~ m/FrontMarker[0-9]?[0-9]?[0-9] ([^ ]+) ([^ ]+) \Q$army\E/)
                    {
                        $dist= distance($cxo,$cyo,$1,$2);
                        if ($dist < $near) 
                        {
                            $near=$dist;
                            if ($dist < $MAX_DIST_CITY_BA) 
                            {
                                last;
                            }
                        }
                    }
                }

                if ($near < $MAX_DIST_CITY_BA) 
                {
                    push(@possible,$tgt_name);
                }
            }
        }
    }

    return \@possible;
}

## @Heracles@20170816
## Supply airfield target generation
sub supply_airfield_targets($$$$$$) {
    
    my $army = shift @_;
    my $task_stock_SUM = shift @_;
    my $capacity = shift @_;
    my $plane_supply = shift @_;
    my $cg_bases = shift @_;
    my $geo = shift @_;

    my @cg_bases = @$cg_bases;
    my @possible = ();    

    ## @Heracles@20110805
    ## Solo seleccionar suministro si quedan aviones SUM
    if ($task_stock_SUM >= $MIN_STOCK_FOR_FLYING && ($capacity >= $plane_supply)) 
    {
        seek $geo,0,0;
        while(<$geo>) 
        {
            if ($_ =~  m/(AF[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^,]+):\Q$army\E/) 
            {
                $tgt_name= "SUA-" . $2;
                $cxo=$3;
                $cyo=$4;
                $damage=$5;
                
                my $cg_base=0;
                foreach my $af_cg (@cg_bases) 
                {
                    if ($af_cg eq $2) {
                        $cg_base = 1;
                    }
                }       
                
                if ($damage > 0 && $damage < 100 && !$cg_base) 
                {
                    push (@possible,$tgt_name);
                }
            }
        }
    }

    return \@possible;    
}

## @Heracles@20170816
## Supply city target generation
sub supply_city_targets($$$) {
    
    my $army = shift @_;
    my $task_stock_SUM = shift @_;
    my $geo = shift @_;

    my @possible = ();   

    ## @Heracles@20110727
    ## Solo seleccionar suministro si quedan aviones SUM    
    if ($task_stock_SUM >= $MIN_STOCK_FOR_FLYING) 
    {    
        seek $geo,0,0;
        while(<$geo>) 
        {
            if ($_ =~  m/^(SUC[0-9]{2}),([^,]+),([^,]+),([^,]+),[^,]+,[^,]+,[^,]+,[^,]+,([^:]+):\Q$army\E.*$/) 
            {
                $tgt_name=$2;
                $cxo=$3;
                $cyo=$4;
                
                ## @Heracles@20110719@
                ## No se pueden seleccionar como objetivo las ciudades con el 100% de suministro
                my $my_city = $1;
                $my_city =~ m/SUC([0-9]+)/;
                $my_city = $1;
                                                                                                
                $line_back=tell $geo;                 ##lemos la posicion en el archivo      
                seek $geo,0,0;
                while(<$geo>) 
                {
                    if ( $_ =~ m/^CT$my_city,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),[^:]+:[\Q$army\E].*$/) 
                    {
                        if ($1 > 0) 
                        {
                            push (@possible,$tgt_name);
                        }
                    }
                }
                seek $geo,$line_back,0; # regresamos a la misma sig linea        
            }
        }
    }

    return \@possible;

}