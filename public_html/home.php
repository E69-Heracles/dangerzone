<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>
			<img class="modal_map" src="<?php echo $RELATIVE_DYNAMIC_FRONT; ?>/front.jpg" WIDTH="675" HEIGHT="585" BORDER=0/>
			
			<table cellpadding="0" cellspacing="0" width="835px" border=0>
			<tr>
				<td colspan="3"><img src="images/header2.jpg"/></td>
			</tr>
			<tr>
				<td width="297px" valign="bottom">
				
					En Danger Zone los pilotos se dividen en dos bandos que luchan por la victoria. La campa�a consta de varios 
					mapas consecutivos que cambian cuando uno de los dos bandos en competici�n alcanza las condiciones de victoria. 
					BADC, el software que gestiona la campa�a mantiene estad�sticas de pilotos y escuadrones, y tiene un motor 
					online que permite planificar, generar y descargar las misiones justo antes de volarlas. <br/><br/>
						
			<?php 
						include ("./points.php");
			?>
			
			<!--		<table width="100%">
						<tr>
							<td>&nbsp;</td>
							<td width="104px">
								<a href="/foro/index.php?board=7.0" target="main"><img src="images/luftwaffe_logo.gif" border="0"/></a>
							</td>
							<td>&nbsp;</td>
							<td width="104px">
								<a href="/foro/index.php?board=6.0" target="main"><img src="images/ws_logo.gif" border="0"/></a>
							</td>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td/>
							<td align="middle"><a href="/foro/index.php?board=7.0" style="font-size:9px">Foro Aleman</a></td>
							<td/>
							<td align="middle"><a href="/foro/index.php?board=6.0" style="font-size:9px">Foro Aliado</a></td>
							<td/>
						</tr>
					</table>  -->
					<br/>
					Para mas informaci�n, consulta el <a href="manual.php">Manual</a>,  
					accede a nuestro <a href="/foro/index.php" target="main">Foro General</a> o 
					si ya eres parte de un bando accede directamente al 
					<a href="/foro/index.php?board=7.0">Foro Aleman</a> o
					al <a href="/foro/index.php?board=6.0">Foro Aliado</a>.
				</td>
				<td width="240" align="center" valign="bottom">
					<img src="images/lilya.jpg" alt="�Dejar de mirarme las medallas que me poneis nerviosa!">
				</td>
				<td width="297px" valign="bottom">
					
					<?php
					$file = $PATH_DYNAMIC_TXT . "/" . "Status.txt";
					$contents = file($file);
					echo $contents[0];
					echo $contents[1];
					?>
			
					<a href="<?php echo $RELATIVE_DYNAMIC_MAP; ?>/mapa.html"><img id="map_icon" src="images/map_banner_kursk.jpg" border="2"></a><br/><br/>
					Para volarla, basta con que te conectes en el <a href="http://hyperfighter.sk/" target="main">HyperLobby</a> en alguna de las partidas 
					que se lanzan diariamente en <b>Teamplay Room</b>, pero te rogamos encarecidamente que te leas antes el manual. 
					Si te gusta la experiencia, puedes solicitar el alta de piloto en esta misma web o de tu escuadr�n en 
					el foro.<br/><br/> 
						
					Actualmente se montan partidas tarde y noche diariamente, que es cuando m�s pilotos espa�oles est�n conectados, 
					pero tambi�n se vuela en otros horarios y en el foro se pueden convocar u organizar partidas con antelaci�n. 
				</td>
			</tr>
			<tr>
				<td colspan="3"><br/><br/><br/></td>
			</tr>
			<tr>
				<td colspan="3" class="section_header">
					<span class="section_header_txt">�ltimas Noticias de la Danger Zone</span><br/><br/></td>				
			</tr>
			
			<tr class="section_subheader" height="30px"> 
				<td colspan="2"> 
					<span class="section_subheader_txt">Finalizaci�n de Lvov 1.941</span>&nbsp;&nbsp;
					<span style="font-size:9px">[E69_espiral]</span><br/></td> 
					<td align="right" style="font-size:9px">4 de Agosto de 2011</td>
			</tr>	
			<tr>
				<td colspan="3">
					<b>Preparando el siguiente mapa: Smolensk 41</b><br/>					
<p>El mapa de <b>Lvov-1.941</b> ha terminado tras <b>86 misiones</b> voladas (poco menos de 3 d�as virtuales), pero el tiempo ha cundido como si fuese mucho m�s.</p>

<p>Ha estado muy re�ido, con momentos en los que parec�a que en la siguiente misi�n el Bando Rojo iba a ganar el mapa y momentos en los que parec�a que era el Bando Azul el que pod�a vencer. Finalmente la fortuna ha favorecido al Bando Alem�n, pero en honor a la verdad hay que decir que no hubi�semos podido ganar sin la participaci�n del <b><i>Escuadr�n Mercenario</i></b>, por lo que realmente creo que la Victoria es m�s suya que nuestra y la derrota no es de nadie.</p>

