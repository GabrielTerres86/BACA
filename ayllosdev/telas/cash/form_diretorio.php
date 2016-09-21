<?php
/*!
 * FONTE        : form_diretorio.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 16/11/2011
 * OBJETIVO     : Formulario da opção L da tela Cash
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout (David Kruger).
 * --------------
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

<form id="frmDiretorio" name="frmDiretorio" class="formulario" onsubmit="return false;">

	<fieldset>
		
		<label for="nmdireto">Diretorio:    <?php echo $nmdireto ?></label>
		<input name="nmdireto" id="nmdireto" type="text" value="" />
		
	</fieldset>	

</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="fechaOpcao(); return false;">Fechar</a>
    <a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">Continuar</a>	
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmDiretorio'));
	});

</script>