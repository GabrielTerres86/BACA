<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 24/09/2015
	 * OBJETIVO     : Tela para realizar o processamento da planilha
	 * --------------
	 * ALTERAÇÕES   : 14/10/2015 - Ajustes para liberação (Adriano).
	*				 16/02/2016 - Ajustes para corrigir o problema de não conseguir carregar corretamente as informações para opção "E" (Adriano - SD 402006)
	*				 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	 */
	 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
?>
<form id="frmProcessar" name="frmProcessar" class="formulario" style="display:none;">

	<fieldset id="fsetFiltroProcessar" name="fsetFiltroProcessar" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>
		
		<label for="nmdarqui">Arquivo:</label>
		<input type="text" id="nmdarqui" name="nmdarqui"/>
		
	</fieldset>
	
	<fieldset id="fsetFiltroProcessarObs" name="fsetFiltroProcessarObs" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend>Observa&ccedil;&otilde;es</legend>
		
		<div id="exemplo" style="height:130px;padding-left:15px;">
			<label style="text-align:left">
				Regras para processar a planilha de benef&iacute;cios do INSS:<br>
				1º - Obrigat&oacute;riamente, ap&oacute;s o processamento da planilha o SICREDI dever&aacute; ser informado.</b><br>
				2º - Informar apenas o nome do arquivo. A extens&atilde;o padr&atilde;o &eacute; ".csv" e n&atilde;o &eacute; necess&aacute;rio inform&aacute;-lo.<br>
				3º - O arquivo deve estar obrigatoriamente no diret&oacute;rio: <b><? echo "/micros/".$glbvars["dsdircop"]."/inss/" ?></b><br>
				
			</label>
		</div>
	</fieldset>
	
	<fieldset id="fsetFiltroProcessarResumo" name="fsetFiltroProcessarResumo" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Resumo</legend>
		
		<div id="divResumoProcesso">
			<label for="qtdPlanilha" id="lbQtdPlanilha">Quantidade na planilha:</label>
			<input type="text" id="qtdPlanilha" name="qtdPlanilha"/>
			
			<label for="valorPlanilha" id="lbValorPlanilha">Valor na planilha:</label>
			<input type="text" id="valorPlanilha" name="valorPlanilha"/>
			
			<label for="qtdProcessada" id="lbQtdProcessada">Quantidade processada:</label>
			<input type="text" id="qtdProcessada" name="qtdProcessada"/>
			
			<label for="valorTotal" id="lbValorTotal">Valor processado:</label>
			<input type="text" id="valorTotal" name="valorTotal"/>
			
			<label for="qtdErros" id="lbQtdErros">Quantidade de rejeitados:</label>
			<input type="text" id="qtdErros" name="qtdErros"/>
			
			<label for="valorErros" id="lbValorErros">Valor de rejeitados:</label>
			<input type="text" id="valorErros" name="valorErros"/>
								
		</div>
				
	</fieldset>
	
	<fieldset id="fsetFiltroProcessarDivergencia" name="fsetFiltroProcessarDivergencia" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Diverg&ecirc;ncia</legend>
		
		<div id="divResumoErros" name="divResumoErros">
		
		</div>
				
	</fieldset>
	
</form>