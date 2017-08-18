<?php   
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br>
<div id="central">

<h3>Gestión de Escuadrones</h3> 

<table border=0 width=835>
<tr><td>
<p>Para registrar un escuadrón debes estar registrado previamente como piloto en la Danger Zone. Cuando cumplas ese requisito sigue los siguientes pasos:</p>

<ul>
	<li>Pide un código de autorización en el foro.
	<li>Rellena el formulario en el menú: "Escuadrones -> Registrar"
	<li>El menú "Editar Escuadrón" permite cambiar los datos del Escuadrón (solo para el CO)
	<li>El Menú "Administrar Escuadrón" permite llevar a cabo tareas administrativas, como aceptar solicitudes de pilotos (CO y XO).
</ul>
</td></tr></table>
	<br>
<table class=rndtable_nohover width=835>
<tr><td align=center><b>
<a href="sqd_reg.php">Registrar Escuadrón</a> |
<a href="sqd_admin.php">Administrar Escuadrón</a> |
<a href="/cgi-bin/sqd_edit.pl">Editar Escuadrón</a> |
<a href="find_sqd.php">Ver Perfil</a>
</b></td></tr></table>

<?php 
include ("./dz_page_footer.php");
?>