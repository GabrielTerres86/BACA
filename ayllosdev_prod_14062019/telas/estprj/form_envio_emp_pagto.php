<? 
/*!
 * FONTE        : form_envio_emp_pagto.php
 * CRIAÇÃO      : Jean Calao
 * DATA CRIAÇÃO : 05/08/2017
 * OBJETIVO     : Formulario para enviar pagamento de prejuizo de emprestimos
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
 
?>
<form id="frmEnvioEmpPagto" name="frmEnvioEmpPagto" class="formulario">

	<div>
		<fieldset>	
			<legend>Dados Pagamento</legend>
			
			<table>
			<tr><td><label for="nrdconta"><?php echo utf8ToHtml('Conta/DV:') ?></label>
			<input type="text" id="nrdconta" name="nrdconta" class="conta" value=""/>
			<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a></td>

			<td><label for="nrctremp"><?php echo utf8ToHtml('Contrato:') ?></label>
			<input type="text" id="nrctremp" name="nrctremp" value=""/>
			<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a></td></tr>
			
			</table>
			<br style="clear:both" />
			
		</fieldset>	
	<div>
	
	<div id="divLancamentosPagamento"></div>	
</form>