<p>Una de las cuestiones que a mi personalmente m�s me ha gustado es que parece que los pilotos comienzan a concienciarse de que la conservaci�n del propio avi�n y, sobre todo, de la  vida, son fundamentales.</p>

<p>Otro aspecto muy positivo es que la propuesta de <b><i>E69_Chapas</i></b> de creaci�n de ese <b><i>Escuadr�n Mercenario</i></b> para que quienes lo integran pudieran volar indistintamente en cualquiera de los bandos donde faltasen pilotos fue un magn�fico acierto.</p>

<p>El siguiente mapa a volar ser� tambi�n en el Frente del Este, concretamente <b>Smolensk-1.941</b> (190x170 Kms.). No se introduce ninguna novedad, a la espera de que <b><i>E69_Heracles</i></b> acabe de ultimar el nuevo sistema de <b>"Inventario y Suministro"</b>, que casi con toda seguridad entrar� en funcionamiento cuando finalice Smolensk.</p>

<p>La �nica salvedad es que, siendo un mapa con <b>19 AFs</b>, quedar� restablecida la condici�n de que los aviones de SUM aterricen en un radio determinado de la ciudad a suministrar.</p>

<p>El "planeset" es bastante parecido, para ambos bandos, al reci�n terminado mapa de <b>Lvov-1.941</b>, pero se incorporan un par de tipos nuevos en el bando Ruso.</p>

<p>Os animo a todos los que ya hab�is volado a seguir haci�ndolo, y a los que no os hay�is estrenado todav�a a apuntaros y participar en la Campa�a.</p>

<p>Aprovecho para dar las gracias a <b><i>E69_Kras</i></b> y a <b><i>E69_McField</i></b>, que han tenido la generosidad de ofrecer sus conocimientos y su tiempo para contribuir al desarrollo de la nueva p�gina web (que pr�ximamente ver�n Vds. en sus pantallas). Y a <b><i>E69_Outlaw</i></b> por los mismos motivos que le han llevado a iniciar el desarrollo de una Campa�a en <b>"El Alamein"</b>.</p>

<p>Y por supuesto, nuestro agradecimiento a todos los que particip�is en las <b><i>DZ</i></b> de una u otra forma, porque sin vosotros la <b><i>DangerZone</i></b> no tendr�a sentido.</p>

<p>Pero, como he dicho anteriormente, quiero hacer una menci�n muy especial al <b><i>Escuadr�n Mercenario (mEr69)</i></b>, porque siendo una pieza fundamental del desarrollo de las misiones no se llevar�n jam�s una Victoria de forma "oficial", lo que implica un doble sacrificio que espero que sepamos valorar en lo que vale: mi consideraci�n y mi respeto para todos ellos.</p>

<p>Saludos.</p>

				</td>
			</tr>							
			
			
			<tr class="section_subheader" height="30px"> 
				<td colspan="2"> 
					<span class="section_subheader_txt">Nueva campa�a Lvov 1.941</span>&nbsp;&nbsp;
					<span style="font-size:9px">[E69_espiral]</span><br/></td> 
					<td align="right" style="font-size:9px">24 de Junio de 2011</td>
			</tr>	
			<tr>
				<td colspan="3">
					<b>Primera campa�a para la DangerZone 2.0</b><br/>					
<p>Este mapa tiene una serie de caracter�sticas que lo hacen un tanto especial: es peque�o y contiene numerosos Sectores completamente cubiertos de bosque y marasmos de r�os que se entrecruzan, por lo que muchos de esos Sectores (debido al generador de la DZ) no son atacables por tierra. Hemos intentado que todos los Sectores que tienen ubicada una ciudad con SUM y/o un AF sean atacables desde el mayor n�mero posible de Cuadr�culas adyacentes. Pero �sto implica que, en muchos de esos Sectores, el Campamento de Defensa y el Grupo de Tanques atacantes comiencen mucho m�s pr�ximos que en otros mapas, por lo que la labor defensiva/ofensiva en el aire ser�, casi con seguridad, decisiva. A�n as� hay zonas hu�rfanas de SUM en las que no se han puesto ciudades a bombardear debido a que tanto el Sector de ubicaci�n de la propia ciudad como las adyacentes resultan inatacables. Para tratar de "cubrir" esas zonas, hemos aumentado el radio habitual de SUM de algunas ciudades.</p>

<p><b>LVOV-1.941</b> cuenta �nicamente con <b>5 AFs</b> en todo el mapa, por lo que la cuesti�n comentada al principio sobre la <b>Supervivencia del piloto</b> y la <b>Conservaci�n del propio avi�n</b> ser�n fundamentales para tratar de mantener operativos los AFs.

