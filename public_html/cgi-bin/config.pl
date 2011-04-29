#config.pl for BADC campaign. unix stile paths.
# if you use windows, read config_windows.pl


$PATH_TO_WEBROOT      = "/home/s03e18df/public_html/dangerzone";
$CGI_BIN_PATH         = "/home/s03e18df/public_html/dangerzone/cgi-bin";
$CGI_TEMP_UPLOAD_DIR  = "/home/s03e18df/public_html/dangerzone/cgi-bin/tmp";
$DATA_BKUP            = "/home/s03e18df/public_html/dangerzone/cgi-bin/data_bkup";
$MAX_UPLOAD_SIZE      = 200000; # bytes
$CJPEG_PROG           = "/usr/bin/cjpeg";           
$CJPEG_FLAGS          = "-quality 70 -progressive";
$HTPASSWD_PROG        = "/usr/local/apache/bin/htpasswd";        
$HTPASSWD_FLAGS       = "-bc";                 #unix only, on windows is used stdout redirection
$ZIP_PROG             = "/usr/bin/zip";             
$ZIP_FLAGS            = "-qj";
$GNUPLOT_PROG         = "/usr/bin/gnuplot";
$AUX                  = ""; 

srand;
# cookies, SET EXPIRE TIME
$cookie_expire="Sat, 29-Ago-09 00:00:00 GMT";

# allowed http_referers to insert request on database. (used on gen_opts_31.pl)
# replace "your_website.com" and "www.your_website.com" with your domain 
$allowed_ref1="http://dangerzone.escuadronbo2.com/cgi-bin/take_slot.pl";
$allowed_ref2="http://www.escuadronbo2.com/dangerzone/cgi-bin/take_slot.pl";

# db stuff
$database="s03e18df_dangerzone";       # database name  (CHANGE THIS)
$db_user="s03e18df_badc";        # database user  (CHANGE THIS)
$db_upwd="Phoenix";  # database user password  (CHANGE THIS)


#super_user hyperlobby nick name (used in gen_opts_31.pl: allow  make_suply_image.pl)
$super_user="E69_Heracles";

$MIS_PER_VDAY=30; # mission per virtual day (change time and auto recover AF and city)
$AF_VDAY_RECOVER=2; # % recovery of AF on each virtual day
$CT_VDAY_RECOVER=5; # % recovery of CITY on each virtual day
$CITY_DAM=75;	# Da�o en ciudad para poder ser conquistada
$TTL_WITH_DEF=20; 
$PC_LOST=5;

## @Heracles@20100103
## Airfield damage constants
$AF_HUMAN_SUM_PLANE_LOST_DAM=1.5; # damage to AF per each HUMAN SUM plane lost
$AF_HUMAN_SUM_PILOT_LOST_DAM=2.5; # damage to AF per each HUMAN SUM pilot lost
$AF_IA_SUM_PLANE_LOST_DAM=1.0; # damage to AF per each IA SUM plane lost
$AF_IA_SUM_PILOT_LOST_DAM=2.0; # damage to AF per each IA SUM pilot lost

$AF_HUMAN_BOMBER_PLANE_LOST_DAM=2.0; # damage to AF per each HUMAN BOMBER plane lost
$AF_HUMAN_BOMBER_PILOT_LOST_DAM=2.5; # damage to AF per each HUMAN BOMBER pilot lost
$AF_IA_BOMBER_PLANE_LOST_DAM=1.50; # damage to AF per each IA BOMBER plane lost
$AF_IA_BOMBER_PILOT_LOST_DAM=2.0; # damage to AF per each IA BOMBER pilot lost

$AF_HUMAN_FIGHTER_PLANE_LOST_DAM=1.5; # damage to AF per each HUMAN FIGHTER plane lost
$AF_HUMAN_FIGHTER_PILOT_LOST_DAM=2.0; # damage to AF per each HUMAN FIGHTER pilot lost
$AF_IA_FIGHTER_PLANE_LOST_DAM=1.0; # damage to AF per each IA FIGHTER plane lost
$AF_IA_FIGHTER_PILOT_LOST_DAM=1.5; # damage to AF per each IA FIGHTER pilot lost


$MIN_TIME_MIN=25; # minimun minutes of mission to accept a report
$MIN_PILOT_NUM=4; # minumum total human players per mission
$MIN_PILOT_SIDE=2; # minimun human pilot per side
# you can fly against ai, an require min human players: (Never tested)
# to do that set: $MIN_PILOT_SIDE=0 and $MIN_PILOT_NUM to something biger than 0.  

