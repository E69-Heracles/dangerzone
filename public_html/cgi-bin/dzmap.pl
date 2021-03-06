require "config.pl";
require "dzclima.pl";
require "dztools.pl";

sub compute_time_and_weather($$$);

sub calc_map_points();
sub print_map_and_sta($$$);
sub calc_stocks_plane();
sub calc_sum_plane_supply($$);
sub calc_sectors_owned();
sub get_hq($);

sub print_headquarter_for_army($$$$$$$$$$$);
sub print_plane_inventory_for_army($$$$$$);
sub print_airfield_damage_for_army($$$$$);
sub print_city_damage_for_army($$$$$);

## @Heracles@20170815
## Campaign map info header creation
## Name of map and campaign points
sub print_map_and_points($) {
    my $map = shift @_;

    print $map  &print_start_html;
    print $map "<!-- VICTORY CONDITION -->\n";
    print $map "\n";

    my $blue_points = 0;
    my $red_points = 0;
    ($red_points, $blue_points) = calc_map_points();
  
    if ($red_points > $blue_points) {
    print $map  "<font size=\"+2\" color=\"red\"><b>Mapa de $MAP_NAME_LONG</b></font><br>\n";
    }
    else {
    if ($blue_points > $red_points) {
        print $map  "<font size=\"+2\" color=\"blue\"><b>Mapa de $MAP_NAME_LONG</b></font><br>\n";
    }
    else {
        print $map  "<font size=\"+2\" color=\"green\"><b>Mapa de $MAP_NAME_LONG</b></font><br>\n";
    }
    }
    
    print $map "<table>\n";
    print $map "<tr class=first><td colspan=8 align=center><h3>Puntuaci&oacute;n del Mapa</h3></td></tr>\n";   
    print $map "<tr class=first><td  align=center valign=middle><nowrap><img src=\"../images/luftwaffe_logo.gif\" width=40 height=40/></td>";
    print $map "<td>&nbsp;&nbsp;</td><td><b>$blue_points</b></nowrap></td>";
    print $map "<td>&nbsp;&nbsp;</td><td  align=center valign=middle><img src=\"../images/ws_logo.gif\" border=0 width=40 height=40/></td>";
    print $map "<td>&nbsp;&nbsp;</td><td><b>$red_points</b></nowrap></td>"; 
    print $map "</tr>";
    print $map "</table>\n";
}

## @Heracles@20170815
## Campaign map time and weather info
sub print_time_and_weather($$$$$$$$) {
    my $map = shift @_;
    my $sta = shift @_;
    my $map_vday = shift @_;
    my $mission_of_day = shift @_;
    my $hora = shift @_;
    my $minutos = shift @_;
    my $tipo_clima_spa = shift @_;
    my $nubes = shift @_;

    print $map  "<br><br><font size=\"+1\"> Dia de campa&ntilde;a <b>$map_vday</b> de <b>$CAMPAIGN_MAX_VDAY</b><br>\n";
    print $map  "<font size=\"+1\">Siguiente misi&oacute;n del d&iacute;a:<b> $mission_of_day / $MIS_PER_VDAY</b><br>\n";
    print $sta   "<b>Siguiente misi&oacute;n del d&iacute;a:</b> $mission_of_day / $MIS_PER_VDAY - $hora h $minutos m.<br>\n";

    print $map  "$hora h $minutos m - Clima: $tipo_clima_spa  - Nubes a $nubes metros. </font><br><br>\n\n";
    print $sta   "<b>Previsi&oacute;n:</b> $tipo_clima_spa  - Nubes a $nubes metros. <br><br>\n\n";

}

