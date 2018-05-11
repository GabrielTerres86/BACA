<? 
/*!
 * FONTE        : form_estorno_pagto.php
 * CRIAÇÃO      : Jean Calao
 * DATA CRIAÇÃO : 05/07/2017
 * OBJETIVO     : Formulario para estornar os pagamentos de prejuizo
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form id="frmEstornoPagto" name="frmEstornoPagto" class="formulario">

	<div>
		<fieldset>	
			<legend>Dados Pagamento</legend>
			
			<label for="dtpagto" class=data><?php echo utf8ToHtml('Data Pagamento:') ?></label>
			<input type="text" id="dtpagto" name="dtpagto" value=""/>
			
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
