<?php
/*!
 * FONTE        : form_relatorio.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 11/03/2016
 * OBJETIVO     : Formulario de impressao do relatorio da tela HISTOR
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmRelatorio" name="frmRelatorio" style="display:none">
	<input type="hidden" id="sidlogin" name="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">	
	<input type="hidden" id="cddopcao" name="cddopcao" type="text"/>
</form>