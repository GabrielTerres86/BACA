<? 
/*!
 * FONTE        : form_estorno_pagamento.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Formulario para estornar os pagamentos
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form id="frmEstornoPagamento" name="frmEstornoPagamento" class="formulario">

	<div>
		<fieldset>	
			<legend>Dados</legend>
			
			<label for="nrdconta"><?php echo utf8ToHtml('Conta/DV:') ?></label>
			<input type="text" id="nrdconta" name="nrdconta" class="conta" value=""/>
			<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<label for="nrctremp"><?php echo utf8ToHtml('Contrato:') ?></label>
			<input type="text" id="nrctremp" name="nrctremp" value=""/>
			<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
			
			<br style="clear:both" />
			
		</fieldset>	
	<div>
	
	<div id="divLancamentosPagamento"></div>	
</form>