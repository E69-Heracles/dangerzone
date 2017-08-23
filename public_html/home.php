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
				
					En Danger Zone los pilotos se dividen en dos bandos que luchan por la victoria. La campaña consta de varios 
					mapas consecutivos que cambian cuando uno de los dos bandos en competición alcanza las condiciones de victoria. 
					BADC, el software que gestiona la campaña mantiene estadísticas de pilotos y escuadrones, y tiene un motor 
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
					Para mas información, consulta el <a href="manual.php">Manual</a>,  
					accede a nuestro <a href="/foro/index.php" target="main">Foro General</a> o 
					si ya eres parte de un bando accede directamente al 
					<a href="/foro/index.php?board=7.0">Foro Aleman</a> o
					al <a href="/foro/index.php?board=6.0">Foro Aliado</a>.
				</td>
				<td width="240" align="center" valign="bottom">
					<img src="images/lilya.jpg" alt="¡Dejar de mirarme las medallas que me poneis nerviosa!">
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
					Si te gusta la experiencia, puedes solicitar el alta de piloto en esta misma web o de tu escuadrón en 
					el foro.<br/><br/> 
						
					Actualmente se montan partidas tarde y noche diariamente, que es cuando más pilotos españoles están conectados, 
					pero también se vuela en otros horarios y en el foro se pueden convocar u organizar partidas con antelación. 
				</td>
			</tr>
			<tr>
				<td colspan="3"><br/><br/><br/></td>
			</tr>
			<tr>
				<td colspan="3" class="section_header">
					<span class="section_header_txt">Últimas Noticias de la Danger Zone</span><br/><br/></td>				
			</tr>
			
			<tr class="section_subheader" height="30px"> 
				<td colspan="2"> 
					<span class="section_subheader_txt">Finalización de Lvov 1.941</span>&nbsp;&nbsp;
					<span style="font-size:9px">[E69_espiral]</span><br/></td> 
					<td align="right" style="font-size:9px">4 de Agosto de 2011</td>
			</tr>	
			<tr>
				<td colspan="3">
					<b>Preparando el siguiente mapa: Smolensk 41</b><br/>					
<p>El mapa de <b>Lvov-1.941</b> ha terminado tras <b>86 misiones</b> voladas (poco menos de 3 días virtuales), pero el tiempo ha cundido como si fuese mucho más.</p>

<p>Ha estado muy reñido, con momentos en los que parecía que en la siguiente misión el Bando Rojo iba a ganar el mapa y momentos en los que parecía que era el Bando Azul el que podía vencer. Finalmente la fortuna ha favorecido al Bando Alemán, pero en honor a la verdad hay que decir que no hubiésemos podido ganar sin la participación del <b><i>Escuadrón Mercenario</i></b>, por lo que realmente creo que la Victoria es más suya que nuestra y la derrota no es de nadie.</p>

<p>Una de las cuestiones que a mi personalmente más me ha gustado es que parece que los pilotos comienzan a concienciarse de que la conservación del propio avión y, sobre todo, de la  vida, son fundamentales.</p>

<p>Otro aspecto muy positivo es que la propuesta de <b><i>E69_Chapas</i></b> de creación de ese <b><i>Escuadrón Mercenario</i></b> para que quienes lo integran pudieran volar indistintamente en cualquiera de los bandos donde faltasen pilotos fue un magnífico acierto.</p>

<p>El siguiente mapa a volar será también en el Frente del Este, concretamente <b>Smolensk-1.941</b> (190x170 Kms.). No se introduce ninguna novedad, a la espera de que <b><i>E69_Heracles</i></b> acabe de ultimar el nuevo sistema de <b>"Inventario y Suministro"</b>, que casi con toda seguridad entrará en funcionamiento cuando finalice Smolensk.</p>

<p>La única salvedad es que, siendo un mapa con <b>19 AFs</b>, quedará restablecida la condición de que los aviones de SUM aterricen en un radio determinado de la ciudad a suministrar.</p>