## @Heracles@20170815
## Campaign map headquarters info
sub print_headquarter($$) {

    my $map = shift @_;
    my $sta = shift @_;

    print_map_and_sta($map, $sta, "<table border=1 ><tr>");

    my $red_sua_capacity = 0;
    my $blue_sua_capacity = 0;    
    my $red_initial = 0;
    my $blue_initial = 0;
    my $red_stock = 0;
    my $blue_stock = 0;
    my $red_losts = 0;
    my $blue_losts = 0;
    ($red_sua_capacity, $blue_sua_capacity, $red_initial, $blue_initial, $red_stock, $blue_stock, $red_losts, $blue_losts) = calc_stocks_plane();
    
    my $red_plane_supply = 0;
    my $blue_plane_supply = 0;    
    ($red_plane_supply, $blue_plane_supply) = calc_sum_plane_supply($red_sua_capacity, $blue_sua_capacity);
    
    my $blue_sectors = 0;
    my $red_sectors = 0;
                             
    ($red_sectors, $blue_sectors, $red_supply_city, $blue_supply_city) = calc_sectors_owned();

    $red_sua_capacity = sprintf("%d", $red_sua_capacity * 100);
    $blue_sua_capacity = sprintf("%d", $blue_sua_capacity * 100);

    print_headquarter_for_army($map, $sta, "rojo", $RED_HQ, $red_stock, $red_losts, $VDAY_PRODUCTION_RED, $red_sua_capacity, $red_plane_supply, $red_sectors, $red_supply_city);
    print_headquarter_for_army($map, $sta, "azul", $BLUE_HQ, $blue_stock, $blue_losts, $VDAY_PRODUCTION_BLUE, $blue_sua_capacity, $blue_plane_supply, $blue_sectors, $blue_supply_city);    

    print_map_and_sta($map, $sta, "</tr></table><br><br>\n");

}

## @Heracles@20170815
## Campaign map headquarters info for army
sub print_headquarter_for_army($$$$$$$$$$$) {
    my $map = shift @_;
    my $sta = shift @_;
    my $army_color = shift @_;
    my $headquarter = shift @_;
    my $stock = shift @_;
    my $losts = shift @_;
    my $daily_production = shift @_;
    my $capacity = shift @_;
    my $plane_supply = shift @_;
    my $sectors = shift @_;
    my $supply_city = shift @_;

    print_map_and_sta($map, $sta, "<td valign=\"top\">\n");
    
    ## informe de capacidad de producción
    print_map_and_sta($map, $sta, "<b><u>Cuartel general $army_color</u></b><br><br>\n");
    print_map_and_sta($map, $sta, "<table>\n<col width=\"130\">\n<tr><td>Ciudad C.G.:</td><td align=\"right\"><b>$headquarter</b></td></tr>\n");
    print_map_and_sta($map, $sta, "</table><br>\n");    
    print_map_and_sta($map, $sta, "<b>Producci&oacute;n de aviones: </b><br>\n");
    print_map_and_sta($map, $sta, "<table>\n<col width=\"150\"> <col width=\"50\">\n");
    print_map_and_sta($map, $sta, "<tr><td>Existencias:</td><td align=\"right\"><b>$stock</b></td></tr>\n");
    print_map_and_sta($map, $sta, "<tr><td>P&eacute;rdidas:</td><td align=\"right\"><b>$losts</b></td></tr>\n");
    print_map_and_sta($map, $sta, "<tr><td>Producci&oacute;n diaria:</td><td align=\"right\"><b>$daily_production</b></td></tr>\n");
    print_map_and_sta($map, $sta, "</table><br>\n");
    
    ## informe de capacidad de suministro a aeródromos
    print_map_and_sta($map, $sta, "<b>Suministro a aer&oacute;dromo: </b><br>\n");

    print_map_and_sta($map, $sta, "<table>\n<col width=\"150\"> <col width=\"50\">\n");
    print_map_and_sta($map, $sta, "<tr><td>Capacidad SUA (%):</td><td align=\"right\"><b>$capacity</b></td></tr>\n");
    
    print_map_and_sta($map, $sta, "<tr><td>Por avi&oacute;n SUA (%):</td><td align=\"right\"><b>$plane_supply</b></td></tr>\n");    
    print_map_and_sta($map, $sta, "</table><br>\n");

    ## informe de capacidad de suministro a ciudades
    print_map_and_sta($map, $sta, "<b>Suministro a ciudad: </b><br>\n");
    print_map_and_sta($map, $sta, "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Sectores (%):</td><td align=\"right\"><b>$sectors</b></font></td></tr>\n");
    print_map_and_sta($map, $sta, "<tr><td>Por avi&oacute;n SUM (%):</td><td align=\"right\"><b>$supply_city</b></td></tr>\n");
    print_map_and_sta($map, $sta, "</table><br><br></td>");
}