Debido a la existencia de s�lo esos 5 AFs, y a las caracter�sticas del terreno, <b>los aviones de SUM podr�n aterrizar (s�lo para este mapa) en cualquiera de los AFs de su propio bando</b>.

"PLANESET"<br/><br/>


<b>RUSOS:</b><br/><br/>

Escolta a BA, SUM<br/>
<ul>
   <li>I-16 Type 18</li>
   <li>I-16 Type 18 (2xBS)</li>
   <li>I-16 Type 24</li>
   <li>MIG-3ud standard 1941</li>
   <li>YAK-1</li>
</ul>
Interceptores<br/>
<ul>
   <li>I-16 Type 18</li>
   <li>I-16 Type 18 (2xBS)</li>
   <li>I-16 Type 24</li>
   <li>MIG-3ud standard 1941</li>
   <li>YAK-1</li>
</ul>
Escolta a BD y AT (Jabo)<br/>
<ul>
   <li>I-16 Type 18</li>
   <li>I-16 Type 18 (2xBS)</li>
   <li>I-16 Type 24</li>
   <li>MIG-3ud standard 1941</li>
   <li>YAK-1</li>
</ul>
BD y AT<br/>
<ul>
   <li>IL-2M 1941 1 series</li>
   <li>I-153P</li>
   <li>I-153 M62</li>
</ul>
BA<br/>
<ul>
   <li>DB-3B</li>
   <li>DB-3F</li>
   <li>DB-3M</li>
   <li>PE-2 Series 1</li>
   <li>SB-2 M-100A</li>
   <li>SB-2 M-103</li>
   <li>SU-2</li>
   <li>TB-3</li>
</ul>
SUM<br/>
<ul>
   <li>LI-2</li>
</ul>

<p>Si bien los I-153, en sus dos modelos, fueron utilizados tambi�n como Bombarderos, los hemos quitado de ese "rol" debido a su escas�sima carga b�lica para ese cometido. Se ha suprimido del "planeset" el Polikarpov-2/U2, ya que seg�n las tablas utilizadas s�lo hac�a misiones nocturnas de bombardeo y suministro.</p>

<p>En las tablas de "Yogy" menciona �nicamente el I-16 TYPE 18, pero hemos optado por incluir tambi�n, ya que el HSFX v. 5.01 lo permite, el modelo I-16 TYPE 18 (2xBS), que tiene capacidad de portar cohetes, adem�s de bombas. El n�mero de cada modelo es la mitad del total.</p>


<b>ALEMANES:</b><br/><br>
Escolta a BA, SUM<br/>
<ul>
  <li>CR.42 Hungarian</li>
  <li>Bf109-F2</li>
  <li>Bf109-F4</li>
</ul>
Interceptores<br/>
<ul>
  <li>CR.42 Hungarian</li>
  <li>Bf109-F2</li>
  <li>Bf109-F4</li>
</ul>
Escolta a BD y AT (Jabo)<br/>
<ul>
  <li>CR.42 Hungarian</li>
</ul>
BD y AT<br/>
<ul>
  <li>HS-123</li>
  <li>Bf109-E4B</li>
  <li>Bf109-E7B</li>
  <li>BF-110C-4B</li>
  <li>JU-87B2</li>
</ul>
BA<br/>
<ul>
  <li>HE-111 H-2</li>
  <li>HE-111 H-6</li>
  <li>JU-88A4</li>
</ul>
SUM<br/>
<ul>
  <li>JU 52/3mg6e  Tante Ju</li>
</ul>					
				</td>
			</tr>				
			<tr class="section_subheader" height="30px"> 
				<td colspan="2"> 
					<span class="section_subheader_txt">DangerZone 2.0</span>&nbsp;&nbsp;
					<span style="font-size:9px">[E69_espiral]</span><br/></td> 
					<td align="right" style="font-size:9px">22 de Junio de 2011</td>
			</tr>	
			<tr>
				<td colspan="3">
					<b>Ya la tenemos aqu�: disfrut�mosla</b><br/>
<p>El mapa de <b>Kursk-1.943</b> ha terminado. Ha durado bastante menos de lo previsto, aunque ha servido con creces para probar los "bugs" corregidos y las nuevas caracter�sticas implementadas.</p>

<p>Ha quedado demostrado que, tal como pretend�amos, la conservaci�n del propio avi�n y de la vida del piloto marcan, en muy buena medida, el desarrollo de la Campa�a, por lo que parece necesario que los participantes de ambos bandos tomen conciencia de esta cuesti�n: a veces resulta m�s rentable no perder aviones/pilotos que conseguir el objetivo de la misi�n a toda costa.</p>

