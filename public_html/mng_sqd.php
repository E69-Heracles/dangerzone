<?php   
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br>
<div id="central">

<h3>Gesti�n de Escuadrones</h3> 

<table border=0 width=835>
<tr><td>
<p>Para registrar un escuadr�n debes estar registrado previamente como piloto en la Danger Zone. Cuando cumplas ese requisito sigue los siguientes pasos:</p>

<ul>
	<li>Pide un c�digo de autorizaci�n en el foro.
	<li>Rellena el formulario en el men�: "Escuadrones -> Registrar"
	<li>El men� "Editar Escuadr�n" permite cambiar los datos del Escuadr�n (solo para el CO)
	<li>El Men� "Administrar Escuadr�n" permite llevar a cabo tareas administrativas, como aceptar solicitudes de pilotos (CO y XO).
</ul>
</td></tr></table>
	<br>
<table class=rndtable_nohover width=835>
<tr><td align=center><b>
<a href="sqd_reg.php">Registrar Escuadr�n</a> |
<a href="sqd_admin.php">Administrar Escuadr�n</a> |
<a href="/cgi-bin/sqd_edit.pl">Editar Escuadr�n</a> |
<a href="find_sqd.php">Ver Perfil</a>
</b></td></tr></table>

<?php 
include ("./dz_page_footer.php");
?>