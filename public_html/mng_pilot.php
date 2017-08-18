<?php   
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php"); 
?>

<br>
<div id="central">

<h3>Gestión de Pilotos</h3> 

<table border=0 width=835>
<tr><td>
<p>Para registrarte como piloto tienes que rellenar el formulario "Registrar". Necesitarás proporcionar 
	tu nombre (Nick del HL) y una contraseña personal. Además, puedes introducir tu email y un link a una 
imagen avatar. Cuando lo hayas hecho, podrás editar tu perfil, unirte a un Escuadrón, crear uno propio, etc.</p>

<p>Ten en cuenta que si ya has volado alguna misión de  Danger Zone estarás registrado automaticamente 
	como piloto. La contraseña que se habrá asignado es tu nombre del HL (coincidencia exacta). Si éste es 
	tu caso, sáltate el registro y dirígete a "Editar Piloto" para que puedas cambiar tu contraseña e introducir 
la información sobre tu email y tu avatar. Después ya puedes unirte o crear escuadrones.</p>
</td></tr></table>
	<br><br>
<table class=rndtable_nohover width=835>
<tr><td align=center><b>
<a href="pilot_reg.php">Registrar Piloto</a> |
<a href="join_sqd.php">Unirse a Escuadrón</a> |
<a href="leave_squadron.php">Dejar Escuadrón</a> |
<a href="/cgi-bin/pilot_edit.pl">Editar Piloto</a> |
<a href="delete_pilot.php">Borrar Piloto</a> |
<a href="find_pilot.php">Ver Perfil</a>
</b></td></tr></table>

<?php 
include ("./dz_page_footer.php");
?>



