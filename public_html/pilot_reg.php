<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br><br><br>

<FORM METHOD="POST" ACTION="/cgi-bin/pilot_reg.pl">
<table>
<tr><td align="right">Nick HypperLobby * </td><td><input type="text" size="20" name="hlname"></td></tr>
<tr><td align="right">Contraseña * </td><td><input type="password" size="15" name="pwd1"></td></tr>
<tr><td align="right">Repite Contraseña * </td><td><input type="password" size="15" name="pwd2"></td></tr>
<tr><td align="right">Email &nbsp; </td>
    <td><input type="text" value="your-email@example.com" size="30" name="email"></td></tr>
<tr><td align="right">Avatar image &nbsp; </td>
   <td><input type="text" value="http://www.example.com/avatar.gif" size="50" name="avatar"></td></tr>
<tr><td align="center" colspan="2">Los Campos marcados * son obligatorios &nbsp; &nbsp; 
    <input TYPE="SUBMIT" VALUE="Registrar"></td></tr>
</table>
</FORM>

<br>
<br>

<?php 
include ("./dz_page_footer.php");
?>