<p>Era nuestra intenci�n que, antes de lanzar la <b>DZ 2.0</b>, el siguiente mapa fuese el de <b>Normand�a-1.944</b>, pero, debido a la duraci�n del anterior, no hemos tenido tiempo de terminarlo y le quedan un m�nimo de un par de semanas. As� que empezaremos de nuevo en el <b>Frente Oriental</b> e iremos volando, de forma m�s o menos cronol�gica, los diferentes mapas de aquel teatro b�lico. El motivo es que los primeros de esos mapas (Lvov, Bessarabia, Kiev, Smolensk, etc.) ya estaban hechos. No obstante, y a medida que  vayamos generando los mapas correspondientes, nos gustar�a ir alternando el Frente Oriental con el Frente Occidental. Tampoco descartamos, si somos capaces de solucionar una serie de cuestiones t�cnicas en los mapas con grandes extensiones de mar, a�adir Campa�as en el Pac�fico, Mediterr�neo, Canal de La Mancha, etc.</p>

<p>Esta nueva fase de la <b>DZ 2.0</b> se volar� con el <b>HSFX v.5.01</b>, ya que aporta interesantes caracter�sticas de las que enumeraremos unas cuantas que nos parecen las m�s relevantes.</p>

<p>El <b>HSFX v5.01</b> se instala sobre una copia "limpia" de la versi�n <b>4.10.1</b> del IL-2. En esta versi�n (4.10.1) se corrigieron los FM (modelos de vuelo) de algunos Bombarderos, de forma que se comportan como tales y no como Cazas; se a�adi� el da�o provocado por el exceso de G's a la estructura de los aviones; se a�adi� la navegaci�n realista mediante radio-balizas y otros sistemas de navegaci�n; los artilleros ya no son aut�nticos francotiradores; y otra serie de cuestiones que ser�a muy largo enumerar.</p>

<p>El <b>HSFX v5.01</b> a�ade otra serie de caracter�sticas que nos parecen muy adecuadas para este tipo de Campa�as Cooperativas: el "*.log" de la misi�n recoge la altura de los aviones cuando se activa el humo de las alas y lo env�a al generador, con lo que resulta muy �til para las misiones de SUM. Adem�s abre las puertas a las misiones de <b>"Recon"</b>. Las bombas han sido modificadas (en todos los bandos en contienda: italianos, japoneses, rusos, aliados, alemanes, �) de tal forma que el radio de acci�n y los da�os ocasionados est�n en funci�n, no s�lo del tipo de bomba, sino  de la cantidad de Kgrs. de explosivo que porta y no del peso total de la propia bomba.</p>

<p>Otra de las caracter�sticas m�s que atractiva que incluye el <b>HSFX v5.01</b> es la posibilidad de establecer <b>F�bricas</b> (en realidad son zonas previamente fijadas en el mapa y que simulan la producci�n de f�bricas), con lo que se abre tambi�n la posibilidad de reponer aviones en la medida en que dichas f�bricas permanezcan activas.</p>

<p>Se van a resetear las Estad�sticas, tanto personales como de Escuadrones, por lo que ser� necesario que los pilotos que deseen participar vuelvan a registrarse como tales, den de alta los distintos Escuadrones y se unan a ellos. Habr� tiempo suficiente para hacerlo y, tal como se ha dicho repetidamente, como es una Campa�a en equipo, no se permitir� participar en ninguna misi�n si previamente alg�n piloto no est� registrado y forma parte de alguno de los Escuadrones en activo. Ser�a deseable que los responsables de cada Escuadr�n fuesen pilotos que volasen asiduamente para que pudiesen gestionar con inmediatez las Altas en sus filas.</p>

<p>Queremos introducir varias modificaciones m�s. Algunas parecen f�ciles (se lo parecen a E69_Heracles, que es como el Genio de la l�mpara de Aladino), pero a�n as� el tiempo escasea, por lo que las novedades ir�n llegando poco a poco. Algunas de  ellas se implementar�n sobre la marcha, puede que en este mapa o en alguno de los pr�ximos. Tenemos bastantes cuestiones a modificar, pero sabemos que algunas de ellas llevar� mucho tiempo lograrlas y otras puede que resulten imposibles. Como ejemplos, varias cuestiones que nos gustar�a hacer pero a�n no sabemos (quiero decir que E69_Heracles a�n no lo sabe, pero lo sabr�; los dem�s jam�s llegaremos a tener idea siquiera) si ser�n posibles:</p>

<ul>
	<li>Cuando un piloto resulte muerto o capturado los derribos (u objetivos
	terrestres destru�dos) NO contabilizar�n en sus Estad�sticas personales, pero
	s� se sumar�n a las p�rdidas del bando enemigo.</li>
	<li>Para las misiones de Bombardeo (BA) los aviones saldr�n aleatoriamente,
	igual que pasa con los cazas, en funci�n de la cantidad disponible de cada
	modelo y/o tipo.</li>
	<li>El control de altura de SUM (�sto ya lo tiene resuelto para los SUM
	humanos, pero puede que no sea posible con los IAs).</li>
</ul>