<p>El "planeset" es bastante parecido, para ambos bandos, al recién terminado mapa de <b>Lvov-1.941</b>, pero se incorporan un par de tipos nuevos en el bando Ruso.</p>

<p>Os animo a todos los que ya habéis volado a seguir haciéndolo, y a los que no os hayáis estrenado todavía a apuntaros y participar en la Campaña.</p>

<p>Aprovecho para dar las gracias a <b><i>E69_Kras</i></b> y a <b><i>E69_McField</i></b>, que han tenido la generosidad de ofrecer sus conocimientos y su tiempo para contribuir al desarrollo de la nueva página web (que próximamente verán Vds. en sus pantallas). Y a <b><i>E69_Outlaw</i></b> por los mismos motivos que le han llevado a iniciar el desarrollo de una Campaña en <b>"El Alamein"</b>.</p>

<p>Y por supuesto, nuestro agradecimiento a todos los que participáis en las <b><i>DZ</i></b> de una u otra forma, porque sin vosotros la <b><i>DangerZone</i></b> no tendría sentido.</p>

<p>Pero, como he dicho anteriormente, quiero hacer una mención muy especial al <b><i>Escuadrón Mercenario (mEr69)</i></b>, porque siendo una pieza fundamental del desarrollo de las misiones no se llevarán jamás una Victoria de forma "oficial", lo que implica un doble sacrificio que espero que sepamos valorar en lo que vale: mi consideración y mi respeto para todos ellos.</p>

<p>Saludos.</p>

				</td>
			</tr>							
			
			
			<tr class="section_subheader" height="30px"> 
				<td colspan="2"> 
					<span class="section_subheader_txt">Nueva campaña Lvov 1.941</span>&nbsp;&nbsp;
					<span style="font-size:9px">[E69_espiral]</span><br/></td> 
					<td align="right" style="font-size:9px">24 de Junio de 2011</td>
			</tr>	
			<tr>
				<td colspan="3">
					<b>Primera campaña para la DangerZone 2.0</b><br/>					
<p>Este mapa tiene una serie de características que lo hacen un tanto especial: es pequeño y contiene numerosos Sectores completamente cubiertos de bosque y marasmos de ríos que se entrecruzan, por lo que muchos de esos Sectores (debido al generador de la DZ) no son atacables por tierra. Hemos intentado que todos los Sectores que tienen ubicada una ciudad con SUM y/o un AF sean atacables desde el mayor número posible de Cuadrículas adyacentes. Pero ésto implica que, en muchos de esos Sectores, el Campamento de Defensa y el Grupo de Tanques atacantes comiencen mucho más próximos que en otros mapas, por lo que la labor defensiva/ofensiva en el aire será, casi con seguridad, decisiva. Aún así hay zonas huérfanas de SUM en las que no se han puesto ciudades a bombardear debido a que tanto el Sector de ubicación de la propia ciudad como las adyacentes resultan inatacables. Para tratar de "cubrir" esas zonas, hemos aumentado el radio habitual de SUM de algunas ciudades.</p>

<p><b>LVOV-1.941</b> cuenta únicamente con <b>5 AFs</b> en todo el mapa, por lo que la cuestión comentada al principio sobre la <b>Supervivencia del piloto</b> y la <b>Conservación del propio avión</b> serán fundamentales para tratar de mantener operativos los AFs.

Debido a la existencia de sólo esos 5 AFs, y a las características del terreno, <b>los aviones de SUM podrán aterrizar (sólo para este mapa) en cualquiera de los AFs de su propio bando</b>.

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

<p>Si bien los I-153, en sus dos modelos, fueron utilizados también como Bombarderos, los hemos quitado de ese "rol" debido a su escasísima carga bélica para ese cometido. Se ha suprimido del "planeset" el Polikarpov-2/U2, ya que según las tablas utilizadas sólo hacía misiones nocturnas de bombardeo y suministro.</p>

