<? 
/*!
 * FONTE        : form_crapvqs.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 11/12/2014 
 * OBJETIVO     : Tela para incluir/alterar dados da versao do questionario
 * --------------
 * ALTERAÇÕES   : 
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmVersao" name="frmVersao" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Vers&atilde;o'); ?></legend>

	<label for="dsversao"><? echo utf8ToHtml('Versão:') ?></label>	
	<input name="dsversao" id="dsversao" type="text" maxlength="30" value="<? echo $dsversao; ?>" />
	<br />
		
	<label for="dtinivig"><? echo utf8ToHtml('In&iacute;cio Vig&ecirc;ncia:') ?></label>
	<input name="dtinivig" id="dtinivig" type="text" value="<? echo $dtinivig; ?>" />
	<br />
	
	</fieldset>	

</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
    <a href="#" class="botao" id="btSalvar" onclick="manter_rotina('<? echo substr($operacao,0,10) . '2' ?>'); return false;">Continuar</a>   
</div>

<script> 
		
	$(document).ready(function(){
		highlightObjFocus($('#frmVersao'));
		formataVersao('<? echo substr($operacao,0,1); ?>');
	});

</script>