#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";


# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------



    print "Set-Cookie: ";
    print "badc_images=1; expires=".$cookie_expire."; path=/\n";

    print &PrintHeader;
    print <<TOP;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
      <META HTTP-EQUIV="PRAGMA" CONTENT="no-cache">
      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      <link rel="stylesheet" type="text/css" href="/badc.css">
      <title>Allowed german images.</title>
</head>
<body>


<div id="hoja">

  <a href="/index.html"><img border="0" src="/images/logo.gif"  alt="regresar" style="margin-left: 40px; margin-top: 0px" ></a>
  <br><br><br><br>

<div id="central">
TOP
    ; # emacs related
    
    print "<br><br>German Images <b>allowed</b>.<br>\n";
    print "If you like to disable german images, use link or just delete your cookies.<br><br>\n"; 

    print "<br><br></div><br></div>\n";
    print &HtmlBot;
    exit (0);


# useless lines to avoid used only once messages 
$cookie_expire=$cookie_expire;