## @Heracles@20170815
## Campaign map plane inventory
sub print_plane_inventory($$$) {

    my $map = shift @_;
    my $sta = shift @_;
    my $log = shift @_;

    if (not $INVENTARIO) {
        exit(0);
    }

    if (!open (FLIGHTS, "<$FLIGHTS_DEF")) {
        print "$big_red ERROR Can't open File $FLIGHTS_DEF: $! on get_flight()\n";
        print "Please NOTIFY this error.\n";
        print &print_end_html();
        print $log " Pid $$ : " .scalar(localtime(time)) ." ERROR: Can't open File $FLIGHTS_DEF: $! on get_flight()\n\n";
        exit(0);
    }       
    
    print_map_and_sta($map, $sta, "<table border=1 ><tr>");

    ($red_task_stock, $red_stock_out) = print_plane_inventory_for_army($map, $sta, FLIGHTS, "rojos", "IR", "1");
    ($blue_task_stock, $blue_stock_out) = print_plane_inventory_for_army($map, $sta, FLIGHTS, "azules", "IA", "2");

    print_map_and_sta($map, $sta, "</tr></table><br><br>\n");
    close (FLIGHTS);
    
    my $albaran=$PATH_DYNAMIC_TXT . "/" . "albaran.txt";
    if ($PRODUCCION) {
        if (open (ALB, "<$albaran")) {
        seek ALB, 0, 0;
        while (<ALB>) {
            print $map;
            print $sta;
        }
        close (ALB);
        }               
    }

    return ($red_task_stock, $red_stock_out, $blue_task_stock, $blue_stock_out);
}

