
$|=1; # hot output

sub print_start_html
{
    return <<END_OF_TEXT;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Danger Zone</title>
	<META HTTP-EQUIV="PRAGMA" CONTENT="no-cache">
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">	
	<link href="/css/luftwaffe.css" rel="stylesheet" type="text/css" /> 
	<script type="text/javascript" src="/js/jquery.js"></script> 
	<script type="text/JavaScript" src="/js/curvycorners.src.js"></script> 
	<script type="text/JavaScript" src="/js/dz_menu.js"></script>  

</head>
<body>
	<div id="dhtmltooltip"></div>
	<table  width="100%" cellpadding="0" cellspacing="0" border=0 height="100%">
	<tr height="30" class="header">
		<td align="center">
			<table  border=0 cellpadding="0" cellspacing="0" width="835px">
			<tr height="40" style="text-align:center">
					<td width="224px"><a href="#" id="menu-1" class="menu">Todo lo que hay leer<br/>sobre Danger Zone</a>
						<div id="submenu-1" class="menu-text">
							<nobr><span  class="submenu-text">
							<a href="/index.html">Home</a> |
							<a href="/manual.php">Manual</a> |
							<a href="/foro/index.php" target="main">Foro General</a> |
							<a href="/foro/index.php?board=6.0" target="main">Foro Aliado</a> |
							<a href="/foro/index.php?board=7.0" target="main">Foro del Eje</a> |
							<a href="/credits.php">Creditos</a> 
							</span></nobr>
						</div></td>
					<td width="1px"><img src="/images/menu_separator.gif"></td>
					<td width="208px"><a href="#" id="menu-2" class="menu">Para ver el estado de<br/>la campaña actual</a>
						<div id="submenu-2" class="menu-text">
							<nobr><span  class="submenu-text">
							<a href="/mapa.html">Mapa del Frente</a> |
							<a href="/last_mis.php">Misiones</a> |
							<a href="/all_sqds.php">Escuadrones</a> |
							<a href="/all_pilots.php">Pilotos</a> |
							<a href="/alive_pilots.php">Pilotos Vivos</a>
							</span></nobr>
						</div></td>
					<td width="1px"><img src="/images/menu_separator.gif"></td>
					<td width="204px"><a href="#" id="menu-3" class="menu">Alístate en la campaña<br/>o plánifica misiones</a>
						<div id="submenu-3" class="menu-text">
							<nobr><span  class="submenu-text">
							<a href="/mng_pilot.php">Gestión Piloto</a> |
							<a href="/mng_sqd.php">Gestión Escuadrón</a> |
							<a href="/create.php">Generar Misión</a> |
							<a href="/rep_input.php">Reportar Misión</a>
							</span></nobr>
						</div></td>
					<td width="1px"><img src="/images/menu_separator.gif"></td>
					<td width="196px"><a href="#" id="menu-4" class="menu">Unete al Teamspeak<br/>y charla con nosotros</a>
						<div id="submenu-4" class="menu-text">
							<script language="javascript" type="text/javascript" charset="iso-8859-1" src="http://www.tsviewer.com/ts_viewer_pur.php?ID=103546&bg=transparent&type=8f8f8f&type_size=10&type_family=4&info=0&channels=1&users=1&js=1&type_s_color=0c18fa&type_s_weight=bold&type_s_style=normal&type_s_variant=normal&type_s_decoration=none&type_s_color_h=525284&type_s_weight_h=bold&type_s_style_h=normal&type_s_variant_h=normal&type_s_decoration_h=underline&type_i_color=000000&type_i_weight=normal&type_i_style=normal&type_i_variant=normal&type_i_decoration=none&type_i_color_h=525284&type_i_weight_h=normal&type_i_style_h=normal&type_i_variant_h=normal&type_i_decoration_h=underline&type_c_color=0a39d1&type_c_weight=normal&type_c_style=normal&type_c_variant=normal&type_c_decoration=none&type_c_color_h=c41a0e&type_c_weight_h=normal&type_c_style_h=normal&type_c_variant_h=normal&type_c_decoration_h=underline&type_u_color=000000&type_u_weight=normal&type_u_style=normal&type_u_variant=normal&type_u_decoration=none&type_u_color_h=525284&type_u_weight_h=normal&type_u_style_h=normal&type_u_variant_h=normal&type_u_decoration_h=none"></script>
						</div></td>
			</tr>
			<tr>
				<td colspan="7"><img src="/images/header.gif"/></td>
			</tr>
		</table>
	</td>	
	</tr>
	<tr class="main">
		<td align="center" valign=top>
			<br/><br/>
			<div id="hoja">
				<div id="central"> 
END_OF_TEXT
}



sub print_end_html
{
    return <<END_OF_TEXT2;
</div></div>
			<br/><br/></td></tr>
		  <tr>
				<td colspan="3" class="footer" height="30px" align="center">
					<span style="font-size:9px">Footer que te kagas, con <img src="/images/footer_empe.jpg" valign="middle">opciones y un Empecinado monisimo.</span> 
				</td>
			</tr>		
			</table>
		</td>
	</tr>
	</table>
</body>
</html>        
END_OF_TEXT2
}
