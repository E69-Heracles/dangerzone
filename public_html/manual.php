<?php  
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>
			<!---------- CONTENIDO DE LA PAGINA START ------------>
			
			<style>
				h1 { font-family : Stencil; }
				h2 { font-family : Stencil; }
				h3 { font-family : Stencil; }
				h4 { font-family : Stencil; }
		
			</style>
	
			<table cellpadding="0" cellspacing="0" width="835px" border=0>
			<tr>
				<td colspan="3">
		<H1>manual de dangerzone</H1> 

		<A HREF="http://www.gavca.com/modules.php?name=Content&amp;pa=showpage&amp;pid=39">Vers&atilde;o em Portugu&ecirc;s</A> 
		&nbsp;Traduzida por Jambock &quot;Tupan&quot; 37<BR/> 
		<A HREF="/manual_fr.html">Version Fran&ccedil;aise</A> 
		&nbsp;Traduit par	FreeManStars alias 214th=FreeMan=
		
		<UL TYPE=DISC> 
			<LI><A HREF="#register">Registro</A> 
			<LI><A HREF="#report">Reportar misiones</A>
			<LI><A HREF="#intro">DZ, H&eacute;roes sobre Europa: introducci&oacute;n</A>
			<LI><A HREF="#howwork">DZ : C&oacute;mo funciona</A>
			<LI><A HREF="#suply">Misiones de Suministro</A>
			<LI><A HREF="#rules">DZ : Reglas</A> 
			<LI><A HREF="#hostrec">Configuraciones recomendadas para Hosts</A>
			<LI><A HREF="#puntu">DZ : Sistema de Puntuaci&oacute;n</A>
			<LI><A HREF="#howhost">C&oacute;mo generar una misi&oacute;n</A> 
		</UL> 
		<br/>

		proporcionar tu nombre (el que usas en&nbsp; HyperLobby) y una
		<H2><A NAME="register"></A>Registro</H2> 
		<P>El registro en &nbsp;DZ es independiente del registro en el
		Foro. &Eacute;ste utiliza una base de datos completamente
		diferente.</P> 
		<P STYLE="margin-bottom: 0.42cm"><A NAME="_x0000_i1027"></A>&nbsp;DZ&nbsp;es
		una campa&ntilde;a online, cuyas partidas se lanzan desde el
		servidor de juegos <B>Hyperlobby</B>. Por tanto, lo primero que
		tienes que hacer es conseguir el programa cliente de Hyperlobby y
		registrar un nombre de piloto. Haz click en el bot&oacute;n
		Hyperlobby para conseguir el cliente:<BR><BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<SPAN STYLE="text-decoration: none"> 
		<A HREF="http://hyperfighter.sk/" target="main"><IMG SRC="images/hl.gif" NAME="gr&aacute;ficos3" ALIGN=BOTTOM WIDTH=88 HEIGHT=31 BORDER=0></A></SPAN></P> 
		<P>Para registrarte como piloto tienes que cumplimentar el
		formulario &quot;Registro de Piloto&quot;. Tendr&aacute;s que
		contrase&ntilde;a personal. Tambi&eacute;n puedes a&ntilde;adir tu
		email y un enlace a una imagen de avatar. Una vez hecho esto,
		puedes editar tu perfil, unirte o crear un escuadr&oacute;n, etc.</P> 
		<P>&nbsp;</P> 
		<P>Ten en cuenta que <B>si ya has volado alguna misi&oacute;n de
		&nbsp;DZ ya est&aacute;s autom&aacute;ticamente registrado como
		piloto</B>. La contrase&ntilde;a que se te ha asignado es tu nombre
		de HyperLobby (nombre exacto). Si &eacute;ste es tu caso, tienes
		que saltarte el registro e ir directamente a &quot;Editar Piloto&quot;
		para que puedas cambiar tu contrase&ntilde;a, a&ntilde;adir tu
		email y enlazar tu imagen de avatar. Tras esto puedes crear o
		unirte a un escuadr&oacute;n.</P> 
		<P>Registro de Escuadrones **: Si eres el CO de un escuadr&oacute;n,
		ve a &quot;Escuadrones -&gt; Registro&quot; y rellena el formulario
		con la informaci&oacute;n del escuadr&oacute;n. Una vez completado
		el formulario ser&aacute;s incorporado autom&aacute;ticamente al
		escuadr&oacute;n junto con tus estad&iacute;sticas. Tras esto ya
		puedes ir a &quot;Escuadrones -&gt; Editar&quot; y a&ntilde;adir un
		XO a tu escuadr&oacute;n. El CO y el XO pueden aceptar solicitudes
		de pilotos para unirse al escuadr&oacute;n. Una vez aceptada la
		solicitud, las estad&iacute;sticas del nuevo piloto ser&aacute;n
		incluidas en las del escuadr&oacute;n.</P> 
		<P><B>Pide el c&oacute;digo de autorizaci&oacute;n en el foro </B>o
		contacta con&nbsp;<FONT COLOR="#ff0000"><B>E69_Mertons</B></FONT> 
		para los c&oacute;digos de autorizaci&oacute;n o cualquier duda
		sobre el proceso de registro.</P> 
		<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=2> 
			<TR> 
				<TD BGCOLOR="#dddddd"> 
					<P><FONT SIZE=2><B>**</B></FONT> <FONT SIZE=2>El registro de
					Escuadrones est&aacute; limitado por el car&aacute;cter privado
					de la competici&oacute;n, por lo que no se aceptar&aacute;
					ning&uacute;n escuadr&oacute;n sin la aprobaci&oacute;n previa
					del Staff de Dangerzone<BR>&nbsp;</FONT></P> 
				</TD> 
			</TR> 
		</TABLE> 
		<P>La cantidad total de aviones debe estar predefinida antes de
		hacer el request. En el request, hay una entrada &ldquo;aviones&rdquo;,
		por lo que el Host puede verificar que la cantidad de aviones
		coincide con el n&uacute;mero predefinido en el momento de combinar
		los requests de ambos bandos (8x8 12x12 16x16 8x12 12x8 12x16
		etc...).</P> 
		<P>Como puedes ver, el host no tiene necesariamente que hacer un
		request. &Eacute;ste puede hacerlo cualquier piloto (autorizado
		para ello). El Host s&oacute;lo tiene que combinar los requests de
		ambos bandos. Por favor, ten cuidado al elegir el request apropiado
		para la misi&oacute;n que se va a hostear. 
		</P> 
		<P>La distribuci&oacute;n de aviones se dividir&aacute; en: Defensa
		y Ataque:</P> 
		<ul>
			<li>Los aviones de ataque son los asignados para realizar
			nuestro ataque: escoltar&aacute;n a los aviones de ataque en el
			caso de que nuestro objetivo sea una ciudad o aer&oacute;dromo, o a
			los transportes de suministros, o proporcionar&aacute;n cobertura
			a&eacute;rea para nuestros tanques (en el caso de que hagamos un
			ataque t&aacute;ctico).</P> 
			<li>Los aviones de defensa ser&aacute;n los encargados de
			llevar a cabo nuestra defensa, dependiendo del tipo de ataque
			enemigo pueden ser: <B>patrulla</B>, en caso de que el enemigo
			ataque una de nuestras ciudades o aer&oacute;dromos;&nbsp;
			<B>interceptores</B>, si el enemigo realiza una misi&oacute;n de
			suministros; o <B>escolta</B> del grupo de bombarderos encargado de
			atacar a los tanques enemigos (en el caso de que el enemigo haga un
			ataque t&aacute;ctico).</P> 
		</ul>
		<H2><a name="report"></a>Reportar Misiones</H2> 
		<ol>
			<li><A HREF="rep_input.html">P&aacute;g. Reportar</A>.
			<li>Encuentra tu archivo <I>eventlog</I> e introduce el n&uacute;mero	de misi&oacute;n que quieres reportar (ej: badc_30278) 
			<li>Introduce tu nombre y contrase&ntilde;a. 
			<li>Presiona <I>enviar</I>, y <B>espera</B> al resultado del reporte. Este paso puede tardar muchos segundos, 
				alrededor de un	minuto, dependiendo del resultado de la misi&oacute;n y de la carga	del servidor, debido a 
				que se deben redibujar las nuevas l&iacute;neas	del frente.
		</ol>
		<p>Notas: </P>
		En el caso de que haga
		un refly de una misi&oacute;n, no necesitas editar el archivo
		<I>eventlog</I> . El parser buscar&aacute; la &uacute;ltima misi&oacute;n
		que coincida con el n&uacute;mero de misi&oacute;n</P> 
		<P>Es importante esperar
		a que aparezca un mensaje de CONFIRMACI&Oacute;N o ERROR del
		parser. Si no aparece, puede ser por que la imagen se rompa, no se
		actualice o que se trate de un reporte incorrecto.</P> 
		
		<H2><A NAME="intro"></A>DZ, H&eacute;roes sobre Europa: introducci&oacute;n</H2> 
		<P>&iquest;Quieres empujar al enemigo
		fuera del territorio? &iquest;Quieres destruir sus aer&oacute;dromos,
		campamentos y tropas? &iquest;Cortar sus rutas de suministros,
		aislarlas y apoderarte de ellas? &iquest;Rescatar a compa&ntilde;eros
		abatidos? &nbsp;DZ es el lugar. 
		</P> 
		<P ALIGN=JUSTIFY>En DZ, el territorio
		est&aacute; dividido en sectores. Estos sectores son &aacute;reas
		cuadradas de 10 Km.. de lado. Estos sectores que conforman el mapa
		pertenecen a alguno de los bandos en todo momento. Quien domina un
		sector, domina todo lo que hay en ese sector: ciudades, aer&oacute;dromos,
		campamentos. El avance se consigue capturando sectores.</P> 
		<P ALIGN=JUSTIFY>El objetivo de DZ es
		la conquista del territorio (mapa de FB/PF). Cada mapa comienza con
		una posici&oacute;n equilibrada entre ambos bandos. Una vez
		comenzado el mapa, cada bando trata de avanzar sobre el territorio
		que controla el enemigo, apoder&aacute;ndose de las ciudades y
		aer&oacute;dromos.</P> 
		<P ALIGN=JUSTIFY>Debes ocupar todas las
		poblaciones enemigas con suministros o todos los aer&oacute;dromos
		enemigos para alcanzar la victoria. Si uno de los bandos (rojo o
		azul) pierde todos sus aer&oacute;dromos significar&aacute; que ha
		sido derrotado porque no puede proporcionar apoyo a&eacute;reo a
		sus fuerzas terrestres. Al mismo tiempo, si un bando pierde todas
		sus ciudades estar&aacute; vencido porque porque no podr&aacute;
		abastecer a sus tropas de tierra.</P> 
		<P ALIGN=JUSTIFY>En ambos casos el mapa
		que se est&aacute; jugando se acaba y el siguiente que est&eacute;
		planificado dar&aacute; comienzo, salvo que &eacute;se mapa fuera
		el &uacute;ltimo de la campa&ntilde;a, en cuyo caso se llevar&iacute;a
		al final de la campa&ntilde;a actual.</P> 
		<P ALIGN=JUSTIFY>Las ciudades tienen un
		valor estrat&eacute;gico: la capacidad de mantener tropas aliadas
		en zonas cercanas a la ciudad. Cada ciudad tiene un radio de
		suministro. Todos los sectores aliados dentro de este radio
		operativo tendr&aacute;n campamentos fuertemente armados, lo que
		implica que el enemigo tendr&aacute; mayores dificultades para
		atacar estos sectores abastecidos.</P> 
		<P ALIGN=JUSTIFY>Como puede verse, los
		sectores, ciudades y campamentos est&aacute;n estrechamente
		relacionados. El control sobre un sector que contiene una ciudad
		nos permite apoderarnos de esa ciudad. El radio de suministro de la
		ciudad permite mantener campamentos armados que fortifican la
		defensa de los sectores pr&oacute;ximos a la ciudad.</P> 
		<P ALIGN=JUSTIFY>Teniendo en cuenta
		esta interacci&oacute;n, introducimos el DZ la posibilidad de
		&ldquo;ataques estrat&eacute;gicos&rdquo;, es decir, atacar
		ciudades para reducir su radio de acci&oacute;n y acelerar el
		avance sobre sectores enemigos con pocas defensas. Tambi&eacute;n
		se introduce la posibilidad de reabastecer de suministros nuestras
		ciudades, para incrementar su radio operativo para proporcionar
		zonas mejor defendidas ante los ataques del enemigo.</P> 
		<P ALIGN=JUSTIFY>Las bases a&eacute;reas
		(aer&oacute;dromos) juegan un papel muy importante. En la medida en
		que nuestras bases est&aacute;n alejadas de las zonas de conflicto,
		es m&aacute;s dif&iacute;cil ofrecer apoyo a&eacute;reo. Por este
		motivo introducimos la posibilidad de atacar las bases hasta el
		punto de dejarlas inoperativas. Tambi&eacute;n existe la
		posibilidad de reabastecer las bases para devolverlas a estado
		operativo o para reducir los da&ntilde;os provocados por el
		enemigo.</P> 
		<P ALIGN=JUSTIFY>Esta introducci&oacute;n
		es suficiente para entender el funcionamiento general de DZ. En la
		siguiente secci&oacute;n se explican con m&aacute;s detalle los
		tipos de ataque, las consecuencias, la cantidad de da&ntilde;os que
		se puede obtener y otros datos que hay que considerar a la hora de
		planificar una estrategia.</P> 
		<H2 ALIGN=JUSTIFY><A NAME="howwork"></A>DZ: C&oacute;mo funciona</H2> 
		<P ALIGN=JUSTIFY><FONT COLOR="#ff0000">Esta
		secci&oacute;n no est&aacute; del todo actualizada, trabajamos en
		una nueva y m&aacute;s completa.</FONT> 
		</P> 
		<P ALIGN=JUSTIFY>En cada misi&oacute;n,
		a ambos bandos se les pedir&aacute; que elijan una zona de ataque
		en el mapa de la guerra. Hay dos formas distintas de realizar un
		ataque:</P> 
		<P ALIGN=JUSTIFY><B>Ataque T&aacute;ctico</B> 
		y <B>Ataque Estrat&eacute;gico.</B></P> 
		<P ALIGN=JUSTIFY>&nbsp;</P> 
		<P ALIGN=JUSTIFY>Si est&aacute;s
		tratando de capturar un sector del mapa cercano a la l&iacute;nea
		del frente, eso es un <B>ataque t&aacute;ctico</B>, en cuyo caso se
		env&iacute;a a un grupo de tanques a conquistar el &aacute;rea. 
		</P> 
		<P ALIGN=JUSTIFY>Por otra parte, si
		est&aacute;s atacando directamente una ciudad o aer&oacute;dromo
		para recudir su radio de suministro o su estado operativo, se trata
		de un <B>ataque estrat&eacute;gico.</B></P> 
		<H3 ALIGN=JUSTIFY>Capturar
		sectores enemigos del mapa:</H3> 
		<P ALIGN=JUSTIFY>Cuando un bando trata
		de conquistar un sector enemigo, el sector atacado debe estar en la
		l&iacute;nea del frente del mapa, y lo &uacute;nico que necesita
		ese bando es realizar un ataque t&aacute;ctico sobre el sector.</P> 
		<P ALIGN=JUSTIFY>Cuando realizamos un
		ataque t&aacute;ctico, estamos enviando tropas de tierra (tanques y
		veh&iacute;culos) al sector atacado. Dicho sector puede estar o no
		dentro del radio de suministro enemigo. Si lo est&aacute;, nuestras
		tropas se enfrentar&aacute;n a las tropas de tierra enemigas
		durante el asalto al sector, as&iacute; como a bombarderos enemigos
		que tratar&aacute;n de parar su avance.</P> 
		<P ALIGN=JUSTIFY>Por este motivo es
		preferible atacar sectores en los que el enemigo no dispone de
		ning&uacute;n tipo de suministros de sus ciudades. Incluso cuando
		el sector enemigo carece de suministros es posible no lograr el
		asalto si las fuerzas a&eacute;reas enemigas tienen &eacute;xito en
		su misi&oacute;n. Por esto es importante dar siempre apoyo a&eacute;reo
		a nuestras tropas terrestres de asalto. Si en el &aacute;rea que
		estamos atacando no hay fuerzas de oposici&oacute;n terrestres,
		podemos elegir los aer&oacute;dromos cercanos como objetivo de
		nuestros siguientes ataques estrat&eacute;gicos, y si adem&aacute;s
		logramos da&ntilde;arlos lo suficiente, forzaremos al enemigo a
		volar desde aer&oacute;dromos lejanos, puede que lo suficientemente
		lejanos como impedir que proporcionen cobertura a&eacute;rea en ese
		sector. Esta situaci&oacute;n nos dar&aacute; m&aacute;s
		oportunidades para el &eacute;xito final.</P> 
		<P ALIGN=JUSTIFY>Como a&uacute;n
		estamos en la versi&oacute;n Beta del juego, el ataque terrestre se
		har&aacute; con 9 tanques, 6 de los cuales han de sobrevivir al
		final de la misi&oacute;n para que se considere un &eacute;xito y
		se conquiste el sector.</P> 
		<H2 ALIGN=JUSTIFY><A NAME="suply"></A>Misiones de Suministro:</H2> 
		<P ALIGN=JUSTIFY>Para hacer una misi&oacute;n
		de suministro tienes que seleccionar el objetivo
		<B>SUM-&quot;nombre_de_la_ciudad&quot;</B>. Se establecer&aacute;
		un vuelo de hasta 6 aviones. Las misiones de suministros solo puede
		realizarlas la IA por ahora, hasta que decidamos qu&eacute; aviones
		pilotables se destinar&aacute;n al efecto para cada bando. De todas
		formas a continuaci&oacute;n se detalla el procedimiento para que
		se vaya conociendo:</P> 
		<P ALIGN=JUSTIFY>Los aviones de
		transporte han de despegar y volar hasta el punto de ruta
		(waypoint) sobre la ciudad para reabastecer. Cuando est&eacute;s
		cerca del punto, a menos de 5 Km., tienes que encender el humo
		durante algunos segundos y despu&eacute;s apagarlo. Tienes 3
		intentos, y al menos uno tiene que estar dentro del radio. Tras
		esto, puedes aterrizar en el aer&oacute;dromo que prefieras y &eacute;ste
		recibir&aacute; suministros tambi&eacute;n. 
		</P> 
		<P ALIGN=JUSTIFY>Para realizar un
		suministro v&aacute;lido debes cargar las armas por defecto y el
		100% del combustible(<B>default weapons and 100% fuel</B>). El
		reabastecimiento ha de hacerse dentro de los l&iacute;mites de
		tiempo expuestos en el briefing de la misi&oacute;n.</P> 
		<P ALIGN=JUSTIFY>Por ahora s&oacute;lo
		disponemos de &nbsp;C-47 y Ju-52 para tareas de suministro, aunque
		ya se est&aacute; estudiando la posibilidad de incluir otros
		aviones pilotables.</P> 
		<P ALIGN=JUSTIFY>Si lo que te interesa
		es reabastecer s&oacute;lo un Aer&oacute;dromo, selecciona una
		misi&oacute;n de suply a una ciudad pr&oacute;xima al aer&oacute;dromo
		y realiza un suministro normal a la ciudad, aterrizando finalmente
		en el aer&oacute;dromo que te preocupa.</P> 
		<P ALIGN=JUSTIFY>El &eacute;xito del
		suministro es variable, el porcentaje de cumplimiento para cada
		avi&oacute;n Aliado est&aacute; en 2-4% hacia las ciudades y 5%
		hacia los aer&oacute;dromos. Para cada avi&oacute;n LW est&aacute;
		en 2-3% y 5%, respectivamente..</P> 
		<H3 ALIGN=JUSTIFY>Capturar
		ciudades o aer&oacute;dromos:</H3> 
		<P ALIGN=JUSTIFY>Si un sector capturado
		contiene una ciudad o aer&oacute;dromo, &eacute;stos tambi&eacute;n
		ser&aacute;n capturados con su actual estado operativo. Esto
		significa que si capturamos una ciudad enemiga y en ese momento su
		radio de suministro es de 30 Km., la capturaremos con el mismo
		radio de suministro o porcentaje de da&ntilde;os. Si el sector
		contiene un aer&oacute;dromo destruido, estar&aacute; no operativo
		tambi&eacute;n para nosotros.</P> 
		<P ALIGN=JUSTIFY><B>Para capturar un
		sector en el que existe una ciudad, &eacute;sta debe tener un
		porcentaje de da&ntilde;o superior al 50%. Esto no se aplica a las
		capturas Aisladas (conquista M&uacute;ltiple, ver la siguiente
		secci&oacute;n)</B></P> 
		<P ALIGN=JUSTIFY>Si est&aacute;s
		defendiendo un sector, hay un tiempo l&iacute;mite para hacerlo.
		Tienes 40 minutos desde el inicio de la misi&oacute;n para destruir
		a los tanques que entran en el sector. Despu&eacute;s de ese
		tiempo, los tanques se cuentan como objetivos terrestres, pero no
		cuentan para el resultado de la misi&oacute;n. Esto se ha
		implementado para evitar que los bombarderos est&eacute;n dando
		rodeos hasta que los cazas se queden sin combustible.</P> 
		<H3 ALIGN=JUSTIFY>Conquistas
		m&uacute;ltiples:</H3> 
		<P ALIGN=JUSTIFY>En la siguiente
		imagen, el bando azul podr&iacute;a conseguir una captura m&uacute;ltiple
		de sectores:</P> 
		<P ALIGN=CENTER><A NAME="_x0000_i1028"></A> 
		<IMG SRC="images/capt_0.jpg" NAME="gr&aacute;ficos4" ALIGN=BOTTOM WIDTH=362 HEIGHT=326 BORDER=0></P> 
		<P>El bando rojo tiene una &quot;cabeza
		de puente&quot; que puede ser cercada si el bando azul ataca como
		muestra la flecha en la siguiente imagen. En el caso de que los
		azules lo consigan, tambi&eacute;n tendr&aacute;n &eacute;xito
		cercando el sector marcado con una cruz roja, por lo que capturar&aacute;n
		ambos sectores en un solo movimiento:</P> 
		<P ALIGN=CENTER><A NAME="_x0000_i1029"></A> 
		<IMG SRC="images/capt_1.jpg" NAME="gr&aacute;ficos5" ALIGN=BOTTOM WIDTH=362 HEIGHT=326 BORDER=0></P> 
		<P>Si los azules tiene posibilidades de
		hacerlo, el bando rojo deber&iacute;a entonces prever el movimiento
		de cerco y abrir una ruta de suministro alternativa inmediatamente,
		como se muestra en la imagen:</P> 
		<P ALIGN=CENTER><A NAME="_x0000_i1030"></A> 
		<IMG SRC="images/capt_2.jpg" NAME="gr&aacute;ficos6" ALIGN=BOTTOM WIDTH=362 HEIGHT=326 BORDER=0></P> 
		<H3>D&iacute;a
		Virtual:</H3> 
		<P>Hay un sistema de &quot;d&iacute;a&quot;
		en este juego. Cada d&iacute;a virtual corresponde a un n&uacute;mero
		determinado de misiones. Como ya se dijo previamente, este juego
		est&aacute; en fase beta aun, por lo que no hay nada decidido, pero
		por ahora el d&iacute;a virtual ocupar&aacute; entre 20 y 30
		misiones.</P> 
		<P>Las ciudades y aer&oacute;dromos
		recuperan un porcentaje del da&ntilde;o por s&iacute; mismos cada
		d&iacute;a que pasa en el juego. Cuidar de nuestras ciudades y
		aer&oacute;dromos y detener a los tanques que avanzan hacia ellos
		es una de las tareas m&aacute;s importantes en el juego. Por otra
		parte, si quieres derrotar definitivamente al enemigo, tendr&aacute;s
		que hacer lo contrario con sus ciudades y aer&oacute;dromos.</P> 
		<H3>Aer&oacute;dromos:</H3> 
		<P>Los aer&oacute;dromos estar&aacute;n
		operativos si su porcentaje de da&ntilde;os es MENOR al 80%. Una
		vez que se alcanza esta cifra, el aer&oacute;dromo pasar&aacute; a
		estar inoperativo y no podr&aacute; despegar desde &eacute;l ning&uacute;n
		vuelo, aunque s&iacute; podr&aacute;n aterrizar los vuelos aliados
		tras su misi&oacute;n. Cuanto m&aacute;s da&ntilde;ado est&eacute;,
		menos oposici&oacute;n de flak, artiller&iacute;a y objetos
		encontrar&aacute;s.</P> 
		<H3>Ciudades:</H3> 
		<P>Las ciudades funcionan de la misma
		forma que los aer&oacute;dromos. Cuanto m&aacute;s da&ntilde;adas,
		menos AAA, artiller&iacute;a u objectivos encontrar&aacute;s all&iacute;.</P> 
		<P>Cada ciudad tiene un radio m&aacute;ximo
		de suministro dependiendo de su importancia o tama&ntilde;o.
		Cualquier da&ntilde;o inflingido a la ciudad modificar&aacute; ese
		radio mediante un porcentaje. Las ciudades son las m&aacute;ximas
		responsables del abastecimiento de comida, combustible, munici&oacute;n,
		etc, de las tropas de tierra, por lo que el radio de suministro
		determinar&aacute; si un sector est&aacute; protegido por tropas de
		tierra o no. 
		</P> 
		<H3>Vuelos:</H3> 
		<P>Todos los vuelos cubrir&aacute;n una
		distancia m&iacute;nima de 40 Km. hasta el objetivo, ya sean de
		defensa o de ataque. Algunas veces ver&aacute;s que la zona del
		objetivo est&aacute; bastante lejos del punto de despegue, por lo
		que comprobar&aacute;s al mismo tiempo que el aer&oacute;dromo de
		aterrizaje se encontrar&aacute; lo mas cerca posible del objetivo
		que seleccionaste atacar/defender. Con esta caracter&iacute;stica
		se pretende simular el la idea real de buscar el punto de
		aterrizaje m&aacute;s pr&oacute;ximo para acabar la misi&oacute;n
		cuanto antes.</P> 
		<P>No hay posibilidad de que dos vuelos
		partan de dos aer&oacute;dromos enemigos demasiado cercanos, ni de
		que acaben en un aer&oacute;dromo demasiado pr&oacute;ximo al
		objetivo, porque esto se considera una situaci&oacute;n de alto
		riesgo.</P> 
		<H3>Combinaciones
		de ataque y organizaci&oacute;n de aviones:</H3> 
		<P>Dado que cada bando puede escoger su
		propio tipo de ataque y su objetivo, hay m&uacute;ltiples
		combinaciones de misi&oacute;n final :</P> 
		<CENTER> 
			<TABLE BORDER=1 CELLPADDING=0 CELLSPACING=2 width=250> 
				<TR> 
					<TD> 
						<P ALIGN=CENTER><B>Aliados</B></P> 
					</TD> 
					<TD> 
						<P ALIGN=CENTER><B>Eje</B></P> 
					</TD> 
				</TR> 
				<TR> 
					<TD> 
						<P ALIGN=CENTER>T&aacute;ctico</P> 
					</TD> 
					<TD> 
						<P ALIGN=CENTER>T&aacute;ctico</P> 
					</TD> 
				</TR> 
				<TR> 
					<TD> 
						<P ALIGN=CENTER>T&aacute;ctico</P> 
					</TD> 
					<TD> 
						<P ALIGN=CENTER>Estrat&eacute;gico</P> 
					</TD> 
				</TR> 
				<TR> 
					<TD> 
						<P ALIGN=CENTER>Estrat&eacute;gico</P> 
					</TD> 
					<TD> 
						<P ALIGN=CENTER>T&aacute;ctico</P> 
					</TD> 
				</TR> 
				<TR> 
					<TD> 
						<P ALIGN=CENTER>Estrat&eacute;gico</P> 
					</TD> 
					<TD> 
						<P ALIGN=CENTER>Estrat&eacute;gico</P> 
					</TD> 
				</TR> 
			</TABLE> 
		</CENTER> 
		
		<h4>T&aacute;ctico<!--<img src="chrome://editor/contentimages/tag-comment.gif"><!--[endif]-->--&gt;
		Vs. T&aacute;ctico:</H4> 
		<P>En este caso, ambos bandos intentan
		capturar sectores enemigos del mapa. El setup de la misi&oacute;n
		<SPAN LANG="en-GB">s</SPAN>er&aacute; como sigue<SPAN LANG="en-GB">:</SPAN></P> 
		<ul>
			<li><U>Aliados</U>: Un grupo de bombarderos intentar&aacute;
				destruir las tropas/tanques enemigos que invaden el sector ruso con
				o sin escolta de cazas. Este tipo de misi&oacute;n se conoce como
				VUELO DE DEFENSA. Adem&aacute;s, puede haber un grupo de cazas que
				intente proporcionar apoyo a&eacute;reo al ataque terrestre ruso en
			otro sector (conocido como VUELO DE ATAQUE).</li><br/>
			<li><u>LW</U>: Un grupo de bombarderos intentar&aacute;
				destruir las tropas/tanques enemigos que invaden el sector alem&aacute;n
				con o sin escolta de cazas. Este tipo de misi&oacute;n se conoce
				como VUELO DE DEFENSA. Adem&aacute;s, puede haber un grupo de cazas
				que intente proporcionar apoyo a&eacute;reo al ataque terrestre
			alem&aacute;n en otro sector (conocido como VUELO DE ATAQUE).</li>
		</ul> 
		
		<H4>Aliados: T&aacute;ctico Vs. Eje: Estrat&eacute;gico</H4> 
		<P>En este caso, las tropas aliadas
		intentan conquistar un sector enemigo del mapa, y por el contrario,
		las tropas del Eje atacan una ciudad o aer&oacute;dromo aliado.</P> 
		<ul>
			<li><U>Aliados</U>: Un grupo de interceptores se
				desplegar&aacute; cerca de la ciudad o aer&oacute;dromo que ser&aacute;
				atacada por los alemanes (VUELO DE DEFENSA), y otro grupo de cazas
				se desplegar&aacute; sobre el sector ruso atacado, dando cobertura
				a sus propias fuerzas terrestres (VUELO DE ATAQUE).</li><br/> 
			<li><U>LW</U>: Un grupo de bombarderos realizar&aacute;
				un ataque estrat&eacute;gico (ciudad/aer&oacute;dromo) con sus
				cazas de escolta (VUELO DE ATAQUE) y otro grupo de bombarderos,
				tambi&eacute;n con escoltas, intentar&aacute;n detener a las tropas
				rusas de avance. (VUELO DE DEFENSA).</li>
		</ul>	
	
		<H4>Aliados: Estrat&eacute;gico Vs. Eje: T&aacute;ctico</H4> 
		<P>Este tipo de ataque es bastante
		similar al anterior, pero alternando las misiones de cada bando.
		Ahora, los pilotos Aliados tendr&aacute;n dos grupos de
		bombarderos, cada uno con sus cazas de escolta, realizando un grupo
		entero un vuelo de ataque y el otro un vuelo de defensa. El bando
		LW estar&aacute; cubierto por dos grupos de cazas.</P> 
		
		<H4>Aliados: Estrat&eacute;gico Vs. Eje: Estrat&eacute;gico</H4> 
		<P>Esta es la &uacute;ltima situaci&oacute;n
		b&eacute;lica posible en el juego. En este caso, intentan atacar un
		&aacute;rea bastante lejana de sus aer&oacute;dromos de partida. A
		aquellos que hayan volado campa&ntilde;as de la VEF2, este tipo de
		situaci&oacute;n les resultar&aacute; bastante familiar.</P> 
		<P>El setup de los vuelos es como
		sigue:</P> 
		<ul>
			<li><U>Aliados</U>: un grupo de bombarderos con su grupo
				de cazas de escolta (VUELO DE ATAQUE), un grupo de cazas de
				intercepci&oacute;n (VUELO DE DEFENSA).</li><br/> 
			<li><U>LW</U>: un grupo de bombarderos con su grupo de
			cazas de escolta (VUELO DE ATAQUE), un grupo de cazas de
			intercepci&oacute;n (VUELO DE DEFENSA).</li>
		</ul> 
		
		
		<H2><A NAME="rules"></A>DZ : Reglas</H2> 
		<P> 
		&Eacute;sta es una lista muy b&aacute;sica de las Reglas,
		recomendaciones y procedimientos de hosteo. Todo piloto tiene sus
		derechos y deberes. Todo lo que no aparezca en esta lista vale. De
		todas formas, hay algunas recomendaciones, y algunos castigos
		autom&aacute;ticos para acciones no deseables.</P> 
		<H3>Derechos de
		los Pilotos:</H3> 
		<ul><li>
		<p>Cuando ocupas un slot de DZ en el HL, tienes el
		derecho de tomar parte en la misi&oacute;n. 
		</P> 
		<P><li>
		Tienes al menos una hora para realizar tu tarea. 
		</P> 
		<P><li>
		Tienes el derecho de seguir o no seguir los
		briefings. 
		</P> 
		<P><li>
		Tienes el derecho de que se reporten todas tus
		misiones. 
		</P> 
	</ul>
		<H3>Obligaciones
		de los Pilotos:</H3> 
		<ul>
			<P><li>
		No puedes abandonar una misi&oacute;n una vez
		comenzada. (Filtrado de misiones, desconexiones a prop&oacute;sito...)
				</P> 
		<P><li>
		No puedes reclamar por haber sido ametrallado o
		matado en paraca&iacute;das. 
		</P> 
		<P><li>
		No puedes reclamar sobre que otros pilotos usen luces
		o humo. 
		</P> 
		<P><li>
		No puedes reclamar sobre que otros pilotos no sigan
		los briefings. 
		</P> 
		<P><li>
		N<B>O PUEDES LEER LOS BRIEFINGS CONTRARIOS</B>. 
		</P> 
		<P><li>
		Est&aacute; <B>TERMINANTEMENTE PROHIBIDO </B>el uso
		de <B>cualquier programa/aplicaci&oacute;n/recurso externo que
		otorgue ventaja desigual</B>. (crear lag, etc) 
		</P> 
		<P><li>
		En general puedes reclamar s&oacute;lo si tus derecho
		no han sido respetados, lo que debe hacerse por medio de mensajes
		privados. 
		</P> 
	</ul>
		<H3>Recomendaciones:</H3> 
		<ul>
		<P><li>
		Puedes despegar y aterrizar las veces que quieras. 
		</P> 
		<P><li>
		El ametrallamiento est&aacute; permitido en cualquier
		momento y lugar. 
		</P> 
		<P><li>
		Las luces de aterrizaje est&aacute;n permitidas
		dentro de los 5 primeros minutos desde el comienzo de la misi&oacute;n
		(para despegar), y 5 antes de la maniobra de aterrizaje. El uso
		fuera de estos intervalos permitidos acarrear&aacute; puntuaci&oacute;n
		negativa autom&aacute;ticamente. 
		</P> 
		<P><li>
		El uso del humo no est&aacute; permitido. La &uacute;nica
		Excepci&oacute;n es en la misiones de Suministros. El uso fuera de
		esta excepci&oacute;n acarrear&aacute; puntuaci&oacute;n negativa
		autom&aacute;ticamente. 
		</P> 
		<P><li>
		No est&aacute; prohibido disparar a paracaidistas,
		pero como a la mayor&iacute;a de pilotos no les gusta, se aplicar&aacute;
		puntuaci&oacute;n negativa autom&aacute;ticamente. 
		</P> 
		<P><li>
		Los derribos de aviones aliados ser&aacute;n tratados
		autom&aacute;ticamente por el parser, sin importar cu&aacute;l fue
		la raz&oacute;n. 
		</P> 
	</ul>
		<H3>Procedimientos
		de Hosteo:</H3> 
		<ul>
		<P><li>
		Como host, tambi&eacute;n eres piloto, por lo que se
		te aplican todos los derechos, obligaciones y recomendaciones de
		piloto. 
		</P> 
		<P><li>
		Cuando se comienza una misi&oacute;n, todos los
		pilotos con slot en el HL tienen que ser admitidos. Los que se unan
		usando la &quot;puerta trasera&quot; deben ser kickeados, excepto
		si sobran aviones tras escoger los que estaban en slot del HL o las
		reconexiones. 
		</P> 
		<P><li>
		La misi&oacute;n debe durar al menos 10 minutos, sin
		importar si todos los pilotos humanos
		murieron/aterrizaron/desconectaron (killed/landed/disco) antes de
		ese tiempo. La misi&oacute;n debe durar hasta el momento en que
		todos los humanos dejen el juego. Si se alcanza la duraci&oacute;n
		de una hora, el host tiene el derecho de parar o continuar la
		misi&oacute;n, sin importar la situaci&oacute;n de otros pilotos.
		Si decide parar la misi&oacute;n se recomienda que avise
		previamente a los pilotos que queden en vuelo, aunque el criterio
		del host ser&aacute; definitivo. 
		</P> 
		<P><li>
		Los setings del juego deben ser Full real m&aacute;s
		speedbad. 
		</P> 
		<P><li>
		El <B>Dotrange</B> debe estar establecido en &quot;por
		defecto&quot; (14km). <B>ESTA PROHIBIDO CAMBIARLO.</B> 
		</P> 
		<P><li>
		Se proh&iacute;be hacer cambios en la misi&oacute;n
		una vez descargada (hora, clima, o cualquier otra cosa). 
		</P> 
		<P><FONT FACE="Symbol"><FONT SIZE=2><SPAN LANG="en-GB">&middot;</SPAN></FONT></FONT><FONT FACE="Symbol"><FONT SIZE=2><SPAN LANG="en-GB">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</SPAN></FONT></FONT><SPAN LANG="en-GB">The amount of players need
		to be at least 4 vs 4. </SPAN> 
		</P> 
		<P><li>
		<U><B>EL ARCHIVO DE LOG NO SE PUEDE CAMBIAR NI EDITAR
		BAJO NINGUNA CIRCUNSTANCIA.</B></U> 
		</P> 
		<P><li>
		Todas las misiones deben ser reportadas. 
		</P> 
		<P><li>
		El Host no puede expulsar a jugadores durante el
		juego. 
		</P> 
		<P><li>
		Los Hosts tienen que establecer correctamente los
		par&aacute;metros del &nbsp;eventlogs para reportar misiones. Para
		hacerlo, edita el archivo de configuraci&oacute;n de FB (o PF)
		&quot;conf.ini&quot; en tu carpeta FB: comprueba que estas l&iacute;neas
		y valores est&aacute;n presentes en la secci&oacute;n &quot;[game]&quot;:
				</P> 
		<CENTER> 
			<TABLE BORDER=1 CELLPADDING=0 CELLSPACING=2> 
				<COL WIDTH=450> 
				<TR> 
					<TD> 
						<P LANG="en-GB">[game]<BR>.<BR>.(several
						lines)<BR>.<BR><B>eventlog=coop.txt</B><BR><B>eventlogkeep=0</B></P> 
					</TD> 
				</TR> 
			</TABLE> 
		</CENTER> 
		<P><li>
		Con <B>eventlogkeep=0</B> lo que hacemos es indicarle
		al juego que cada coop.txt sobreescriba al anterior, por lo que si
		por alg&uacute;n motivo quieres conservar un coop.txt deber&aacute;s
		hacerle una copia de seguridad antes de volar la siguiente misi&oacute;n.
				</P> 
		<P><li>
		Para reportar una misi&oacute;n, simplemente entra en
		la p&aacute;gina <B>Reportar</B> y sigue las instrucciones. 
		</P> 
	</ul>
	
		<H2><A NAME="hostrec"></A>Configuraciones recomendadas para Hosts</H2> 
	
		<ul>
		<P><li>
		Trata de hostear para n&uacute;mero m&aacute;ximo de
		jugadores que sepas que tu conexi&oacute;n puede soportar. Se
		recomiendan 10kbits de subida por jugador. Puedes comprobar tu
		velocidad de subida en esta p&aacute;gina:
		<A HREF="http://www.pcpitstop.com/internet/default.asp">http://www.pcpitstop.com/internet/default.asp</A> 
				</P> 
		<P><li>
		No se recomiendan los reinicios (restarts) si se
		pierden menos de tres aviones. si se pierden 3 o m&aacute;s
		aviones, puedes pedir el reinicio en el chat. El Host decide. Si
		hay muchos aviones destruidos, y tu bando (okl/vvs) no est&aacute;
		afectado, se recomienda ofrecer el reinicio como muestra de buena
		actitud. 
		</P> 
		<P><li>Se recomienda para hostear, sin importar qu&eacute;
		conexi&oacute;n se tenga, establecer la network speed del host a
		14,4 kbits. Puedes forzar autom&aacute;ticamente 14,4 kb en FB&nbsp;
		editando tu archivo de configuraci&oacute;n de Hypperlobby
		&quot;hlpro.ini&quot; y a&ntilde;adiendo la l&iacute;nea
		&quot;serverRate=2000&quot;: 
		</P> 
		<CENTER> 
			<TABLE BORDER=1 CELLPADDING=0 CELLSPACING=2> 
				<COL WIDTH=450> 
				<TR> 
					<TD> 
						<P LANG="en-GB">[Forgotten
						Battles]<BR>joinDelay=20<BR>clientRate=2000<BR><B>serverRate=2000</B></P> 
					</TD> 
				</TR> 
			</TABLE> 
		</CENTER> 
		<P><li>
		Settings de MaxLag recomendados: para hacerlo, edita
		el archivo de configuraci&oacute;n de FB (o PF) &quot;conf.ini&quot;
		en tu carpeta FB, comprobando que estas l&iacute;neas y valores
		est&aacute;n presentes: 
		</P> 
		<CENTER> 
			<TABLE BORDER=1 CELLPADDING=0 CELLSPACING=2> 
				<COL WIDTH=450> 
				<TR> 
					<TD> 
						<P LANG="en-GB">[MaxLag]<BR>farMaxLagTime=2<BR>nearMaxLagTime=1<BR>cheaterWarningDelay=1<BR>cheaterWarningNum=1</P> 
					</TD> 
				</TR> 
			</TABLE> 
		</CENTER> 
		<P><li>
		Settings de comprobaci&oacute;n de velocidad
		recomendados: para hacerlo, eedita el archivo de configuraci&oacute;n
		de FB (o PF) &quot;conf.ini&quot; en tu carpeta FB: comprueba que
		estas l&iacute;neas y valores est&aacute;n presentes en la secci&oacute;n
		&quot;[NET]&quot;: 
		</P> 
		<CENTER> 
			<TABLE BORDER=1 CELLPADDING=0 CELLSPACING=2> 
				<COL WIDTH=450> 
				<TR> 
					<TD> 
						<P LANG="en-GB">[NET]<BR>.<BR>.(several
						lines)<BR>.<BR><B>checkServerTimeSpeed=1</B><BR><B>checkClientTimeSpeed=1</B><BR><B>checkTimeSpeedDifferense=0.05</B><BR><B>checkTimeSpeedInterval=5</B></P> 
					</TD> 
				</TR> 
			</TABLE> 
		</CENTER> 
		<P><li>
		Desactivar la descarga de skins <B>(Skin Download Of)</B> 
		siempre ayuda a reducir el tr&aacute;fico en la red. 
		</P> 
	</ul>
		<H2><A NAME="puntu"></A>DZ : Sistema de Puntuaci&oacute;n</H2> 
		<P ALIGN=JUSTIFY>Antes de empezar a
		hablar de puntuaciones, se deber&iacute;a hacer una explicaci&oacute;n
		de los &iacute;ndices que afectan a los puntos. Despu&eacute;s de
		eso, quiz&aacute; tambi&eacute;n quiera comprobar la <A HREF="tasks.html">p&aacute;gina
		de explicaci&oacute;n de roles</A> para comprender por qu&eacute;
		algunas tareas dan puntos tras conseguir derribos a&eacute;reos o
		terrestres. 
		</P> 
		<H3>Indice
		de Experiencia</H3> 
		<P ALIGN=JUSTIFY>El &iacute;ndice de
		experiencia es una forma de demostrar c&oacute;mo de bueno es su
		piloto virtual actual. Cuando se comienza con un nuevo piloto
		virtual (primera misi&oacute;n, o primera misi&oacute;n despu&eacute;s
		de kia/mia), la experiencia de tu piloto se establece en 1 (o
		100%). Entonces, mientras mantengas vivo a tu piloto, la
		experiencia crece. Nunca decrecer&aacute;. En la tabla de abajo
		puedes ver qu&eacute; acciones o eventos propician cambios en la
		experiencia de tu piloto. Una vez que el piloto muere, la
		experiencia vuelve a establecerse en 1 (o 100%). 
		</P> 
		<P ALIGN=CENTER><A NAME="_x0000_i1031"></A> 
		<IMG SRC="images/exp_diff.gif" NAME="gr&aacute;ficos7" ALT="Experience modificators" ALIGN=BOTTOM WIDTH=313 HEIGHT=140 BORDER=0></P> 
		<P>Este &iacute;ndice
		afectar&aacute; a los puntos conseguidos en la misi&oacute;n. Por
		ejemplo, si la experiencia de tu piloto despu&eacute;s de 8
		misiones vivo es 1,23 (123%), los puntos de la misi&oacute;n se
		incrementan en un 23%. La mala noticia es que al tiempo que tu
		experiencia crece, la <B>recompensa por tu cabeza </B>aumenta
		tambi&eacute;n. Esto sucede porque en cada derribo a&eacute;reo los
		puntos conseguidos se determinan en funci&oacute;n de la
		experiencia del piloto derribado.</P> 
		<P>Digamos que vuelas una
		misi&oacute;n, y que conseguir&aacute;s 10m puntos por cada caza
		derribado. Si derribas un AI Veterano (experiencia de 0.8 &oacute;
		80%), conseguir&aacute;s s&oacute;lo 8 puntos. Pero si derribas a
		un humano experto, con una puntuaci&oacute;n de experiencia de 1.68
		(o 168%), conseguir&aacute;s 17 puntos.</P> 
		<P>Este &iacute;ndice
		consigue dos cosas: una es fomentar que mantengas vivo a tu piloto
		virtual, de esta manera consigues m&aacute;s puntos. La segunda es
		establecer la cantidad de puntos en un derribo a&eacute;reo. Todos
		sabemos que no es lo mismo derribar a la m&aacute;quina que a un
		humano. Por lo tanto, tenemos puntuaci&oacute;n <I><B>din&aacute;mica
		</B></I>por derribo, basada en la experiencia del piloto.</P> 
		<P>Cuando rescatas a un
		piloto, tu experiencia crece un 0,1 (10%), porque aprendes del
		piloto que acabas de salvar.</P> 
		<H3>Indice
		de Juego Limpio (FairPlay)</H3> 
		<P>El &iacute;ndice de
		Juego Limpio funciona como el de la experiencia, pero con algunas
		diferencias. Una es que el valor m&aacute;ximo del &iacute;ndice de
		Juego Limpio es 100%. Esto representa el grado en que sigues las
		recomendaciones. En DZ no va contra las reglas usar el humo o
		disparar a paracaidistas. Pero como a la mayor&iacute;a de la gente
		no le gustan estas acciones, cada vez que se detecta una acci&oacute;n
		&quot;no recomendable&quot;, el &iacute;ndice de juego limpio
		decrece.</P> 
		<P ALIGN=JUSTIFY>La siguiente tabla
		muestra en qu&eacute; grado algunas acciones har&aacute;n bajar el
		&iacute;ndice de Juego Limpio. Los puntos totales de la misi&oacute;n
		se ven afectado por este &iacute;ndice. 
		</P> 
		<P ALIGN=CENTER><A NAME="_x0000_i1032"></A> 
		<IMG SRC="images/fairplay.gif" NAME="gr&aacute;ficos8" ALT="Fairplay modificators" ALIGN=BOTTOM WIDTH=314 HEIGHT=155 BORDER=0></P> 
		<P>Por tanto, este &iacute;ndice
		es como un castigo autom&aacute;tico. Se recobra en fracciones del
		5% si vuelas sin romper las recomendaciones. Si quieres conseguir
		todos los puntos de las misiones, mejor que mantengas este &iacute;ndice
		al 100%. Esto tambi&eacute;n se requiere para conseguir medallas.
		si se te otorga una medalla y tu &iacute;ndice de Juego Limpio est&aacute;
		por debajo del 100%, &eacute;sta se retrasar&aacute; hasta que
		recuperes el 100% de Juego Limpio.</P> 
		<P>Cuando rescatas a un
		piloto, tu &iacute;ndice de Juego Limpio se establece en 100% como
		recompensa.</P> 
		<H3>Puntos
		por derribo</H3> 
		<P ALIGN=JUSTIFY>La siguiente tabla
		muestra la cantidad de puntos que se consiguen por cada derribo
		dependiendo de tu rol en la misi&oacute;n. 
		</P> 
		<P ALIGN=CENTER><A NAME="_x0000_i1033"></A> 
		<IMG SRC="images/kill_table.gif" NAME="gr&aacute;ficos9" ALT="Points by ground or airkills kills" ALIGN=BOTTOM WIDTH=517 HEIGHT=236 BORDER=0></P> 
		<H3>Puntos
		de Misi&oacute;n por Roles</H3> 
		<P ALIGN=JUSTIFY>La siguiente tabla
		muestra la cantidad de puntos bas&aacute;ndose en el rol
		desempe&ntilde;ado. Cada rol tiene una condici&oacute;n distinta,
		por lo que en DZ se pueden obtener resultados diferentes en el
		mismo bando. Si desempe&ntilde;as el rol de escolta de un grupo de
		bombarderos y todos regresan vivos, conseguir&aacute;s el m&aacute;ximo
		de puntos. Al mismo tiempo, los bombarderos necesitan destruir el
		objetivo para conseguir m&aacute;s puntos de misi&oacute;n 
		</P> 
		<P ALIGN=CENTER><A NAME="_x0000_i1034"></A> 
		<IMG SRC="images/task_points.gif" NAME="gr&aacute;ficos10" ALT="Mission points by task/goals" ALIGN=BOTTOM WIDTH=431 HEIGHT=395 BORDER=0></P> 
		<H3>Otras
		Puntuaciones</H3> 
		<P ALIGN=JUSTIFY>Finalmente, aqu&iacute;
		aparecen otros eventos puntuables</P> 
		<P ALIGN=CENTER><A NAME="_x0000_i1035"></A> 
		<IMG SRC="images/other_pnts.gif" NAME="gr&aacute;ficos11" ALT="Other points by events" ALIGN=BOTTOM WIDTH=311 HEIGHT=138 BORDER=0></P> 
		<BR><BR>
		
	  <h2><A NAME="howhost"></a>C&oacute;mo generar una misi&oacute;n</h2> 
		<P> 
		Lo primero que hay que hacer es acceder a la p&aacute;gina del
		<B>Generador</B>. Una vez all&iacute;, el piloto que vaya a hacer
		de host seleccionar&aacute; uno de los tres slots llamados <I>Host
		DZ</I>, tras lo cual se le requerir&aacute; su nombre, contrase&ntilde;a
		y el n&uacute;mero de aviones que participar&aacute;n en la misi&oacute;n.
		Tras introducir estos datos, ser&aacute; llevado de nuevo al
		generador, y debajo de su nombre aparecer&aacute;n los dos slots
		para que cada bando haga su <B>request</B> correspondiente (LW para
		el bando alem&aacute;n y ALI para los Aliados). El request no tiene
		por qu&eacute; hacerlo el host, puede ser realizado por <B>cualquier
		piloto con derechos de planificaci&oacute;n que tome parte en la
		misi&oacute;n</B>.</P> 
		<P> 
		El siguiente paso es elaborar el request. Para ello, el piloto que
		lo haga deber&aacute; pinchar sobre el slot correspondiente a su
		bando, con lo que se le llevar&aacute; a una p&aacute;gina en la
		que aparece una tabla para seleccionar el objetivo, los aviones de
		defensa/ataque y los mapas actuales.</P> 
		<P> 
		El resto es sencillo: seleccionar un objetivo conforme a lo que se
		explic&oacute; en la secci&oacute;n <I>DZ: C&oacute;mo Funciona</I> 
		y repartir los aviones de ataque/defensa como mejor se estime.</P> 
		<P> 
		Una vez realizados los requests de ambos bandos (y tras refrescar
		la p&aacute;gina del generador) al Host le aparecer&aacute; la
		opci&oacute;n de descargar la misi&oacute;n. Esta descarga de debe
		realizar en la carpeta que se quiera pero dentro de la ruta
		\Missions\net\coop\ del juego. Lo m&aacute;s apropiado ser&iacute;a
		crear una carpeta que se llamara DZ en esa ruta, para que las
		misiones no se mezclen con otras, pero esto queda a juicio de cada
		cual.</P> 
		<P> 
		Y ya lo &uacute;nico que falta es lanzar la misi&oacute;n desde el
		HL, y a volar.</P> 
		<P><BR>Manual version 2. <BR><BR></P> 
		
				</td>					
			</tr>
			
			<!---------- CONTENIDO DE LA PAGINA END ------------>
			
<br><br>
<br>

<?php 
include ("./dz_page_footer.php");
?>
