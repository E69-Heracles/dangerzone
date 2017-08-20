<?php
$file = getenv("DOCUMENT_ROOT") . "/cgi-bin/version.txt";
$contents = file($file);
$version = implode($contents);
?>
		  <tr>
				<td colspan="3" class="footer" height="30px" align="center">
					<span style="font-size:9px">Danger Zone v<?php echo $version ?></span> 
				</td>
			</tr>		
		  <tr>
				<td colspan="3" height="30px"></td>
			</tr>				
			</table>			
		</td>
	</tr>
	</table>
</body>
</html>