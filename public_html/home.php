<?php 
include ("./block.php");
include ("./config.php");

include ("./dz_page_header.php");
?>
			<img class="modal_map" src="images/front.jpg" WIDTH="675" HEIGHT="585" BORDER=0/>
			
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
					$file = $_SERVER['DOCUMENT_ROOT'] . "/cgi-bin/status.txt";
					$contents = file($file);
					echo $contents[0];
					echo $contents[1];
					?>
			
					<a href="mapa.html"><img id="map_icon" src="images/map_banner_kursk.jpg" border="2"></a><br/><br/>
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
					La Danger Zone 1.93 diseñada por el <b>E69_espiral, E69_cvchavo, E69_Patrel, E69_Metaliving</b> y implementada por <b>E69_Heracles</b>, es una adaptación del motor B.A.D.C.<br/><br/>
					Actualmente se vuela con <b>HSFX v4.11</b> sobre <b>IL-2 1946</b>.<br/><br/>
				</td>
			</tr>					
		</table>
<?php 
include ("./dz_page_footer.php");
?>