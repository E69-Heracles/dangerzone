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
					$file = $_SERVER['DOCUMENT_ROOT'] . "/cgi-bin/status.txt";
					$contents = file($file);
					echo $contents[0];
					echo $contents[1];
					?>
			
					<a href="mapa.html"><img id="map_icon" src="images/map_banner_kursk.jpg" border="2"></a><br/><br/>
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
					La Danger Zone 1.93 dise�ada por el <b>E69_espiral, E69_cvchavo, E69_Patrel, E69_Metaliving</b> y implementada por <b>E69_Heracles</b>, es una adaptaci�n del motor B.A.D.C.<br/><br/>
					Actualmente se vuela con <b>HSFX v4.11</b> sobre <b>IL-2 1946</b>.<br/><br/>
				</td>
			</tr>					
		</table>
<?php 
include ("./dz_page_footer.php");
?>