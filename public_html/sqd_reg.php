<?php  
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>

<br><br><br>

<form method="post" action="/cgi-bin/sqd_reg.pl">
  <table>
    <tbody>
      <tr>
        <td align="right">Nombre Escuadr&oacute;n * </td>
        <td><input size="60" name="sqdname" type="text"> (Nombre Completo)</td>
      </tr>
      <tr>
        <td align="right">Tag del Escuadr&oacute;n * </td>
        <td><input size="7" name="sqdname8" type="text"> 8 caracteres max. Ejemplo: el Tag de ABC_Pilot
es <b>ABC</b> (sin _) </td>
      </tr>
      <tr>
        <td align="right">Volar en ... * </td>
        <td>
	        <select name="lado">
	        <option value="0">Seleciona ...</option>
	        <option value="1">VVS (Menganos)</option>
	        <option value="2">LW (Fulanos)</option>
	        </select>
        </td>
      </tr>
      <tr>
        <td align="right">Web del Escuadr&oacute;n </td>
        <td><input value="http://example.com" size="80" name="weburl" type="text"></td>
      </tr>
      <tr>
        <td align="right">Logo &nbsp;del Escuadr&oacute;n </td>
        <td><input value="http://example.com/image.gif" size="80" name="logourl" type="text"></td>
      </tr>
      <tr>
        <td align="right">Nick Hyperloby CO * </td>
        <td><input size="20" name="coname" type="text"></td>
      </tr>
      <tr>
        <td align="right">Password CO * </td>
        <td><input size="15" name="copwd" type="password"></td>
      </tr>
      <tr>
        <td align="right">C&oacute;d. Autorizaci&oacute;n * </td>
        <td><input size="15" name="auth" type="text"></td>
      </tr>
      <tr>
        <td colspan="2" align="center">Los Campos marcados con * son obligatorios &nbsp; &nbsp; <input value="Registrar" type="submit"></td>
      </tr>
    </tbody>
  </table>
</form>

<br>
<br>

<?php 
include ("./dz_page_footer.php");
?>
