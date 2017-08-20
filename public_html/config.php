<?php

$environment = getenv('ENVIRONMENT');

if ($environment == "DEV") {
    // *******************   DEVELOPMENT VARIABLES - DON'T EDIT  *****************
    $database="badc";
    $db_user="badc_user";
    $db_upwd='badc_password';
    $path_to_cgi_bin="/var/www/html/public_html/cgi-bin";
    $campanya="ESTE";
    $mapa="Bessarabia. 1941";
} else {
	// *******************    PRODUCTION VARIABLES - EDIT AS NEEDED  *************
    $database="s03e18df_dangerzone";
    $db_user="s03e18df_badc";
    $db_upwd='Phoenix';
    $path_to_cgi_bin="/home/s03e18df/public_html/dangerzone/cgi-bin";
    $campanya="ESTE";
    $mapa="Bessarabia. 1941";
}
?>