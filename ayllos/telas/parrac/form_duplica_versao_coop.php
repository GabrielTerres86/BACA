<? 
/*!
 * FONTE        : form_crapvac.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 03/02/20145
 * OBJETIVO     : Tela para incluir/alterar dados da versao
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
	
	$nr_operacao =  substr($operacao,10,1) + 1;
?>

<form id="frmDuplica" name="frmDuplica" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Duplicar vers&atilde;o (outras coop.)'); ?></legend>

	<br />
	<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>	
	<select name="cdcooper" id="cdcooper"> </select>
	<br />

	
	</fieldset>	

</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
    <a href="#" class="botao" id="btSalvar" onclick="manter_rotina('<? echo substr($operacao,0,10) . $nr_operacao ?>'); return false;">Continuar</a>   
</div>

<script> 
		
	$(document).ready(function(){
		highlightObjFocus($('#frmDuplica'));
		$("#cdcooper","#frmDuplica").html('<? echo $slcooper ?>');
		formataDuplicacao();
	});

</script>