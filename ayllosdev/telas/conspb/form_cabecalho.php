<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 30/07/2015
	 * OBJETIVO     : Cabecalho para a tela CONSPB
	 * --------------
	 * ALTERAÇÕES   : 01/06/2016 - Ajustado os campos para a conciliacao nao ser mais por UPLOAD (Douglas - Chamado 443701)
	 * --------------
	 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" enctype="multipart/form-data" style="display:none" >
	<table width="100%">
		<tr>		
			<td>
				<label for="dspartes">Partes:</label>
				<select id="dspartes" name="dspartes">
					<option value="PJA">JDSPB / AYLLOS</option> 
				</select>
			</td>
		</tr>
		<tr>		
			<td>
				<label for="dsdopcao">Op&ccedil;&atilde;o:</label>
				<select id="dsdopcao" name="dsdopcao">
					<option value="OT">Todos</option> 
					<option value="OI">Ind&iacute;cios de duplicidade</option>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="nmarquiv">Arquivo de Concilia&ccedil;&atilde;o:</label>
				<input type="text" id="nmarquiv" name="nmarquiv"/>
			</td>
		</tr>
		<tr>
			<td>
				<fieldset>
					<legend>Observa&ccedil;&otilde;es</legend>
					<div id="exemplo" style="height:70px;padding-left:15px;">
						<label style="text-align:left">
							Regras para processar a planilha de concilia&ccedil;&atilde;o:<br>
							1º - Informar apenas o nome do arquivo. A extens&atilde;o padr&atilde;o &eacute; ".csv" e n&atilde;o &eacute; necess&aacute;rio inform&aacute;-lo.<br>
							2º - O arquivo deve estar obrigatoriamente no diret&oacute;rio: <? echo "L:/".$glbvars["dsdircop"]."/spb/" ?><br>
						</label>
					</div>
				</fieldset>
			</td>
		</tr>
	</table>
</form>