<p>En las tablas de "Yogy" menciona únicamente el I-16 TYPE 18, pero hemos optado por incluir también, ya que el HSFX v. 5.01 lo permite, el modelo I-16 TYPE 18 (2xBS), que tiene capacidad de portar cohetes, además de bombas. El número de cada modelo es la mitad del total.</p>


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
					<b>Ya la tenemos aquí: disfrutémosla</b><br/>
<p>El mapa de <b>Kursk-1.943</b> ha terminado. Ha durado bastante menos de lo previsto, aunque ha servido con creces para probar los "bugs" corregidos y las nuevas características implementadas.</p>

<p>Ha quedado demostrado que, tal como pretendíamos, la conservación del propio avión y de la vida del piloto marcan, en muy buena medida, el desarrollo de la Campaña, por lo que parece necesario que los participantes de ambos bandos tomen conciencia de esta cuestión: a veces resulta más rentable no perder aviones/pilotos que conseguir el objetivo de la misión a toda costa.</p>

<p>Era nuestra intención que, antes de lanzar la <b>DZ 2.0</b>, el siguiente mapa fuese el de <b>Normandía-1.944</b>, pero, debido a la duración del anterior, no hemos tenido tiempo de terminarlo y le quedan un mínimo de un par de semanas. Así que empezaremos de nuevo en el <b>Frente Oriental</b> e iremos volando, de forma más o menos cronológica, los diferentes mapas de aquel teatro bélico. El motivo es que los primeros de esos mapas (Lvov, Bessarabia, Kiev, Smolensk, etc.) ya estaban hechos. No obstante, y a medida que  vayamos generando los mapas correspondientes, nos gustaría ir alternando el Frente Oriental con el Frente Occidental. Tampoco descartamos, si somos capaces de solucionar una serie de cuestiones técnicas en los mapas con grandes extensiones de mar, añadir Campañas en el Pacífico, Mediterráneo, Canal de La Mancha, etc.</p>

<p>Esta nueva fase de la <b>DZ 2.0</b> se volará con el <b>HSFX v.5.01</b>, ya que aporta interesantes características de las que enumeraremos unas cuantas que nos parecen las más relevantes.</p>

<p>El <b>HSFX v5.01</b> se instala sobre una copia "limpia" de la versión <b>4.10.1</b> del IL-2. En esta versión (4.10.1) se corrigieron los FM (modelos de vuelo) de algunos Bombarderos, de forma que se comportan como tales y no como Cazas; se añadió el daño provocado por el exceso de G's a la estructura de los aviones; se añadió la navegación realista mediante radio-balizas y otros sistemas de navegación; los artilleros ya no son auténticos francotiradores; y otra serie de cuestiones que sería muy largo enumerar.</p>

<p>El <b>HSFX v5.01</b> añade otra serie de características que nos parecen muy adecuadas para este tipo de Campañas Cooperativas: el "*.log" de la misión recoge la altura de los aviones cuando se activa el humo de las alas y lo envía al generador, con lo que resulta muy útil para las misiones de SUM. Además abre las puertas a las misiones de <b>"Recon"</b>. Las bombas han sido modificadas (en todos los bandos en contienda: italianos, japoneses, rusos, aliados, alemanes, …) de tal forma que el radio de acción y los daños ocasionados están en función, no sólo del tipo de bomba, sino  de la cantidad de Kgrs. de explosivo que porta y no del peso total de la propia bomba.</p>

<p>Otra de las características más que atractiva que incluye el <b>HSFX v5.01</b> es la posibilidad de establecer <b>Fábricas</b> (en realidad son zonas previamente fijadas en el mapa y que simulan la producción de fábricas), con lo que se abre también la posibilidad de reponer aviones en la medida en que dichas fábricas permanezcan activas.</p>