## @Heracles@20170815
## Campaign map plane inventory for army
sub print_plane_inventory_for_army($$$$$$) {

    my $map = shift @_;
    my $sta = shift @_;
    my $flights = shift @_;
    my $army_color = shift @_;
    my $flight_pattern = shift @_;
    my $army_pattern = shift @_;

    my %task_stock = (
        BA=>0,
        EBA=>0,
        SUM=>0,
        ESU=>0,
        BD=>0,
        EBD=>0,
        ET=>0,
        AT=>0,
        I=>0
    );
  
    print_map_and_sta($map, $sta, "<td valign=\"top\">\n");

    ## informe de inventario de aviones
    print_map_and_sta($map, $sta, "<b>Inventario de aviones $army_color:</b><br>\n");
    print_map_and_sta($map, $sta, "<table><tr><td>Modelo</td><td>Tipo</td><td>Existencias</td><td>P&eacute;rdidas</td></tr>");
        
    seek $flights, 0, 0;
    while (<$flights>) {
        if ($_ =~ m/^\Q$flight_pattern\E,([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),/) 
        {
            my $plane_model = $1;
            my $plane_number = $3;
            my $plane_lost = $5;
            
            print_map_and_sta($map, $sta, "<tr><td> $plane_model </td><td>");
            
            my $line_back = tell $flights;
            seek $flights,0,0;
            while (<$flights>){
                if ($_ =~ m/^\Q$army_pattern\E,[^,]+,$plane_model,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+:([^,]+),/)
                {
                    print_map_and_sta($map, $sta, "$1,");
                    $task_stock{$1} += $plane_number;
                }
            }
            
            my $color = "green";
            if ($plane_number <= 10) 
            { 
                $color = "red";
            } 

            print_map_and_sta($map, $sta, "</td><td align=\"right\"><font color=\"$color\"><b>$plane_number</b></font></td>");            
            print_map_and_sta($map, $sta, "<td align=\"right\"><font color=\"black\">$plane_lost</td><td></tr>\n");        
            seek $flights, $line_back, 0;
        }
    }
    
    if ($task_stock{BD} == 0 || $task_stock{EBD} == 0 || $task_stock{ET} == 0 || $task_stock{AT} == 0 || $task_stock{I} == 0) 
    {
        $stock_out = 1;
    }
    
    print_map_and_sta($map, $sta, "</table><br><br>\n");
    print_map_and_sta($map, $sta, "<br><br>\n");
    print_map_and_sta($map, $sta, "</td>");

    return (\%task_stock, $stock_out);
}

## @Heracles@20170815
## Campaign map airfield damage info
sub print_airfield_damage($$$) {
    
    my $map = shift @_;
    my $sta = shift @_;
    my $geo = shift @_;
    
    print_map_and_sta($map, $sta, "<table border=1 ><tr>");
    
    ($cg_red_bases, $af_red_colapsed) = print_airfield_damage_for_army($map, $sta, $geo, "rojos", 1);
    ($cg_blue_bases, $af_blue_colapsed) = print_airfield_damage_for_army($map, $sta, $geo, "azules", 2);    

    print_map_and_sta($map, $sta, "</tr></table><br><br>\n");

    return ($cg_red_bases, $af_red_colapsed, $cg_blue_bases, $af_blue_colapsed);
}

## @Heracles@20170815
## Campaign map airfield damage info for army
sub print_airfield_damage_for_army($$$$$) {

    my $map = shift @_;
    my $sta = shift @_;
    my $geo = shift @_;
    my $army_color = shift @_;
    my $army = shift @_;

    print_map_and_sta($map, $sta, "<td valign=\"top\">\n");
    print_map_and_sta($map, $sta, "<b>Aer&oacute;dromos $army_color: </b><br>\n");
    print_map_and_sta($map, $sta, "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Aer&oacute;dromo</td><td>Da&ntilde;o</td></tr>\n");

    ## variables para control de colapso de AF
    my $af_num=0;
    my $af_colapsed=0;
    
    ## Control de bases de CG rojo
    @cg_bases=();
    $cg_num_bases=0;
    ($cg_num_bases, @cg_bases) = get_cg_bases($army);
    
    ## Capacidad aerea
    my $air=0;
    my $air_pot=0;
    
    seek $geo, 0, 0;
    while(<$geo>) 
    { 
        if ($_ =~ m/^AF[0-9]+,([^,]+),.*,([^,]+):\Q$army\E/)
        {
            $af_num++;
            my $afname=$1;
            foreach my $af_cg (@cg_bases) 
            {
                if ($af_cg eq $afname) 
                {
                    $afname .= " *CG*";
                    last;
                }       
            }               
            my $afdam=$2;
            $air = ($afdam < 80) ? $air + (80 - $afdam) : $air;
            $air_pot += 80;
            if ($afdam !~ m/\./) 
            {
                $afdam.=".00";
            }
            if ($afdam !~ m/\.[0-9][0-9]/) 
            {
                $afdam.="0";
            }

            my $color = "green";
            if ($afdam>=80) 
            {
                $af_colapsed++;
                $color = "red";
            }
            $afdam="&nbsp;".$afdam;
            print_map_and_sta($map, $sta, "<tr><td> $afname </td><td align=\"right\"> &nbsp;&nbsp;&nbsp;<font color=\"$color\"><b>$afdam%</b></font></td></tr>\n");
        }
    }
    
    my $af_total_colapsed = 0;
    if ($af_num == $af_colapsed) 
    {
        $af_total_colapsed = 1;
    }
    
    my $capacidad_percentage =  ($air / $air_pot) * 100.0;
    my $capacidad = sprintf("%.2f", $capacidad_percentage); 
    print_map_and_sta($map, $sta, "</table><br><br>\n");
    print_map_and_sta($map, $sta, "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td><b>Capacidad aerea: </b></td><td align=\"right\"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color=\"black\">$capacidad%</font></td></tr>\n");
    print_map_and_sta($map, $sta, "</table><br><br></td>");

    return (\@cg_bases, $af_total_colapsed);
}

## @Heracles@20170816
## Campaign map city damage info
sub print_city_damage($$$) {

    my $map = shift @_;
    my $sta = shift @_;
    my $geo = shift @_;

    print_map_and_sta($map, $sta, "<table border=1 ><tr>");

    $red_hq_captured = print_city_damage_for_army($map, $sta, $geo, "rojas", 1);
    $blue_hq_captured = print_city_damage_for_army($map, $sta, $geo, "azules", 2);

    print_map_and_sta($map, $sta, "</tr></table>\n");

    return ($red_hq_captured, $blue_hq_captured);
}

## @Heracles@20170816
## Campaign map city damage info for army
sub print_city_damage_for_army($$$$$) {

    my $map = shift @_;
    my $sta = shift @_;
    my $geo = shift @_;
    my $army_color = shift @_;
    my $army = shift @_;

    print_map_and_sta($map, $sta, "<td valign=\"top\">\n");
    print_map_and_sta($map, $sta, "<b>Estado de las ciudades $army_color:</b><br>\n");
    print_map_and_sta($map, $sta, "<table><tr><td>Ciudad</td><td>Da&ntilde;o</td><td>Suministro</td></tr>");

    seek $geo, 0, 0;
    while(<$geo>) 
    {
        if ($_ =~ m/^(CT[0-9]+),([^,]+),.*,([^,]+),([^,]+):\Q$army\E/)
        {
            my $color = "green";
            if ($3 >= $CITY_DAM) 
            {
                $color = "red";
            }

            print_map_and_sta($map, $sta, "<tr><td> $2 </td><td><font color=\"$color\"><b> $3% </b></font></td><td> $4 Km.</td></tr>\n");
    
            my $hq_captured = 0;
            if ( $2 eq get_hq($army) ) 
            { 
                $hq_captured = 1;
            }
        }
    }

    print_map_and_sta($map, $sta, "</table><br><br></td>");

    return $hq_captured;
}

## @Heracles@20170816
## Campaign map page creation (old make_attack_page())
sub print_map_page($$$$) {
    
    my $geo = shift @_;
    my $log = shift @_;
    my $weather_for_next_mission = shift @_; #allowed values 0 or 1
    my $rep_nbr = shift @_;

    ($map_vday, $mission_of_day, $hora, $minutos, $tipo_clima_spa, $nubes) = compute_time_and_weather($weather_for_next_mission, $log, $rep_nbr);

    my $MAP_FILE= $PATH_DYNAMIC_MAP . "/" . "mapa.html";
    my $Status= $PATH_DYNAMIC_TXT . "/" . "Status.txt";

    open (MAPA,">$MAP_FILE")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA MAPA</font>";
    open (STA,">$Status")|| print "<font color=\"ff0000\"> ERROR: NO SE PUEDE ACTUALIZAR LA PAGINA SRS</font>";

    print_map_and_points(MAPA);    
    print_time_and_weather(MAPA, STA, $map_vday, $mission_of_day, $hora, $minutos, $tipo_clima_spa, $nubes);
    print_headquarter(MAPA, STA);

    ($red_task_stock, $red_stock_out, $blue_task_stock, $blue_stock_out) = print_plane_inventory(MAPA, STA, $log);
    ($cg_red_bases, $af_red_colapsed, $cg_blue_bases, $af_blue_colapsed) = print_airfield_damage(MAPA, STA, $geo);
    ($red_hq_captured, $blue_hq_captured) = print_city_damage(MAPA, STA, $geo);

    print_map_and_sta(MAPA, STA, "<p><strong>Mapa del Frente:</strong><br>");

    open (IMAP,"<$IMAP_DATA");
    while(<IMAP>)
    {
        print MAPA;
    }
    close(IMAP);

    my $footer = `php ../dz_page_footer.php`;
    print MAPA $footer;

    close (MAPA);
    close (STA);

    return ($red_task_stock, $red_stock_out, $blue_task_stock, $blue_stock_out, $cg_red_bases, $af_red_colapsed, $cg_blue_bases, $af_blue_colapsed, $red_hq_captured, $blue_hq_captured);
}