## @Heracles@20110412
## Porcentajes de suministros IA y HUMANOS
## @Heracles@20110107@
$AF_SUM_IA_RED=4;  # porcentaje de recupero  de AF rojo por cada transporte IA que aterriza
$AF_SUM_IA_BLUE=3;  # porcentaje de recupero  de AF azul por cada transporte IA que aterriza
$AF_SUM_HUMAN_RED=6; # porcentaje de recupero  de AF rojo por cada transporte HUMANO que aterriza
$AF_SUM_HUMAN_BLUE=5; # porcentaje de recupero  de AF azul por cada transporte HUMANO que aterriza
$AF_SUM_MAX_RAD=30000; # Radio m�ximo de distancia de una AF a la ciudad suministrada para poder suministrar AF
## @Heracles@20110410@
$CITY_SUM_HUMAN_RED=10; # procentaje de recupero de CIUDAD roja por cada transporte humano que activa el humo correctamente. Random entre este valor y este valor menos 2.
$CITY_SUM_IA_RED=7; # procentaje de recupero de CIUDAD roja por cada transporte IA que activa el humo correctamente
$CITY_SUM_HUMAN_BLUE=8; # procentaje de recupero de CIUDAD roja por cada transporte humano que activa el humo correctamente. Random entre este valor y este valor menos 2.
$CITY_SUM_IA_BLUE=6; # procentaje de recupero de CIUDAD roja por cada transporte IA que activa el humo correctamente

## @Heracles@20110425@
## Radio m�ximo de suministro para las ciudades
$MAX_SUM_RAD=50; # en kil�metros

$MIN_BOMBERS_DIST=50000; 
$MAX_BOMBERS_DIST=70000;
$MIN_FIGHTERS_DIST=2000;
$MAX_FIGHTERS_DIST=50000;
$MIN_ENEMY_AF_DIST=25000; # separacion entre AF enemigos de despegue minima.

@NIVEL_AI_INI=(1,1,1,1,1);

## @Heracles@20110417@
## Porcentajes de AAA en las ciudades. (0 - 1) Utilizar solo un decimal. Deber�an sumar 1 ;)
$AAA_CITY_HIGH=0.5;
$AAA_CITY_MEDIUM=0.1;
$AAA_CITY_LOW=0.4;

## @Heracles@20110423
## Constante de los c�digos de letras para los sectores de los mapas. de "A" a "BZ". Vigilar si existe un mapa mayor
@LETRAS_SEC=("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK","AL","AM","AN","AO","AP","AQ","AR","AS","AT","AU","AV","AW","AX","AY","AZ","BA","BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BO","BP","BQ","BR","BS","BT","BU","BV","BW","BX","BY","BZ");

$require_auth_code=1; # require or not auth code for squadron register
$ALLOW_AUTO_REGISTER=1; # allow pilots be registered automatically at repot time if he is unregistered.

# this is for new registered players, if you allow to do planin set to 0
# 1 is for not allow inital planning till a certan mission are flown
$INIT_BAN_PLANNIG=0;
$MIN_MIS_TO_PLAN=0; # when players reach this amount of mission, planning ban will be cleared
$MAX_NEGATIVE_VOTES=4; # amount of  negative votes when player loose planning rights

# uncoment ONLY ONE MAP:  the map you are flying!
# when map end coment this line and uncoment next in line :)
#MAPS:
#$MAP_NAME_LONG="Moscow. Winter 1941";
#$MAP_NAME_LONG="Moscow. Early 1942"; 
#$MAP_NAME_LONG="Stalingrad. Late 1942";
#$MAP_NAME_LONG="Stalingrad. Early 1943";
$MAP_NAME_LONG="Kursk. 1943"; 
#$MAP_NAME_LONG="Smolensk. 1944";
#$MAP_NAME_LONG="Balaton. 1945";
#$MAP_NAME_LONG="Berlin. 1945";
#$MAP_NAME_LONG="Moscow. Winter 1944"; 


$CHAMP_TYPES_TOTAL=4;
$CHAMP_TYPE_0_RAD=70;
$CHAMP_TYPE_1_RAD=50;
$CHAMP_TYPE_2_RAD=70;
$CHAMP_TYPE_3_RAD=80;