<p>Se van a resetear las Estadísticas, tanto personales como de Escuadrones, por lo que será necesario que los pilotos que deseen participar vuelvan a registrarse como tales, den de alta los distintos Escuadrones y se unan a ellos. Habrá tiempo suficiente para hacerlo y, tal como se ha dicho repetidamente, como es una Campaña en equipo, no se permitirá participar en ninguna misión si previamente algún piloto no está registrado y forma parte de alguno de los Escuadrones en activo. Sería deseable que los responsables de cada Escuadrón fuesen pilotos que volasen asiduamente para que pudiesen gestionar con inmediatez las Altas en sus filas.</p>

<p>Queremos introducir varias modificaciones más. Algunas parecen fáciles (se lo parecen a E69_Heracles, que es como el Genio de la lámpara de Aladino), pero aún así el tiempo escasea, por lo que las novedades irán llegando poco a poco. Algunas de  ellas se implementarán sobre la marcha, puede que en este mapa o en alguno de los próximos. Tenemos bastantes cuestiones a modificar, pero sabemos que algunas de ellas llevará mucho tiempo lograrlas y otras puede que resulten imposibles. Como ejemplos, varias cuestiones que nos gustaría hacer pero aún no sabemos (quiero decir que E69_Heracles aún no lo sabe, pero lo sabrá; los demás jamás llegaremos a tener idea siquiera) si serán posibles:</p>

<ul>
	<li>Cuando un piloto resulte muerto o capturado los derribos (u objetivos
	terrestres destruídos) NO contabilizarán en sus Estadísticas personales, pero
	sí se sumarán a las pérdidas del bando enemigo.</li>
	<li>Para las misiones de Bombardeo (BA) los aviones saldrán aleatoriamente,
	igual que pasa con los cazas, en función de la cantidad disponible de cada
	modelo y/o tipo.</li>
	<li>El control de altura de SUM (ésto ya lo tiene resuelto para los SUM
	humanos, pero puede que no sea posible con los IAs).</li>
</ul>


<p>Otras modificaciones a más largo plazo, debido a su complejidad, pero que E69_Heracles ya sabe cómo hacer, aunque le llevarán tiempo:</p>

<ul>
	<li>Nueva página web.</li>
	<li>Inventario de aviones (número total de aviones por modelo, del que se irán
	restando las pérdidas, en cada mapa).</li>
	<li>Producción de Fábricas (que irán reponiendo los aviones perdidos).</li>
</ul>

<p>Estas tres últimas modificaciones se implementarán de forma conjunta para que la producción de las fábricas tenga repercusión sobre el número de aviones total por mapa.</p>
				</td>
			</tr>					
					
			<tr class="section_subheader" height="30px"> 
				<td colspan="2"> 
					<span class="section_subheader_txt">Un nuevo impulso para renovar nuestra competición</span>&nbsp;&nbsp;
					<span style="font-size:9px">[E69_espiral]</span><br/></td> 
					<td align="right" style="font-size:9px">30 de Abril de 2011</td>
			</tr>	
			<tr>
				<td colspan="3">
					<b>Nuevas normas, nuevo mapa</b><br/>
<p> La <b>DangerZone</b> surgió como una Campaña-Cooperativa Inter-Escuadrones (de habla hispana) con dos objetivos principales:<br />
 <br />
1) Establecer una actividad conjunta entre todos los pilotos de los diferentes Escuadrones Virtuales que conformaban ambos bandos.<br />
2) Que dicha Campaña fuese lo más histórica posible, sabiendo de antemano que era muy difícil lograrlo debido a la gran cantidad de información dispersa y a la disparidad de las fuentes consultadas en cuanto a "planesets" y demás aspectos operativos.</p>

