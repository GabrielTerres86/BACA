<? 
/*!
 * FONTE        : form_envio_cc_pagto.php
 * CRIAÇÃO      : Jean Calao
 * DATA CRIAÇÃO : 05/08/2017
 * OBJETIVO     : Formulario para enviar pagamento de prejuizo de conta corrente
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form id="frmEnvioCCPagto" name="frmEnvioCCPagto" class="formulario">

	<div>
		<fieldset>	
			<legend>Dados Pagamento</legend>
			
			<label for="nrdconta"><?php echo utf8ToHtml('Conta/DV:') ?></label>
			<input type="text" id="nrdconta" name="nrdconta" class="conta" value=""/>
			<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<br style="clear:both" />
			
		</fieldset>	
	<div>
	
	<div id="divLancamentosPagamento"></div>	
</form>