<p>Otras modificaciones a m�s largo plazo, debido a su complejidad, pero que E69_Heracles ya sabe c�mo hacer, aunque le llevar�n tiempo:</p>

<ul>
	<li>Nueva p�gina web.</li>
	<li>Inventario de aviones (n�mero total de aviones por modelo, del que se ir�n
	restando las p�rdidas, en cada mapa).</li>
	<li>Producci�n de F�bricas (que ir�n reponiendo los aviones perdidos).</li>
</ul>

<p>Estas tres �ltimas modificaciones se implementar�n de forma conjunta para que la producci�n de las f�bricas tenga repercusi�n sobre el n�mero de aviones total por mapa.</p>
				</td>
			</tr>					
					
			<tr class="section_subheader" height="30px"> 
				<td colspan="2"> 
					<span class="section_subheader_txt">Un nuevo impulso para renovar nuestra competici�n</span>&nbsp;&nbsp;
					<span style="font-size:9px">[E69_espiral]</span><br/></td> 
					<td align="right" style="font-size:9px">30 de Abril de 2011</td>
			</tr>	
			<tr>
				<td colspan="3">
					<b>Nuevas normas, nuevo mapa</b><br/>
<p> La <b>DangerZone</b> surgi� como una Campa�a-Cooperativa Inter-Escuadrones (de habla hispana) con dos objetivos principales:<br />
 <br />
1) Establecer una actividad conjunta entre todos los pilotos de los diferentes Escuadrones Virtuales que conformaban ambos bandos.<br />
2) Que dicha Campa�a fuese lo m�s hist�rica posible, sabiendo de antemano que era muy dif�cil lograrlo debido a la gran cantidad de informaci�n dispersa y a la disparidad de las fuentes consultadas en cuanto a "planesets" y dem�s aspectos operativos.</p>

<p> Si bien la primera finalidad se cumpli� con creces -aunque siempre es deseable pedir m�s-, el segundo prop�sito, por diferentes razones, comenz� a desvirtuarse poco a poco hasta diluirse por completo, haciendo que lo que hab�a nacido como una Campa�a-Cooperativa se convirtiese, en la pr�ctica, en una sucesi�n de "dogfights" con formato de cooperativa.<br />
 <br />
 Esto tuvo, b�sicamente dos causas: <br />
 <br />
 La primera fue la pretensi�n de lograr un "equilibrio t�cnico" en los "planesets", lo que condujo a una serie de peticiones que fueron "in crescendo" hasta desembocar en aut�nticos desprop�sitos que llevaron a la confecci�n de "planesets" totalmente alejados de la realidad hist�rica y que, adem�s, tuvieron el efecto contrario al buscado.<br />
 <br />
 La segunda, y no menos importante, fue que no se premiaba suficientemente la supervivencia del piloto y la conservaci�n del propio avi�n, lo que dio como resultado que la mentalidad de algunos participantes no fuese la de <b>volar una misi�n en equipo</b>, sino la de participar en una "dogfight" en la que lo �nico importante era hacer derribos, a�n a costa de resultar muerto, para incrementar las estad�sticas personales.<br />
 <br />
 Pero �sto ha iniciado un profundo proceso de cambio que no s�lo pretende que la DZ vuelva a sus or�genes, sino mejorar diversos aspectos de la Campa�a, tanto a nivel de programaci�n como de las normas que la rigen.<br />
 <br />
 Para ello se ha constitu�do un grupo de trabajo inter-Escuadrones que ya ha comenzado a desarrollar una serie de modificaciones y nuevas funcionalidades en el generador/parser, en las normas, en la web y en los Foros.<br />
 <br />
 Los primeros esfuerzos han estado destinados a darle a la DZ el mayor componente de <b>realidad hist�rica</b> del que hemos sido capaces. Este componente hist�rico est� limitado, adem�s de por lo anteriormente apuntado en referencia a los "planesets", por diferentes cuestiones del motor de la DZ y por la versi�n del <b>IL-2</b> (v. 4.09m) con la que actualmente se vuela la Campa�a. Algunas cuestiones est�n ya en estudio para ver su viabilidad t�cnica y, en muchos casos, se ir�n implementando en sucesivas versiones de la DZ, que finalmente se volar� con la <b>v. 4.11 del HSFX</b> inclu�do en el Ultrapack 2.01. �Por qu� este pack de MODs? A nuestro juicio tiene varias ventajas que vamos a tratar de resumir:<br />
 <br />
 Queda totalmente descartada, pues, la situaci�n de equilibrio entre los bandos en disputa en beneficio de la de realidad hist�rica.<br />
 <br />
 Se dar� <b>prioridad absoluta</b> a un concepto un tanto olvidado en la simulaci�n: <b>LA VIDA</b>. Durante la contienda ning�n piloto (salvo alg�n "bailed" en territorio propio) disfrutaba de una segunda oportunidad (REFLY), y todos eran conscientes de ello, anteponiendo la propia supervivencia y la de sus compa�eros sobre cualquier otra cosa.<br />
 <br />
 Por tanto, a partir de ahora, volver� a ser una Campa�a; es decir, que todas las acciones de una misi�n tendr�n consecuencias en las sucesivas. Puede haber alg�n piloto al que este planteamiento le parezca poco importante, pero, con seguridad, s� le importar� a su bando, porque le afectar� enormemente en el devenir de la Campa�a.<br />
 <br />
 Somos muy conscientes de que la DZ es una competici�n, que tiene car�cter l�dico y, si se quiere, formativo, pero sobre todo es una <b>Campa�a en equipo</b>, uno por bando, as� que no se permitir�n comportamientos individualistas tipo Server-Dog: <b>se exigir�</b>, en todo momento, una <b>actitud</b> acorde al esp�ritu necesario para intentar ganar una Campa�a de estas caracter�sticas. Tened en cuenta, adem�s, que cada <b>equipo</b> estar� integrado por pilotos de diferentes Escuadrones, por lo que ser� necesario un esfuerzo adicional de coordinaci�n para que el equipo/bando resulte cohesionado.<br />
 <br />
 En los respectivos Briefings de cada bando, en cada misi�n generada, se refleja de forma muy concisa, clara y comprensible cu�l es el objetivo de la misi�n de Ataque y de la de Defensa. As� que es necesario que <b>cada piloto</b> que ocupe un "slot" <b>lea y comprenda</b> cu�l es <b>su misi�n</b> y (salvo que su l�der decida lo contrario) se ci�a a ella.<br />
 <br />
 Dado que se potencia la supervivencia y se penaliza la muerte/captura, cada piloto/avi�n perdido penalizar� (bastante m�s que ahora) su Base de partida, haciendo que �sta tenga cada vez menos aviones disponibles que puedan operar desde ella y que la AAA de dicha Base vaya disminuyendo, con lo que resultar� un objetivo m�s f�cil y apetecible para el bando enemigo. �sto se simula da�ando el AF hasta un punto (80% de da�o) en que el AF es inoperativo, es decir no quedan m�s aviones que puedan despegar desde �l.<br />
 <br />
 Como paso previo al reinicio definitivo de la DZ, se volar� un primer mapa en el que se ir�n probando diversas modificaciones introducidas. La hemos denominado <b>DZ v. 1.93</b> y hemos escogido el <b>Mapa de Kursk en 1943</b> por varias razones:<br />
 <br />
 Kursk_43 est�, m�s o menos, situado a mitad de la contienda, momento en el que no hab�a una neta superioridad por parte de ninguno de los dos bandos, lo que nos proporciona una situaci�n ideal para poder valorar si los cambios introducidos son positivos para el desarrollo de la Campa�a.<br />
 <br />
 Estos cambios, que de momento son menores, son:<br />
 <br />