<p> Si bien la primera finalidad se cumplió con creces -aunque siempre es deseable pedir más-, el segundo propósito, por diferentes razones, comenzó a desvirtuarse poco a poco hasta diluirse por completo, haciendo que lo que había nacido como una Campaña-Cooperativa se convirtiese, en la práctica, en una sucesión de "dogfights" con formato de cooperativa.<br />
 <br />
 Esto tuvo, básicamente dos causas: <br />
 <br />
 La primera fue la pretensión de lograr un "equilibrio técnico" en los "planesets", lo que condujo a una serie de peticiones que fueron "in crescendo" hasta desembocar en auténticos despropósitos que llevaron a la confección de "planesets" totalmente alejados de la realidad histórica y que, además, tuvieron el efecto contrario al buscado.<br />
 <br />
 La segunda, y no menos importante, fue que no se premiaba suficientemente la supervivencia del piloto y la conservación del propio avión, lo que dio como resultado que la mentalidad de algunos participantes no fuese la de <b>volar una misión en equipo</b>, sino la de participar en una "dogfight" en la que lo único importante era hacer derribos, aún a costa de resultar muerto, para incrementar las estadísticas personales.<br />
 <br />
 Pero ésto ha iniciado un profundo proceso de cambio que no sólo pretende que la DZ vuelva a sus orígenes, sino mejorar diversos aspectos de la Campaña, tanto a nivel de programación como de las normas que la rigen.<br />
 <br />
 Para ello se ha constituído un grupo de trabajo inter-Escuadrones que ya ha comenzado a desarrollar una serie de modificaciones y nuevas funcionalidades en el generador/parser, en las normas, en la web y en los Foros.<br />
 <br />
 Los primeros esfuerzos han estado destinados a darle a la DZ el mayor componente de <b>realidad histórica</b> del que hemos sido capaces. Este componente histórico está limitado, además de por lo anteriormente apuntado en referencia a los "planesets", por diferentes cuestiones del motor de la DZ y por la versión del <b>IL-2</b> (v. 4.09m) con la que actualmente se vuela la Campaña. Algunas cuestiones están ya en estudio para ver su viabilidad técnica y, en muchos casos, se irán implementando en sucesivas versiones de la DZ, que finalmente se volará con la <b>v. 4.11 del HSFX</b> incluído en el Ultrapack 2.01. ¿Por qué este pack de MODs? A nuestro juicio tiene varias ventajas que vamos a tratar de resumir:<br />
 <br />
 Queda totalmente descartada, pues, la situación de equilibrio entre los bandos en disputa en beneficio de la de realidad histórica.<br />
 <br />
 Se dará <b>prioridad absoluta</b> a un concepto un tanto olvidado en la simulación: <b>LA VIDA</b>. Durante la contienda ningún piloto (salvo algún "bailed" en territorio propio) disfrutaba de una segunda oportunidad (REFLY), y todos eran conscientes de ello, anteponiendo la propia supervivencia y la de sus compañeros sobre cualquier otra cosa.<br />
 <br />
 Por tanto, a partir de ahora, volverá a ser una Campaña; es decir, que todas las acciones de una misión tendrán consecuencias en las sucesivas. Puede haber algún piloto al que este planteamiento le parezca poco importante, pero, con seguridad, sí le importará a su bando, porque le afectará enormemente en el devenir de la Campaña.<br />
 <br />
 Somos muy conscientes de que la DZ es una competición, que tiene carácter lúdico y, si se quiere, formativo, pero sobre todo es una <b>Campaña en equipo</b>, uno por bando, así que no se permitirán comportamientos individualistas tipo Server-Dog: <b>se exigirá</b>, en todo momento, una <b>actitud</b> acorde al espíritu necesario para intentar ganar una Campaña de estas características. Tened en cuenta, además, que cada <b>equipo</b> estará integrado por pilotos de diferentes Escuadrones, por lo que será necesario un esfuerzo adicional de coordinación para que el equipo/bando resulte cohesionado.<br />
 <br />
 En los respectivos Briefings de cada bando, en cada misión generada, se refleja de forma muy concisa, clara y comprensible cuál es el objetivo de la misión de Ataque y de la de Defensa. Así que es necesario que <b>cada piloto</b> que ocupe un "slot" <b>lea y comprenda</b> cuál es <b>su misión</b> y (salvo que su líder decida lo contrario) se ciña a ella.<br />
 <br />
 Dado que se potencia la supervivencia y se penaliza la muerte/captura, cada piloto/avión perdido penalizará (bastante más que ahora) su Base de partida, haciendo que ésta tenga cada vez menos aviones disponibles que puedan operar desde ella y que la AAA de dicha Base vaya disminuyendo, con lo que resultará un objetivo más fácil y apetecible para el bando enemigo. Ésto se simula dañando el AF hasta un punto (80% de daño) en que el AF es inoperativo, es decir no quedan más aviones que puedan despegar desde él.<br />
 <br />
 Como paso previo al reinicio definitivo de la DZ, se volará un primer mapa en el que se irán probando diversas modificaciones introducidas. La hemos denominado <b>DZ v. 1.93</b> y hemos escogido el <b>Mapa de Kursk en 1943</b> por varias razones:<br />
 <br />
 Kursk_43 está, más o menos, situado a mitad de la contienda, momento en el que no había una neta superioridad por parte de ninguno de los dos bandos, lo que nos proporciona una situación ideal para poder valorar si los cambios introducidos son positivos para el desarrollo de la Campaña.<br />
 <br />
 Estos cambios, que de momento son menores, son:<br />
 <br />