$CHAMP_TYPE=int(rand($CHAMP_TYPES_TOTAL));  
#$CHAMP_TYPE=2;  # force a champ type
if ($CHAMP_TYPE==0){$CHAMP_RAD=$CHAMP_TYPE_0_RAD;}
if ($CHAMP_TYPE==1){$CHAMP_RAD=$CHAMP_TYPE_1_RAD;}
if ($CHAMP_TYPE==2){$CHAMP_RAD=$CHAMP_TYPE_3_RAD;}
if ($CHAMP_TYPE==3){$CHAMP_RAD=$CHAMP_TYPE_3_RAD;}


$ALLIED_COLUMN_ATTK="Vehicles.RussiaCarsColumnE";
$AXIS_COLUMN_ATTK="Vehicles.GermanyCarsColumnA";


# DO NOT CHANGE lines below here unles you know what are you doing :)
#------------------------------------------------------------------------
$TANK_REGEX="Pz|T34|ValentineII|BT7|M4A2|T70"; # tank string identification use | as separator

if ( $MAP_NAME_LONG eq "Moscow. Winter 1941" || $MAP_NAME_LONG eq "Moscow. Early 1942") {

    # @HEracles@20110416@
    # Constantes que definen la salido y la puesta de sol de un dia virtual. Controlan si hay misiones nocturnas o no
    # S�lo adminte horas co�mo n�mero enteros en formato de 24 h.
    $SUNRISE=7;
    $SUNSET=17;
    
    # map image information
    $ANCHO=900;      # image width in pixels
    $ALTO=780;       # image height in pixels
    $H_BLOCK_PIX=47; # horizontal sector size in pixels
    $V_BLOCK_PIX=47; # vertical sector size in pixeles
    $LETRAS=20;      # map sector letters, 1 in excess 
    $NUMEROS=17;     # map sector numbers, 1 in excess 

    #tank types and aaa placement
    $ALLIED_TANKS_ATTK="Armor.3-BT7";
    $AXIS_TANKS_ATTK="Armor.3-PzIIIG";
    $ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$BT7"; # notice "escaped $"
    $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIIIG"; # notice "escaped $" 
    $AAA_IN_CHAMPS=0;       # place or not place AAA on field champs
    $LATE_AAA_IN_CHAMPS=0;  # place or not place advanced AAA, like nimrod and M16

    # Moscow common files
    $GEOGRAFIC_COORDINATES="MO_geo_obj.data";
    $FRONT_LINE="MO_frontline.mis";
    $RED_OBJ_FILE="MO_red_obj.mis";
    $BLUE_OBJ_FILE="MO_blue_obj.mis";
    $CITY_PLACES="MO_city.mis";
    $TANKS_WP="MO_tank_wp.mis";  
    $FRONT_IMAGE="MO_000.bmp";
    $IMAP_DATA="MO_imap.data";
    if ( $MAP_NAME_LONG eq "Moscow. Winter 1941") {	#Moscow. Winter 1941
	$MAP_CODE="MO1";
	$MAP_NAME_LOAD="Moscow/load.ini";
	$FLIGHTS_DEF="MO_aircrafts_1941.data";  
	@VVS_SUM_PLANES=("Li-2","TB3-4M-34R");
	$VVS_TRP_SPEED=180; # average speed for human VVS suply plane
	@VVS_BA_PLANES=("IL2 series1","IL2 series2","IL-2 Field Mod","IL-4-DB3B","PE-2 1940","R-10","SB-2M100A","SB2-M103","SU-2","TB3-4M-34R");
	@VVS_AI_PLANES=("Li-2","IL-4-DB3B","R-10","SB-2M100A","SB2-M103","SU-2");
	@LW_SUM_PLANES=("HE-111H2","JU-52");
	$LW_TRP_SPEED=360; # average speed for human LW suply plane
	@LW_BA_PLANES=("BF-110C4B","HE-111H2","JU-87B2","JU-88A4");
	@LW_AI_PLANES=("JU-52","BF-110C4B");
    }
    if ( $MAP_NAME_LONG eq "Moscow. Early 1942") {	#Moscow. Early 1942
	$MAP_CODE="MO2";
	$MAP_NAME_LOAD="Moscow/sload.ini";    
	$FLIGHTS_DEF="MO_aircrafts_1942.data";  
	@VVS_SUM_PLANES=("Li-2","TB3-4M-34R");
	$VVS_TRP_SPEED=180; # average speed for human VVS suply plane
	@VVS_BA_PLANES=("IL2 series2","IL2 series3","IL-2 Field Mod","IL-4-DB3B","IL-4-DB3M","PE-2 1940","R-10","SB-2M100A","SB2-M103","SU-2","TB3-4M-34R");
	@VVS_AI_PLANES=("Li-2","IL-4-DB3B","IL-4-DB3M","PE-2 S84","R-10","SB-2M100A","SB2-M103","SU-2");
	@LW_SUM_PLANES=("HE-111H2","JU-52");
	$LW_TRP_SPEED=360; # average speed for human LW suply plane
	@LW_BA_PLANES=("BF-110C4B","HE-111H2","JU-87B2","JU-88A4");
	@LW_AI_PLANES=("JU-52","BF-110C4B");
    }
}

