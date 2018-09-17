<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 24/09/2015
	 * OBJETIVO     : Tela para realizar a exclusão do lançamento do pagamento do beneficio do INSS
	 * --------------
	 * ALTERAÇÕES   : 14/10/2015 - Ajustes para liberação (Adriano).
	 * --------------
	 */
?>
<form id="frmExcluirLancamento" name="frmExcluirLancamento" class="formulario" style="display:none;">

	<fieldset id="fsetExcluirFiltro" name="fsetExcluirFiltro" style="padding:0px; margin:0px; padding-bottom:10px; display:none;">
		
		<legend>Filtro</legend>
		
		<table width="100%">
			<tr>
				<td>
					<label for="cddotipo"><? echo utf8ToHtml("Tipo:"); ?></label>
					<select class="campo" id="cddotipo" name="cddotipo">
						<option value="E"><? echo utf8ToHtml("E - Exclus&atilde;o de lan&ccedil;amento exclusivo") ?></option> 
						<option value="T"><? echo utf8ToHtml("T - Todos os lan&ccedil;amentos do dia") ?></option> 
					</select>
				</td>
			</tr>
			<tr>
				<td>
					<table width="100%" id="tbFiltrarExcluir">
						<tr>
							<td>
								<label for="cdcooper">Cooperativa:</label>
								<select class="campo" id="cdcooper" name="cdcooper"></select>
							</td>
						</tr>
						<tr>
							<td>
								<label for="nrdconta">Conta:</label>
								<input type="text" id="nrdconta" name="nrdconta"/>														
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>

	</fieldset>
	
	<fieldset id="fsetExcluirLancamentos" name="fsetExcluirLancamentos" style="padding:0px; margin:0px; padding-bottom:10px; display:none;">
		
		<legend>Lan&ccedil;amentos</legend>
		
		<div id="divExcluir" name="divExcluir">
			
		</div>
		
	</fieldset>
	
</form>