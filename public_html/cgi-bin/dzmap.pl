require "dztools.pl";

sub calc_map_points();

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