if ($MAP_NAME_LONG eq "Stalingrad. Late 1942" || $MAP_NAME_LONG eq "Stalingrad. Early 1943" ){

    # @HEracles@20110416@
    # Constantes que definen la salido y la puesta de sol de un dia virtual. Controlan si hay misiones nocturnas o no
    # S�lo adminte horas co�mo n�mero enteros en formato de 24 h.
    $SUNRISE=7;
    $SUNSET=17;
    
    # map image information
    $ANCHO=900;      # image width in pixels
    $ALTO=780;       # image height in pixels
    $H_BLOCK_PIX=47; # horizontal sector size in pixels
    $V_BLOCK_PIX=47; # vertical sector size in pixeles
    $LETRAS=20;      # map sector letters, 1 in excess 
    $NUMEROS=17;     # map sector numbers, 1 in excess 

    #tank types and aaa placement
    $ALLIED_TANKS_ATTK="Armor.3-T70M";
    $AXIS_TANKS_ATTK="Armor.3-PzIIIM";
    $ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T70M"; # notice "escaped $"
    my $rnd= int(rand(2));
    if ($rnd){ $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIIIM";} # notice "escaped $" 
    else { $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIIIM";} # notice "escaped $" 

    $AAA_IN_CHAMPS=1;       # place or not place AAA on field champs
    $LATE_AAA_IN_CHAMPS=0;  # place or not place advanced AAA, like nimrod and M16

    #Stalingrad common
    $GEOGRAFIC_COORDINATES="ST_geo_obj.data";
    $FRONT_LINE="ST_frontline.mis";
    $RED_OBJ_FILE="ST_red_obj.mis";
    $BLUE_OBJ_FILE="ST_blue_obj.mis";
    $CITY_PLACES="ST_city.mis";
    $TANKS_WP="ST_tank_wp.mis";  
    $FRONT_IMAGE="ST_000.bmp";
    $IMAP_DATA="ST_imap.data";
    if ($MAP_NAME_LONG eq "Stalingrad. Late 1942") { # Stalingrado Late 1942
	$MAP_CODE="ST1";
	$MAP_NAME_LOAD="Stgrad/sload.ini";
	$FLIGHTS_DEF="ST_aircrafts_1942.data";  
	@VVS_SUM_PLANES=("Li-2","PE-2 S84");
	$VVS_TRP_SPEED=360; # average speed for human VVS suply plane -  ANTES PONIA 180
	@VVS_BA_PLANES=("PE-2 S84","PE-2 S110");
	@VVS_AI_PLANES=("Li-2","IL-4-DB3B","SB2-M103","SU-2");
	@LW_SUM_PLANES=("JU-88A4","JU-52");
	$LW_TRP_SPEED=360; # average speed for human LW suply plane
	@LW_BA_PLANES=("JU-88A4");
	@LW_AI_PLANES=("JU-52","BF-110C4B");
    } 
    if ($MAP_NAME_LONG eq "Stalingrad. Early 1943") { # Stalingrado Early 1943
	$MAP_CODE="ST2";
	$MAP_NAME_LOAD="Stgrad/load.ini";    
	$FLIGHTS_DEF="ST_aircrafts_1943.data";  
	@VVS_SUM_PLANES=("Li-2","PE-2 S84");
	$VVS_TRP_SPEED=360; # average speed for human VVS suply plane - ANTES PONIA 180
	@VVS_BA_PLANES=("PE-2 S84","PE-2 S110");
	@VVS_AI_PLANES=("Li-2","IL-4-DB3B","SB2-M103");
	@LW_SUM_PLANES=("JU-88A4","JU-52");
	$LW_TRP_SPEED=360; # average speed for human LW suply plane
	@LW_BA_PLANES=("JU-88A4");
	@LW_AI_PLANES=("JU-52","BF-110C4B");
    }
}


if ($MAP_NAME_LONG eq "Kursk. 1943"){

    # @HEracles@20110416@
    # Constantes que definen la salido y la puesta de sol de un dia virtual. Controlan si hay misiones nocturnas o no
    # S�lo adminte horas co�mo n�mero enteros en formato de 24 h.
    $SUNRISE=5;
    $SUNSET=19;

    # map image information
    $ANCHO=900;      # image width in pixels
    $ALTO=780;       # image height in pixels
    $H_BLOCK_PIX=47; # horizontal sector size in pixels
    $V_BLOCK_PIX=47; # vertical sector size in pixeles
    $LETRAS=20;      # map sector letters, 1 in excess 
    $NUMEROS=17;     # map sector numbers, 1 in excess 

    #tank types and aaa placement

#Para mantener lo mismo que en Stalingrado mientras no se decide el tankset
    $ALLIED_TANKS_ATTK="Armor.1-T34";
    $AXIS_TANKS_ATTK="Armor.1-PzVIE";
    $ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T34"; # notice "escaped $"
    $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzVIE"; # notice "escaped $" 

    $AAA_IN_CHAMPS=1;       # place or not place AAA on field champs
    $LATE_AAA_IN_CHAMPS=1;  # place or not place advanced AAA, like nimrod and M16

    $GEOGRAFIC_COORDINATES="KUR_geo_obj.data";
    $FRONT_LINE="KUR_frontline.mis";
    $RED_OBJ_FILE="KUR_red_obj.mis";
    $BLUE_OBJ_FILE="KUR_blue_obj.mis";
    $CITY_PLACES="KUR_city.mis";
    $TANKS_WP="KUR_tank_wp.mis";  
    $FRONT_IMAGE="KUR_000.bmp";
    $IMAP_DATA="KUR_imap.data";

    $MAP_CODE="KUR";
    $MAP_NAME_LOAD="Kursk/load.ini";
    $FLIGHTS_DEF="KUR_aircrafts.data";  
    @VVS_SUM_PLANES=("LI-2");
    $VVS_TRP_SPEED=295; # average speed for human VVS suply plane
    @VVS_BA_PLANES=("A-20C","SB-2_M103","IL_4","PE-2S84","PE-2S110","TU-2S");
    @VVS_AI_PLANES=("LI-2","IL-4-DB3B");

    @LW_SUM_PLANES=("JU-52-3MG4E");
    $LW_TRP_SPEED=250; # average speed for human LW suply plane
    @LW_BA_PLANES=("JU-88A4","HE-111H6");
    @LW_AI_PLANES=("JU-52-3MG4E","HS-129B2");
}


if ($MAP_NAME_LONG eq "Smolensk. 1944"){

    # @HEracles@20110416@
    # Constantes que definen la salido y la puesta de sol de un dia virtual. Controlan si hay misiones nocturnas o no
    # S�lo adminte horas co�mo n�mero enteros en formato de 24 h.
    $SUNRISE=7;
    $SUNSET=17;

    # map image information
    $ANCHO=900;      # image width in pixels
    $ALTO=780;       # image height in pixels
    $H_BLOCK_PIX=47; # horizontal sector size in pixels
    $V_BLOCK_PIX=47; # vertical sector size in pixeles
    $LETRAS=20;      # map sector letters, 1 in excess 
    $NUMEROS=17;     # map sector numbers, 1 in excess 

    #tank types and aaa placement
    my $times= int(rand(100))+1; # 1 ~ 100
    if ($times>25) {
	$ALLIED_TANKS_ATTK="Armor.3-T34";
	$AXIS_TANKS_ATTK="Armor.3-PzIVJ";
	$ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T34"; # notice "escaped $"
	$AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIVJ"; # notice "escaped $" 
	$AAA_IN_CHAMPS=1;       # place or not place AAA on field champs
	$LATE_AAA_IN_CHAMPS=1;  # place or not place advanced AAA, like nimrod and M16
    }
    else {
	$ALLIED_TANKS_ATTK="Armor.3-T70M";
	$AXIS_TANKS_ATTK="Armor.3-PzIIIM";
	$ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T70M"; # notice "escaped $"
	my $rnd= int(rand(2));
	if ($rnd){ $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIIIM";} # notice "escaped $" 
	else { $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIIIM";} # notice "escaped $" 
	$AAA_IN_CHAMPS=1;       # place or not place AAA on field champs
	$LATE_AAA_IN_CHAMPS=0;  # place or not place advanced AAA, like nimrod and M16
    }
    $GEOGRAFIC_COORDINATES="SM_geo_obj.data";
    $FRONT_LINE="SM_frontline.mis";
    $RED_OBJ_FILE="SM_red_obj.mis";
    $BLUE_OBJ_FILE="SM_blue_obj.mis";
    $CITY_PLACES="SM_city.mis";
    $TANKS_WP="SM_tank_wp.mis";  
    $FRONT_IMAGE="SM_000.bmp";
    $IMAP_DATA="SM_imap.data";

    $MAP_CODE="SML";
    $MAP_NAME_LOAD="Smolensk/load.ini";
    $FLIGHTS_DEF="SM_aircrafts.data";  
    @VVS_SUM_PLANES=("Li-2","B-25J1");
    $VVS_TRP_SPEED=360; # average speed for human VVS suply plane
    @VVS_BA_PLANES=("IL-2 1943 23mm","IL-2 1943 37mm","A-20G","B-25J1","IL-4-DB3B","PE-2 S359","PE-2 S110");
    @VVS_AI_PLANES=("Li-2","IL-4-DB3B","PE-2 S359","PE-2 S110");

    @LW_SUM_PLANES=("HE-111H6","JU-52");
    $LW_TRP_SPEED=360; # average speed for human LW suply plane
    @LW_BA_PLANES=("HE-111H6","JU-87D5","JU-88A4");
    @LW_AI_PLANES=("JU-52","JU-88A4");
}

if ($MAP_NAME_LONG eq "Balaton. 1945"){

    # @HEracles@20110416@
    # Constantes que definen la salido y la puesta de sol de un dia virtual. Controlan si hay misiones nocturnas o no
    # S�lo adminte horas co�mo n�mero enteros en formato de 24 h.
    $SUNRISE=7;
    $SUNSET=17;

    # map image information
    $ANCHO=900;      # image width in pixels
    $ALTO=780;       # image height in pixels
    $H_BLOCK_PIX=47; # horizontal sector size in pixels
    $V_BLOCK_PIX=47; # vertical sector size in pixeles
    $LETRAS=20;      # map sector letters, 1 in excess 
    $NUMEROS=17;     # map sector numbers, 1 in excess 

    #tank types and aaa placement
    my $times= int(rand(100))+1; # 1 ~ 100
    if ($times>25) {
	# T34 vs PzIVJ
#	$ALLIED_TANKS_ATTK="Armor.3-T34";
#	$AXIS_TANKS_ATTK="Armor.3-PzIVJ";
#	$ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T34"; # notice "escaped $"
#	$AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIVJ"; # notice "escaped $" 

	# T34-85 vs PzVA
	$ALLIED_TANKS_ATTK="Armor.3-T34_85";
	$AXIS_TANKS_ATTK="Armor.3-PzVA";
	$ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T34_85"; # notice "escaped $"
	$AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzVA"; # notice "escaped $" 

	$AAA_IN_CHAMPS=1;       # place or not place AAA on field champs
	$LATE_AAA_IN_CHAMPS=1;  # place or not place advanced AAA, like nimrod and M16
    }
    else {
	$ALLIED_TANKS_ATTK="Armor.3-T70M";
	$AXIS_TANKS_ATTK="Armor.3-PzIIIM";
	$ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T70M"; # notice "escaped $"
	my $rnd= int(rand(2));
	if ($rnd){ $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIIIM";} # notice "escaped $" 
	else { $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIIIM";} # notice "escaped $" 
	$AAA_IN_CHAMPS=1;       # place or not place AAA on field champs
	$LATE_AAA_IN_CHAMPS=0;  # place or not place advanced AAA, like nimrod and M16
    }
    $GEOGRAFIC_COORDINATES="BAL_geo_obj.data";
    $FRONT_LINE="BAL_frontline.mis";
    $RED_OBJ_FILE="BAL_red_obj.mis";
    $BLUE_OBJ_FILE="BAL_blue_obj.mis";
    $CITY_PLACES="BAL_city.mis";
    $TANKS_WP="BAL_tank_wp.mis";  
    $FRONT_IMAGE="BAL_000.bmp";
    $IMAP_DATA="BAL_imap.data";

    $MAP_CODE="BAL";
    $MAP_NAME_LOAD="Balaton/load_w.ini";
    $FLIGHTS_DEF="BAL_aircrafts.data";  
    @VVS_SUM_PLANES=("Li-2","B-25J1","TB3-4M-34R");
    $VVS_TRP_SPEED=360; # average speed for human VVS suply plane
    @VVS_BA_PLANES=("IL-2 1943 23mm","IL-2 1943 37mm","A-20G","B-25J1","IL-4-DB3B","PE-2 S359","PE-2 S110","Tu-2S","JU-87D3");
    @VVS_AI_PLANES=("Li-2","IL-4-DB3B","PE-2 S359","PE-2 S110","Tu-2S","TB3-4M-34R");

    @LW_SUM_PLANES=("HE-111H6","JU-52","ME-323");
    $LW_TRP_SPEED=360; # average speed for human LW suply plane
    @LW_BA_PLANES=("HE-111H6","JU-87D5","JU-88A4","BF-110G2");
    @LW_AI_PLANES=("JU-52","JU-88A4","ME-323");
}


if ($MAP_NAME_LONG eq "Berlin. 1945"){ 

    # @HEracles@20110416@
    # Constantes que definen la salido y la puesta de sol de un dia virtual. Controlan si hay misiones nocturnas o no
    # S�lo adminte horas co�mo n�mero enteros en formato de 24 h.
    $SUNRISE=7;
    $SUNSET=17;

    # map image information
    $ANCHO=900;      # image width in pixels
    $ALTO=386;       # image height in pixels
    $H_BLOCK_PIX=46; # horizontal sector size in pixels
    $V_BLOCK_PIX=47; # vertical sector size in pixeles
    $LETRAS=20;      # map sector letters, 1 in excess 
    $NUMEROS=9;     # map sector numbers, 1 in excess 

    #tank types and aaa placement
    # T34 vs PzIVJ
#    $ALLIED_TANKS_ATTK="Armor.3-T34";
#    $AXIS_TANKS_ATTK="Armor.3-PzIVJ";
#    $ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T34"; # notice "escaped $"
#    $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzIVJ"; # notice "escaped $" 

    # T34-85 vs PzVA
    $ALLIED_TANKS_ATTK="Armor.3-T34_85";
    $AXIS_TANKS_ATTK="Armor.3-PzVA";
    $ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T34_85"; # notice "escaped $"
    $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzVA"; # notice "escaped $" 

    $AAA_IN_CHAMPS=1;       # place or not place AAA on field champs
    $LATE_AAA_IN_CHAMPS=1;  # place or not place advanced AAA, like nimrod and M16

    $GEOGRAFIC_COORDINATES="BER_geo_obj.data";
    $FRONT_LINE="BER_frontline.mis";
    $RED_OBJ_FILE="BER_red_obj.mis";
    $BLUE_OBJ_FILE="BER_blue_obj.mis";
    $CITY_PLACES="BER_city.mis";
    $TANKS_WP="BER_tank_wp.mis";  
    $FRONT_IMAGE="BER_000.bmp";
    $IMAP_DATA="BER_imap.data";

    $MAP_CODE="BER";
    $MAP_NAME_LOAD="Berlin/load.ini";
    $FLIGHTS_DEF="BER_aircrafts.data";  
    @VVS_SUM_PLANES=("Li-2","B-25J1","TB3-4M-34R","C-47");
    $VVS_TRP_SPEED=360; # average speed for human VVS suply plane
    @VVS_BA_PLANES=("IL-2 1943 23mm","IL-2 1943 37mm","A-20G","B-25J1","IL-4-DB3B","PE-2 S359","PE-2 S110","Tu-2S","Pe-8","B-17G");
#    @VVS_AI_PLANES=("Li-2","IL-4-DB3B","PE-2 S359","PE-2 S110","Tu-2S","TB3-4M-34R","Pe-8","B-17G");
#    @VVS_AI_PLANES=("IL-4-DB3B","PE-2 S359","PE-2 S110","Tu-2S","Pe-8","B-17G","Li-2","C-47");
    @VVS_AI_PLANES=("Li-2","IL-4-DB3B","PE-2 S359","PE-2 S110","Tu-2S","TB3-4M-34R","Pe-8","B-17G");

    @LW_SUM_PLANES=("HE-111H6","Fw200","ME-323");
    $LW_TRP_SPEED=360; # average speed for human LW suply plane
    @LW_BA_PLANES=("HE-111H6","JU-87D5","JU-88A4","BF-110G2","Me262A2-a");
    @LW_AI_PLANES=("JU-52","JU-88A4","ME-323","Me-210CA1","Fw200","HS-129B3WA");
}

if ($MAP_NAME_LONG eq "Moscow. Winter 1944"){

    # @HEracles@20110416@
    # Constantes que definen la salido y la puesta de sol de un dia virtual. Controlan si hay misiones nocturnas o no
    # S�lo adminte horas co�mo n�mero enteros en formato de 24 h.
    $SUNRISE=7;
    $SUNSET=17;

    # map image information
    $ANCHO=900;      # image width in pixels
    $ALTO=780;       # image height in pixels
    $H_BLOCK_PIX=47; # horizontal sector size in pixels
    $V_BLOCK_PIX=47; # vertical sector size in pixeles
    $LETRAS=20;      # map sector letters, 1 in excess 
    $NUMEROS=17;     # map sector numbers, 1 in excess 

    #tank types and aaa placement

#Para mantener lo mismo que en Stalingrado mientras no se decide el tankset
    $ALLIED_TANKS_ATTK="Armor.3-T34_85";
    $AXIS_TANKS_ATTK="Armor.3-PzVIE";
    $ALLIED_TANKS_DEF="vehicles.artillery.Artillery\$T34_85"; # notice "escaped $"
    my $rnd= int(rand(2));
    if ($rnd){ $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzVIE";} # notice "escaped $" 
    else { $AXIS_TANKS_DEF="vehicles.artillery.Artillery\$PzVIE";} # notice "escaped $" 

    $AAA_IN_CHAMPS=1;       # place or not place AAA on field champs
    $LATE_AAA_IN_CHAMPS=1;  # place or not place advanced AAA, like nimrod and M16

    $GEOGRAFIC_COORDINATES="MO_geo_obj.data";
    $FRONT_LINE="MO_frontline.mis";
    $RED_OBJ_FILE="MO_red_obj.mis";
    $BLUE_OBJ_FILE="MO_blue_obj.mis";
    $CITY_PLACES="MO_city.mis";
    $TANKS_WP="MO_tank_wp.mis";  
    $FRONT_IMAGE="MO_000.bmp";
    $IMAP_DATA="MO_imap.data";

    $MAP_CODE="MO3";
    $MAP_NAME_LOAD="Moscow/load.ini";
    $FLIGHTS_DEF="MO_aircrafts_1944.data";  
    @VVS_SUM_PLANES=("PE-2 S110");
    $VVS_TRP_SPEED=360; # average speed for human VVS suply plane
    @VVS_BA_PLANES=("A-20C","IL-2 1943 23mm");
    @VVS_AI_PLANES=("Li-2","IL-4-DB3B");

    @LW_SUM_PLANES=("JU-88A4");
    $LW_TRP_SPEED=360; # average speed for human LW suply plane
    @LW_BA_PLANES=("JU-88A4","BF-110G2");
    @LW_AI_PLANES=("JU-52","HS-129B2");
}

$WINDOWS=0;
if  ($^O =~ m/Win/){ # we are using windows?  ..  to later use correct eval commands
    $WINDOWS=1;
}
$unix_cgi=1;  # this is not only unix. really indicates if is CGI or CMD LINE

# db tables
$sqd_file_tbl="badc_sqd_file";        # squadron file tbl
$pilot_file_tbl="badc_pilot_file";    # pilot_file tbl
$host_slots_tbl="badc_host_slots";    # host_slots tbl
$pilot_mis_tbl="badc_pilot_mis";      # pilot_missions table
$mis_prog="badc_mis_prog";            # mission in progress table
$air_events_tbl="badc_air_event";     # air events tbl
$ground_events_tbl="badc_grnd_event"; # ground events tbl
$rescue_tbl="badc_rescues";           # rescue table
$av_list="av_list";
$av_perdidas="av_perdidas";
$config="config";
$nivelia="nivelia";

$voted_names_tbl="badc_voted_names";
$co_voting_names_tbl="badc_co_voting_names";

#a shorcut used when printing html error messages
$big_red="<strong><font size=\"+2\" color=\"ff0000\"><br>";

$VVS_RADIO="&0";
$LW_RADIO="&0";
my $radio;
$radio= int(rand(100))+1; # 1 ~ 100
if ($radio>50) { $VVS_RADIO="&1";}
$radio= int(rand(100))+1; # 1 ~ 100
if ($radio>50) { $LW_RADIO="&1";}


#locks (if you change this, you have to update "create.php", because they monitor this filenames. (UP/DOWN)
$parser_lock="_par.lock";  # indicates parser is working, not allow generation or new parser
$gen_lock="_gen.lock";     # indicates generator is working, not allow parser or new generation
$parser_stop="_par.stop";  # manual stop parser, do not blocks generator
$gen_stop="_gen.stop";     # manual stop generator, do not blocks parser

# used in take_slot.pl
$expire_seconds=1200; # set expire time 1800 seconds = 30 minutes