1) <b>"Planesets" históricos</b>. A falta de poder reunir una información más abundante y exhaustiva, y aún sabiendo que no es completo nos hemos decantado por el "planeset de Yogy", dado que hay acuerdo en que es lo más parecido, con todas sus carencias, a lo que hubo históricamente. Hemos sumado las existencias de aparatos (para ambos bandos) en los mapas de Prokhorovka y Kursk, ya que la "Batalla de Prokhorovka" tuvo lugar dentro de la Ofensiva de Kursk (Operación "Citadelle"). Los "roles" asignados a los diferentes tipos de aparatos son también en función de las tablas de Yogy. Se han suprimido del cómputo total los aviones destinados a misiones nocturnas y de Reconocimiento.</p>

<p>2) <b>Penalización por muerte/pérdida de avión</b>. Ya funcionaba en la DZ (bajando la operatividad del AF de salida), pero con unos valores que no premiaban la supervivencia ni la conservación del avión. Así que hemos modificado dichos valores para que ahora SÍ que sea más rentable sobrevivir que hacer un derribo. Este premio/penalización afectará, en distinta medida, tanto a los humanos como a los IAs.</p>

<p><br />
3) En referencia al primer punto, Aviones de SUM que son de Transporte y no Bombarderos (Ju-52 y Li-2). Estos aviones, que con la v. 4.09m no son pilotables, sí lo son con el HSFX. Para tratar de "compensar" el mayor número total de aviones del bando ruso, y dado que las misiones se generan para igual número de pilotos/bando, se ha incrementado el "ratio" de SUM para el bando rojo en un pequeño porcentaje respecto del "ratio" alemán. <br />
Los aviones de SUM deberán aterrizar, obligatoriamente, en los AFs que estén dentro de un radio de 30 Km. de la ciudad suministrada. En caso contrario la misión SUM será anulada por el parser tanto en la ciudad como en el AF, fracasando la misión al completo.</p>

<p>4) <b>Aumento del número de Objetivos en las ciudades</b>. Hasta ahora los objetivos a bombardear solían estar situados en un solo grupo, con lo que resultaba bastante fácil que un único Bombadero pudiese infligir un daño como toda una Escuadrilla. Ahora se ha intentado que, en las ciudades, los objetivos estén repartidos en varios grupos, con lo que se pretende que el daño sufrido por el Bambardeo esté también en función del número de aviones atacantes y de la pericia de los pilotos.</p>