1) <b>"Planesets" hist�ricos</b>. A falta de poder reunir una informaci�n m�s abundante y exhaustiva, y a�n sabiendo que no es completo nos hemos decantado por el "planeset de Yogy", dado que hay acuerdo en que es lo m�s parecido, con todas sus carencias, a lo que hubo hist�ricamente. Hemos sumado las existencias de aparatos (para ambos bandos) en los mapas de Prokhorovka y Kursk, ya que la "Batalla de Prokhorovka" tuvo lugar dentro de la Ofensiva de Kursk (Operaci�n "Citadelle"). Los "roles" asignados a los diferentes tipos de aparatos son tambi�n en funci�n de las tablas de Yogy. Se han suprimido del c�mputo total los aviones destinados a misiones nocturnas y de Reconocimiento.</p>

<p>2) <b>Penalizaci�n por muerte/p�rdida de avi�n</b>. Ya funcionaba en la DZ (bajando la operatividad del AF de salida), pero con unos valores que no premiaban la supervivencia ni la conservaci�n del avi�n. As� que hemos modificado dichos valores para que ahora S� que sea m�s rentable sobrevivir que hacer un derribo. Este premio/penalizaci�n afectar�, en distinta medida, tanto a los humanos como a los IAs.</p>

<p><br />
3) En referencia al primer punto, Aviones de SUM que son de Transporte y no Bombarderos (Ju-52 y Li-2). Estos aviones, que con la v. 4.09m no son pilotables, s� lo son con el HSFX. Para tratar de "compensar" el mayor n�mero total de aviones del bando ruso, y dado que las misiones se generan para igual n�mero de pilotos/bando, se ha incrementado el "ratio" de SUM para el bando rojo en un peque�o porcentaje respecto del "ratio" alem�n. <br />
Los aviones de SUM deber�n aterrizar, obligatoriamente, en los AFs que est�n dentro de un radio de 30 Km. de la ciudad suministrada. En caso contrario la misi�n SUM ser� anulada por el parser tanto en la ciudad como en el AF, fracasando la misi�n al completo.</p>

