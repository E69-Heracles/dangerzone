<?php

$ua="Unknown";
$ua = $_SERVER['HTTP_USER_AGENT'];

// UA ALLOW
// By: JG10r_Dutertre - ignacio_xxi@hotmail.com

// based on UA BLOCK
// By: Christopher Lover - webmaster@icehousedesigns.com
// http://www.icehousedesigns.com
// This script is freeware. I accept no responsibility for
// damage it may cause (which should be none).
// This script can be freely modified, as long as this
// header is included.
// Place an include ("/path/to/block.php"); //
// at the TOP of your HTML documents


    //List user-agents below you wish to allow
    $browser = array ("Mozilla","Opera","Lynx","Avant","W3C_Validator");

     $punish = 1; // default to deny
     foreach ($browser as $valid) {
         if (stristr ($ua, $valid)) {
               $punish = 0;
		break;
          }
     }

    if ($punish) {

        // Print custom page
        echo "
<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
<html>
  <head>
    <META http-equiv=Content-Type content=\"text/html; charset=iso-8859-1\">
    <title>Acceso Denegado - Access Denied.</title>
  </head>
<body bgcolor=\"#AAAA00\">
<pre>



</pre>
<center>
<font color=\"cc0000\" size=\"+1\"><b><u>ERROR: $ua </u></b></font> 
<br><br>
  <table border=\"0\">
	<col width=\"500\">
    <tr><td><hr size=\"1px\"></td></tr>
    <tr><td><font color=\"#000066\">
    El software que usted est&aacute; usando para acceder a nuestro sitio web no est&aacute; permitido. Algunos ejemplos de estos son programas recolectores de direcciones de correo electr&oacute;nico y programas que copian sitios web a su disco duro. Si usted cree que obtuvo este mensaje por error, por favor env&iacute;e un menaje de coreo electr&oacute;nico al adminsitrador de este sitio web. </font><b>Gracias</b>.</td></tr>
    <tr><td><hr size=\"1px\"></td></tr>

    <tr><td>&nbsp;</td></tr>

    <tr><td><hr size=\"1px\"></td></tr>
    <tr><td><font color=\"#000066\">
    The software you are using to access our website is not allowed. Some examples of this are e-mail harvesting programs and programs that will copy websites to your hard drive. If you feel you have gotten this message in error, please send an e-mail addressed to admin. </font><b>Thanks</b>.</td></tr>
    <tr><td><hr size=\"1px\"></td></tr>

  </table>
</center>
  <BR><BR><BR><BR>
</body>
</html>";
exit;
    }
?>