<? 
/*!
 * FONTE        : form_craptqs.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 11/12/2014 
 * OBJETIVO     : Tela para incluir/alterar dados do titulo do questionario
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

<form id="frmTitulo" name="frmTitulo" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend><? echo utf8ToHtml('Título'); ?></legend>
	
	<label for="nrordtit"><? echo utf8ToHtml('Sequência:') ?></label>	
	<input name="nrordtit" id="nrordtit" type="text" value="<? echo $nrordtit; ?>" />
	<br />

	<label for="dstitulo"><? echo utf8ToHtml('Título:') ?></label>	
	<input name="dstitulo" id="dstitulo" type="text" maxlength="50" value="<? echo $dstitulo; ?>" />
	<br />
	
	</fieldset>	

</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
    <a href="#" class="botao" id="btSalvar" onclick="manter_rotina('<? echo substr($operacao,0,10) . '2' ?>'); return false;">Continuar</a>   
	
</div>

<script> 
		
	$(document).ready(function(){
		highlightObjFocus($('#frmTitulo'));
		formataTitulo('<? echo substr($operacao,0,1); ?>');
	});

</script>