<?php   
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php"); 
?>

<br>
<div id="central">

<h3>Gesti�n de Pilotos</h3> 

<table border=0 width=835>
<tr><td>
<p>Para registrarte como piloto tienes que rellenar el formulario "Registrar". Necesitar�s proporcionar 
	tu nombre (Nick del HL) y una contrase�a personal. Adem�s, puedes introducir tu email y un link a una 
imagen avatar. Cuando lo hayas hecho, podr�s editar tu perfil, unirte a un Escuadr�n, crear uno propio, etc.</p>

<p>Ten en cuenta que si ya has volado alguna misi�n de  Danger Zone estar�s registrado automaticamente 
	como piloto. La contrase�a que se habr� asignado es tu nombre del HL (coincidencia exacta). Si �ste es 
	tu caso, s�ltate el registro y dir�gete a "Editar Piloto" para que puedas cambiar tu contrase�a e introducir 
la informaci�n sobre tu email y tu avatar. Despu�s ya puedes unirte o crear escuadrones.</p>
</td></tr></table>
	<br><br>
<table class=rndtable_nohover width=835>
<tr><td align=center><b>
<a href="pilot_reg.php">Registrar Piloto</a> |
<a href="join_sqd.php">Unirse a Escuadr�n</a> |
<a href="leave_squadron.php">Dejar Escuadr�n</a> |
<a href="/cgi-bin/pilot_edit.pl">Editar Piloto</a> |
<a href="delete_pilot.php">Borrar Piloto</a> |
<a href="find_pilot.php">Ver Perfil</a>
</b></td></tr></table>

<?php 
include ("./dz_page_footer.php");
?>