<p>4) <b>Aumento del n�mero de Objetivos en las ciudades</b>. Hasta ahora los objetivos a bombardear sol�an estar situados en un solo grupo, con lo que resultaba bastante f�cil que un �nico Bombadero pudiese infligir un da�o como toda una Escuadrilla. Ahora se ha intentado que, en las ciudades, los objetivos est�n repartidos en varios grupos, con lo que se pretende que el da�o sufrido por el Bambardeo est� tambi�n en funci�n del n�mero de aviones atacantes y de la pericia de los pilotos.</p>

<p>5) <b>Supresi�n de la luz de Bombardeo</b>. M�s o menos a mitad de la actual DZ algunos pilotos solicitaron que en la Zona Objetivo de cada ciudad se colocase una luz para facilitar el bombardeo en altura. Tras m�s de 1.000 misiones voladas, los bombardeos en altura pueden contarse con los dedos de una mano. As� que hemos optado por suprimir esa "ayuda" para dar m�s realismo a la Campa�a. (Est� en estudio, para pr�ximas versiones, la viabilidad t�cnica de Misiones de Reconocimiento, que ubiquen con m�s precisi�n las zonas donde el enemigo ha emplazado sus SUM y/o sus tropas).<br />
6) <b>30 Misiones/D�a Virtual</b>. Tal como era en su origen, lo que permite aprovechar las ventajas t�cticas que uno de los bandos (o ambos) hayan podido obtener. Se entender� mejor al ver el punto siguiente.</p>

<p>7) <b>Corregido el TTL (Time To Live)</b>. El TTL se corresponde con las rayitas roja/verde que podemos ver en los distintos Sectores del Mapa. Significan el nivel de SUM de ese Sector: si un Sector est� sin Suministro, esa rayita (TTL), que tiene un valor de 30 puntos cuando est� al 100%, va disminuyendo un punto por misi�n hasta desaparecer cuando acaba el d�a virtual; en ese momento resulta m�s f�cil atacar con �xito el Sector que si estuviese suministrado (al no tener suministro est� menos defendido y es necesario un menor n�mero de tanques enemigos para conquistarlo). Al bajar el n�mero de misiones a 10/d�a virtual habr�a que haber corregido el TTL, pero no se hizo, por eso ahora da igual cu�nto est� suministrado un Sector: siempre, tienen que sobrevivir un n�mero de tanques atacantes, como si el Sector estuviese suministrado al 100%. Una vez corregido, el n�mero de tanques atacantes que tengan que sobrevivir para conquistar el Sector estar� en funci�n de los SUM de ese Sector, oscilando entre 2 y 7.</p>

<p><br />
8) <b>Corregido el "bug" de los 12 tanques</b>. En las misiones en las que ambos bandos hac�an ataque a Sector se produc�a un error que hac�a que el bando ruso atacase con 12 tanques (4 grupos de 3) en lugar de los 9 (3 grupos de 3) establecidos.</p>

<p>9) <b>Aumento y correcci�n de AAA en los AFs</b>. Hasta ahora cualquier Aer�dromo (AF) operativo al 100% dispon�a de 4 AAA de 85mm y 4 AAA de 20mm. Por otra parte, en alg�n momento de la DZ, se solicit� que se cambiase la AAA de 88mm alemana por la de 85mm rusa, ya que se "ten�a la impresi�n" (creo que lo dije yo mismo y sin ning�n dato objetivo que lo sustentase) de que era m�s efectiva esta �ltima. Ahora se incrementar� y cada bando dispondr� de la suya propia; es decir, los AFs rusos tendr�n 8x25mm, 2x37mm y 6x25mm. Iguales cantidades los AFs alemanes con sus propios calibres (88mm, 37mm y 20mm). Se aplicar� el mismo criterio a las zonas objetivos de BA de las ciudades.</p>

<p><br />
10) <b>Supresi�n de misiones nocturnas/tormenta</b>. Este tipo de misiones, que sin duda resultar�an muy interesantes si todos los pilotos fu�semos humanos, no lo son en la pr�ctica porque casi no hay misi�n en la que no exista alg�n "caza" IA, y es evidente que, a�n con el "skill" en "rookie" tienen una clara ventaja con respecto a los humanos: nos ven entre nubes y con oscuridad total, pero nosotros a ellos no. Por otra parte, ya que hemos suprimido de los "planesets" los aviones destinados a este tipo de misiones, no ser�a muy consecuente continuar vol�ndolas.</p>

