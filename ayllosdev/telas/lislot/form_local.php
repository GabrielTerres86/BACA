<?php
/*!
 * FONTE        : form_local.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 24/03/2014
 * OBJETIVO     : Formlario nome do arquivo
 * --------------
 * ALTERAÇÕES   :
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
	
	$dsdircop	= (isset($_POST['dsdircop'])) ? $_POST['dsdircop'] : ''  ;
	
?>

<form id="frmLocal" name="frmLocal" class="formulario" onsubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Digite o nome do arquivo') ?></legend>
		<label for="nmarquiv">Arquivo: /micros/<? echo $glbvars["nmcooper"] ?>/</label>
		<input name="nmarquiv" id="nmarquiv" type="text" />
		<label for="nmarquiva"></label>		
		
	</fieldset>	
</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Cancelar</a>
	<a href="#" class="botao" id="btOk" onclick="validaArquivo(); return false;">Ok</a>
</div>