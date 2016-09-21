<? 
/*!
 * FONTE        : form_crarpqs.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 12/12/2014 
 * OBJETIVO     : Tela para incluir/alterar dados das respostas do questionario
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

<form id="frmResposta" name="frmResposta" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Resposta'); ?></legend>
	
	<label for="nrordres"><? echo utf8ToHtml('Sequência:'); ?></label>	
	<input name="nrordres" id="nrordres" type="text" value="<? echo $nrordres; ?>" />
	<br />

	<label for="dsrespos"><? echo utf8ToHtml('Resposta:'); ?></label>	
	<input name="dsrespos" id="dsrespos" type="text" maxlength="30" value="<? echo $dsrespos; ?>" />

	<br />
	
	</fieldset>	

</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
    <a href="#" class="botao" id="btSalvar" onclick="manter_rotina('<? echo substr($operacao,0,10) . '2' ?>'); return false;">Continuar</a>   
	
</div>

<script> 
		
	$(document).ready(function(){
		highlightObjFocus($('#frmResposta'));
		formataResposta('<? echo substr($operacao,0,1); ?>');
	});

</script>