<p>5) <b>Supresión de la luz de Bombardeo</b>. Más o menos a mitad de la actual DZ algunos pilotos solicitaron que en la Zona Objetivo de cada ciudad se colocase una luz para facilitar el bombardeo en altura. Tras más de 1.000 misiones voladas, los bombardeos en altura pueden contarse con los dedos de una mano. Así que hemos optado por suprimir esa "ayuda" para dar más realismo a la Campaña. (Está en estudio, para próximas versiones, la viabilidad técnica de Misiones de Reconocimiento, que ubiquen con más precisión las zonas donde el enemigo ha emplazado sus SUM y/o sus tropas).<br />
6) <b>30 Misiones/Día Virtual</b>. Tal como era en su origen, lo que permite aprovechar las ventajas tácticas que uno de los bandos (o ambos) hayan podido obtener. Se entenderá mejor al ver el punto siguiente.</p>

<p>7) <b>Corregido el TTL (Time To Live)</b>. El TTL se corresponde con las rayitas roja/verde que podemos ver en los distintos Sectores del Mapa. Significan el nivel de SUM de ese Sector: si un Sector está sin Suministro, esa rayita (TTL), que tiene un valor de 30 puntos cuando está al 100%, va disminuyendo un punto por misión hasta desaparecer cuando acaba el día virtual; en ese momento resulta más fácil atacar con éxito el Sector que si estuviese suministrado (al no tener suministro está menos defendido y es necesario un menor número de tanques enemigos para conquistarlo). Al bajar el número de misiones a 10/día virtual habría que haber corregido el TTL, pero no se hizo, por eso ahora da igual cuánto esté suministrado un Sector: siempre, tienen que sobrevivir un número de tanques atacantes, como si el Sector estuviese suministrado al 100%. Una vez corregido, el número de tanques atacantes que tengan que sobrevivir para conquistar el Sector estará en función de los SUM de ese Sector, oscilando entre 2 y 7.</p>

<p><br />
8) <b>Corregido el "bug" de los 12 tanques</b>. En las misiones en las que ambos bandos hacían ataque a Sector se producía un error que hacía que el bando ruso atacase con 12 tanques (4 grupos de 3) en lugar de los 9 (3 grupos de 3) establecidos.</p>

<p>9) <b>Aumento y corrección de AAA en los AFs</b>. Hasta ahora cualquier Aeródromo (AF) operativo al 100% disponía de 4 AAA de 85mm y 4 AAA de 20mm. Por otra parte, en algún momento de la DZ, se solicitó que se cambiase la AAA de 88mm alemana por la de 85mm rusa, ya que se "tenía la impresión" (creo que lo dije yo mismo y sin ningún dato objetivo que lo sustentase) de que era más efectiva esta última. Ahora se incrementará y cada bando dispondrá de la suya propia; es decir, los AFs rusos tendrán 8x25mm, 2x37mm y 6x25mm. Iguales cantidades los AFs alemanes con sus propios calibres (88mm, 37mm y 20mm). Se aplicará el mismo criterio a las zonas objetivos de BA de las ciudades.</p>

<p><br />
10) <b>Supresión de misiones nocturnas/tormenta</b>. Este tipo de misiones, que sin duda resultarían muy interesantes si todos los pilotos fuésemos humanos, no lo son en la práctica porque casi no hay misión en la que no exista algún "caza" IA, y es evidente que, aún con el "skill" en "rookie" tienen una clara ventaja con respecto a los humanos: nos ven entre nubes y con oscuridad total, pero nosotros a ellos no. Por otra parte, ya que hemos suprimido de los "planesets" los aviones destinados a este tipo de misiones, no sería muy consecuente continuar volándolas.</p>

<p>11) <b>Limitación del número de Bombarderos/SUM en función del número de pilotos/bando que vuelen la misión</b>. Las misiones de la DZ permiten fijar el número de Bombarderos de Ataque (BA) y de Suministro (SUM) hasta un máximo de 6. No obstante, en ambos bandos venimos utilizando con demasiada frecuencia el máximo número posible de ellos independientemente de si la Misión es generada para 4, 5 ó 20 pilotos por bando. Por ello hemos considerado establecer un número máximo de aparatos de BA/SUM que, de momento y mientras se comprueba si su proporción resulta idónea, será: hasta 4 pilotos/bando, 2; hasta 6 pilotos/bando, 3, hasta 8 pilotos bando, 4; 10 ó más pilotos/bando, 6.</p>