<p>11) <b>Limitaci�n del n�mero de Bombarderos/SUM en funci�n del n�mero de pilotos/bando que vuelen la misi�n</b>. Las misiones de la DZ permiten fijar el n�mero de Bombarderos de Ataque (BA) y de Suministro (SUM) hasta un m�ximo de 6. No obstante, en ambos bandos venimos utilizando con demasiada frecuencia el m�ximo n�mero posible de ellos independientemente de si la Misi�n es generada para 4, 5 � 20 pilotos por bando. Por ello hemos considerado establecer un n�mero m�ximo de aparatos de BA/SUM que, de momento y mientras se comprueba si su proporci�n resulta id�nea, ser�: hasta 4 pilotos/bando, 2; hasta 6 pilotos/bando, 3, hasta 8 pilotos bando, 4; 10 � m�s pilotos/bando, 6.</p>

<p> </p>

<p> Todas estas modificaciones estar�n, en esta versi�n de la DZ, en fase de prueba: algunas sujetas a que funcionen correctamente, otras a que los valores que les hemos dado resulten adecuados (podr�an aumentar o disminuir), y todas (salvo los "bugs" corregidos) a que contribuyan a hacer la DZ m�s din�mica y atractiva de volar cada vez a m�s pilotos.<br />
 <br />
 Hay otras muchas cuestiones que est�n en estudio: SUM terrestres y mar�timos, misiones de Reconocimiento, misiones paracaidistas tras las l�neas enemigas, misiones de desembarco anfibio, producci�n de f�bricas, misiones de "BlitzKrieg" (ataque en profundidad a 2 Sectores en lugar de al inmediato a la l�nea del Frente), poder hacer Campa�as en mapas con dos letras por Sector (mapas m�s grandes como el de Besarabia), mapas con gran cantidad de Sectores de mar (Pac�fico, Mediterr�neo, Canal), etc. Algunas de ellas ser�n viables t�cnicamente y otras no. De las t�cnicamente posibles algunas se acabar�n implementando y otras, que no resulten positivas, no. Pero tened en cuenta que �nicamente contamos con un Programador (E69_Heracles), que, adem�s de obligaciones de trabajo, estudios, familia y necesidad de volar, dedica desinteresadamente muchas horas a estudiar, revisar y programar el c�digo de la DZ. Por eso, aunque todas las peticiones, cr�ticas y sugerencias son muy bien venidas, tened mucha paciencia, al menos tanta como tiene �l con nosotros y con el c�digo.<br />
 Una �ltima cuesti�n: todas las modificaciones y nuevas funcionalidades est�n pensadas para dar mayor dinamismo e inter�s a la DZ. Todas se han sopesado cuidadosamente y s�lo queda probarlas en Campa�a. En ning�n caso se ha pretendido favorecer o perjudicar a cualquiera de los bandos. As� que, como ha quedado dicho anteriormente, cualquier sugerencia ser� acogida favorablemente, pero <b>quedan totalmente exclu�dos</b> comentarios del tipo "es que vuestros aviones son mejores", "este avi�n tiene poca munici�n", etc. Cada bando tiene lo que ten�a hist�ricamente y no queda ninguna otra opci�n que aprovechar las ventajas propias e intentar que el enemigo no pueda aprovechar las suyas: <b>trabajo en Equipo</b>.<br />
 <br />
 Adem�s de reiterar el agradecimiento a "E69_Heracles" quiero hacerlo extensivo a otros muchos pilotos virtuales que, en mayor o menor medida, han contribu�do a hacer posible este proyecto: unos con sus conocimientos, consejos y sugerencias, otros con su apoyo, otros con sus gestiones, y muchos como "sufridos probadores":<br />
 <br />
 E69_cvchavo<br />
 E69_metaliving<br />
 E69_Patrel<br />
 E69_chapas<br />
 FAE_Cazador<br />
 FAE_Cormor�n<br />
 RedEye_Tumu<br />
 <br />
 Y, por supuesto, a quienes como "E69_vgilsoler" comenzaron este proyecto desde sus inicios.<br /><br />
</p>
				</td>
			</tr>
			<tr>
				<td colspan="3" class="section_header">
					<span class="section_header_txt">B.A.D.C.: El Motor de la Danger Zone</span><br/><br/></td>				
			</tr>			
			<tr>
				<td colspan="3">
					B.A.D.C. (Bourne Again Dynamic Campaign) es un motor de campa�as din�micas para  el IL2-FB. Fue desarrollado 
					en 2004 por <b>JG10r_Dutertre</b>, y se ha usado en algunas de las mejores competiciones online como 
					Bellum,CAD,Czec War,Mosquito, ...  <br/><br/>
					La Danger Zone 1.93 dise�ada por e <b>E69_espiral, E69_cvchavo, E69_Patrel, E69_Metaliving</b> y implementada por <b>E69_Heracles</b>, es una adaptaci�n del motor B.A.D.C.<br/><br/>
					Actualmente se vuela con <b>HSFX v5.01</b> sobre <b>IL-2 1946</b>.<br/><br/>
				</td>
			</tr>					
		</table>
<?php 
include ("./dz_page_footer.php");
?>