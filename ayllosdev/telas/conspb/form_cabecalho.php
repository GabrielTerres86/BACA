<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 30/07/2015
	 * OBJETIVO     : Cabecalho para a tela CONSPB
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" enctype="multipart/form-data" style="display:none" >
	<table width="100%">
		<tr>
			<td>
				<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
			</td>
		</tr>
		<tr>		
			<td align="center">
				<label for="dspartes">Partes:</label>
				<select id="dspartes" name="dspartes">
					<option value="PJA">JDSPB / AYLLOS</option> 
				</select>
			</td>
		</tr>
		<tr>		
			<td align="center">
				<label for="dsdopcao">Op&ccedil;&atilde;o:</label>
				<select id="dsdopcao" name="dsdopcao">
					<option value="OT">Todos</option> 
					<option value="OI">Ind&iacute;cios de duplicidade</option>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<fieldset>
					<legend>Arquivo de Concilia&ccedil;&atilde;o</legend>
					<table width="100%">
						<tr>		
							<td>
								<div id="divuploadfile" style="height: 30px;" center>
									<input type="hidden" name="MAX_FILE_SIZE" value="8388608" />
									<input name="userfile" id="userfile" size="110" type="file" class="campo" style="height: 25px;" alt="<? echo utf8ToHtml('Informe o caminho do arquivo.'); ?>" />
								</div>	
							</td>
						</tr>
					</table>
				</fieldset>
			</td>
		</tr>
	</table>
</form>