<p> </p>

<p> Todas estas modificaciones estarán, en esta versión de la DZ, en fase de prueba: algunas sujetas a que funcionen correctamente, otras a que los valores que les hemos dado resulten adecuados (podrían aumentar o disminuir), y todas (salvo los "bugs" corregidos) a que contribuyan a hacer la DZ más dinámica y atractiva de volar cada vez a más pilotos.<br />
 <br />
 Hay otras muchas cuestiones que están en estudio: SUM terrestres y marítimos, misiones de Reconocimiento, misiones paracaidistas tras las líneas enemigas, misiones de desembarco anfibio, producción de fábricas, misiones de "BlitzKrieg" (ataque en profundidad a 2 Sectores en lugar de al inmediato a la línea del Frente), poder hacer Campañas en mapas con dos letras por Sector (mapas más grandes como el de Besarabia), mapas con gran cantidad de Sectores de mar (Pacífico, Mediterráneo, Canal), etc. Algunas de ellas serán viables técnicamente y otras no. De las técnicamente posibles algunas se acabarán implementando y otras, que no resulten positivas, no. Pero tened en cuenta que únicamente contamos con un Programador (E69_Heracles), que, además de obligaciones de trabajo, estudios, familia y necesidad de volar, dedica desinteresadamente muchas horas a estudiar, revisar y programar el código de la DZ. Por eso, aunque todas las peticiones, críticas y sugerencias son muy bien venidas, tened mucha paciencia, al menos tanta como tiene él con nosotros y con el código.<br />
 Una última cuestión: todas las modificaciones y nuevas funcionalidades están pensadas para dar mayor dinamismo e interés a la DZ. Todas se han sopesado cuidadosamente y sólo queda probarlas en Campaña. En ningún caso se ha pretendido favorecer o perjudicar a cualquiera de los bandos. Así que, como ha quedado dicho anteriormente, cualquier sugerencia será acogida favorablemente, pero <b>quedan totalmente excluídos</b> comentarios del tipo "es que vuestros aviones son mejores", "este avión tiene poca munición", etc. Cada bando tiene lo que tenía históricamente y no queda ninguna otra opción que aprovechar las ventajas propias e intentar que el enemigo no pueda aprovechar las suyas: <b>trabajo en Equipo</b>.<br />
 <br />
 Además de reiterar el agradecimiento a "E69_Heracles" quiero hacerlo extensivo a otros muchos pilotos virtuales que, en mayor o menor medida, han contribuído a hacer posible este proyecto: unos con sus conocimientos, consejos y sugerencias, otros con su apoyo, otros con sus gestiones, y muchos como "sufridos probadores":<br />
 <br />
 E69_cvchavo<br />
 E69_metaliving<br />
 E69_Patrel<br />
 E69_chapas<br />
 FAE_Cazador<br />
 FAE_Cormorán<br />
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
					B.A.D.C. (Bourne Again Dynamic Campaign) es un motor de campañas dinámicas para  el IL2-FB. Fue desarrollado 
					en 2004 por <b>JG10r_Dutertre</b>, y se ha usado en algunas de las mejores competiciones online como 
					Bellum,CAD,Czec War,Mosquito, ...  <br/><br/>
					La Danger Zone 1.93 diseñada por e <b>E69_espiral, E69_cvchavo, E69_Patrel, E69_Metaliving</b> y implementada por <b>E69_Heracles</b>, es una adaptación del motor B.A.D.C.<br/><br/>
					Actualmente se vuela con <b>HSFX v5.01</b> sobre <b>IL-2 1946</b>.<br/><br/>
				</td>
			</tr>					
		</table>
<?php 
include ("./dz_page_footer.php");
?>