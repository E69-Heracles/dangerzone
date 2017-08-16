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