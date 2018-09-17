<?php
/*!
 * FONTE        : form_local.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 29/11/2012
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
		<label for="nmarquiv">Arquivo: /micros/<? echo $dsdircop; ?>/</label>
		<input name="nmarquiv" id="nmarquiv" type="text" />
		<label for="nmarquiva">.csv</label>		
		
	</fieldset>	
</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Canclear</a>
	<a href="#" class="botao" id="btOk" onclick="validaArquivo(); return false;">Ok</a>
</div>