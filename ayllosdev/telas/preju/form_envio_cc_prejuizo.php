<? 
/*!
 * FONTE        : form_envio_cc_prejuizo.php
 * CRIAÇÃO      : Jean Calao
 * DATA CRIAÇÃO : 05/07/2017
 * OBJETIVO     : Formulario para enviar conta corrente para prejuizos
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form id="frmEnvioCCPrejuizo" name="frmEnvioCCPrejuizo" class="formulario">

	<div>
		<fieldset>	
			<legend>Dados Prejuizo</legend>
			
			<label for="nrdconta"><?php echo utf8ToHtml('Conta/DV:') ?></label>
			<input type="text" id="nrdconta" name="nrdconta" class="conta" value=""/>
			<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<br style="clear:both" />
			
		</fieldset>	
	<div>
	
	<div id="divLancamentosPagamento"></div>	
</form>
