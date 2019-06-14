<?php
	/*!
	 * FONTE        : form_importar_prova_vida.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 22/03/2017
	 * OBJETIVO     : Tela para realizar o processamento da planilha
	 * --------------
	 * ALTERAÇÕES   : 
	 */
	 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
?>
<form id="frmImportarProvaVida" name="frmImportarProvaVida" class="formulario" style="display:none;">

	<fieldset id="fsetFiltroProvaVidaObs" name="fsetFiltroProvaVidaObs" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend>Observa&ccedil;&otilde;es</legend>
		
		<div id="exemplo" style="height:130px;padding-left:15px;">
			<label style="text-align:left">
				Regras para processar a planilha de Prova de Vida:<br>
				1º - O arquivo deve estar obrigatoriamente no diret&oacute;rio: <b><? echo "/micros/".$glbvars["dsdircop"]."/inss/" ?></b><br>
				2º - O nome do arquivo deve ser obrigatoriamente <b>"PV_CECRED.csv"</b>.<br>
				
			</label>
		</div>
	</fieldset>
	
</form>