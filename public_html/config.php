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

    $PATH_DYNAMIC_CONTENT = "/var/www/html/public_html/cgi-bin/current_map";
    $PATH_DYNAMIC_TXT     = $PATH_DYNAMIC_CONTENT;
    $RELATIVE_DYNAMIC_REP = "/cgi-bin/current_map/rep";    
    $RELATIVE_DYNAMIC_FRONT = "/cgi-bin/current_map";     
    $RELATIVE_DYNAMIC_MAP = "/cgi-bin/current_map";                
} else {
	// *******************    PRODUCTION VARIABLES - EDIT AS NEEDED  *************
    $database="s03e18df_dangerzone";
    $db_user="s03e18df_badc";
    $db_upwd='Phoenix';
    $path_to_cgi_bin="/home/s03e18df/public_html/dangerzone/cgi-bin";
    $campanya="ESTE";
    $mapa="Bessarabia. 1941";

    $PATH_DYNAMIC_CONTENT = $PATH_TO_WEBROOT;
    $PATH_DYNAMIC_TXT     = $CGI_BIN_PATH;
    $RELATIVE_DYNAMIC_REP = "/rep";    
    $RELATIVE_DYNAMIC_FRONT = "/images";    
    $RELATIVE_DYNAMIC_MAP = "";            
}
?>