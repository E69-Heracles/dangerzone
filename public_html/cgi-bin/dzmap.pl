require "config.pl";
require "dztools.pl";

sub calc_map_points();
sub print_map_and_sta($$$);
sub calc_stocks_plane();
sub get_sua_capacity($);
sub set_sua_capacity($$);
sub calc_sum_plane_supply($$);
sub calc_sectors_owned();
sub print_headquarter_for_army($$$$$$$$$$$);

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
    print $map "<tr class=first><td  align=center valign=middle><nowrap><img src=\"images/luftwaffe_logo.gif\" width=40 height=40/></td>";
    print $map "<td>&nbsp;&nbsp;</td><td><b>$blue_points</b></nowrap></td>";
    print $map "<td>&nbsp;&nbsp;</td><td  align=center valign=middle><img src=\"images/ws_logo.gif\" border=0 width=40 height=40/></td>";
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
    print $sta   "<b>Siguiente misión del día:</b> $mission_of_day / $MIS_PER_VDAY - $hora h $minutos m.<br>\n";

    print $map  "$hora h $minutos m - Clima: $tipo_clima_spa  - Nubes a $nubes metros. </font><br><br>\n\n";
    print $sta   "<b>Previsión:</b> $tipo_clima_spa  - Nubes a $nubes metros. <br><br>\n\n";

}

## @Heracles@20170815
## Campaign map headquarters info
sub print_headquarter($$) {

    my $map = shift @_;
    my $sta = shift @_;

    print_map_and_sta($map, $sta, "<table border=1 ><tr>");

    my $red_stock = 0;
    my $blue_stock = 0;
    my $red_losts = 0;
    my $blue_losts = 0;
    ($red_stock, $blue_stock, $red_losts, $blue_losts) = calc_stocks_plane();
    
    my $red_capacity=get_sua_capacity(1);
    if ($red_capacity eq "-") {
        $red_capacity = $red_stock;
        set_sua_capacity ($red_stock, 1);
    }

    my $red_plane_supply = 0;
    my $blue_plane_supply = 0;    
    ($red_plane_supply, $blue_plane_supply) = calc_sum_plane_supply($red_stock, $blue_stock);
    
    my $blue_sectors = 0;
    my $red_sectors = 0;
                             
    ($red_sectors, $blue_sectors, $red_supply_city, $blue_supply_city) = calc_sectors_owned();
    
    my $blue_capacity=get_sua_capacity(2);
    if ($blue_capacity eq "-") {
    $blue_capacity = $blue_stock;
    set_sua_capacity ($blue_stock, 2);
    }       

    print_headquarter_for_army($map, $sta, "rojo", $RED_HQ, $red_stock, $red_losts, $VDAY_PRODUCTION_RED, $red_capacity, $red_plane_supply, $red_sectors, $red_supply_city);
    print_headquarter_for_army($map, $sta, "azul", $BLUE_HQ, $blue_stock, $blue_losts, $VDAY_PRODUCTION_BLUE, $blue_capacity, $blue_plane_supply, $blue_sectors, $blue_supply_city);    

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

    print_map_and_sta($map, $sta, "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Capacidad SUA (%):</td><td align=\"right\"><b>$capacity</b></td></tr>\n");
    
    print_map_and_sta($map, $sta, "<tr><td>Por avi&oacute;n SUA (%):</td><td align=\"right\"><b>$plane_supply</b></td></tr>\n");    
    print_map_and_sta($map, $sta, "</table><br>\n");

    ## informe de capacidad de suministro a ciudades
    print_map_and_sta($map, $sta, "<b>Suministro a ciudad: </b><br>\n");
    print_map_and_sta($map, $sta, "<table>\n<col width=\"150\"> <col width=\"50\">\n<tr><td>Sectores (%):</td><td align=\"right\"><b>$sectors</b></font></td></tr>\n");
    print_map_and_sta($map, $sta, "<tr><td>Por avi&oacute;n SUM (%):</td><td align=\"right\"><b>$supply_city</b></td></tr>\n");
    print_map_and_sta($map, $sta, "</table><br><br></td>");
}
