<? 
/*!
 * FONTE        : form_estorno_pagamento_ct.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Formulário para estornar os pagamentos da Conta Transitória (Bloqueado Prejuízo)
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form id="frmEstornoPagamentoCT" name="frmEstornoPagamentoCT" class="formulario">

	<div>
		<fieldset>	
        
			<legend><?php echo utf8ToHtml('Prejuízo de C/C'); ?></legend>
			
			<label for="nrdconta"><?php echo utf8ToHtml('Conta/DV:') ?></label>
			<input type="text" id="nrdconta" name="nrdconta" class="conta" value=""/>
			<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<br style="clear:both" />

		</fieldset>	
	<div>
	
	<div id="divLancamentosPagamentoCT"></div>	
</form>