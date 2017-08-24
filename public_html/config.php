<?php

$environment = getenv('ENVIRONMENT');

if ($environment == "DEV") {
    // *******************   DEVELOPMENT VARIABLES - DON'T EDIT  *****************
    $database="badc";
    $db_user="badc_user";
    $db_upwd='badc_password';
    
    $campanya="ESTE";
    $mapa="Bessarabia. 1941";

    $PATH_DYNAMIC_CONTENT = "/var/www/html/public_html/campaign";
    $PATH_DYNAMIC_TXT     = $PATH_DYNAMIC_CONTENT;
    $RELATIVE_DYNAMIC_REP = "/campaign/rep";    
    $RELATIVE_DYNAMIC_FRONT = "/campaign";     
    $RELATIVE_DYNAMIC_MAP = "/campaign";                

} else {
	// *******************    PRODUCTION VARIABLES - EDIT AS NEEDED  *************
    $database="s03e18df_dangerzone";
    $db_user="s03e18df_badc";
    $db_upwd='Phoenix';

    $campanya="ESTE";
    $mapa="Bessarabia. 1941";

    $PATH_DYNAMIC_CONTENT = $PATH_TO_WEBROOT;
    $PATH_DYNAMIC_TXT     = $CGI_BIN_PATH;
    $RELATIVE_DYNAMIC_REP = "/rep";    
    $RELATIVE_DYNAMIC_FRONT = "/images";    
    $RELATIVE_DYNAMIC_MAP = "";            
}

$path_to_cgi_bin=$PATH_DYNAMIC_TXT;
?>