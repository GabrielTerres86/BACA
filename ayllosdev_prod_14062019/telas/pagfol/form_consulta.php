<?
/*!
 * FONTE        : form_consulta.php
 * CRIA��O      : Renato Darosci - SUPERO
 * DATA CRIA��O : Junho/2015
 * OBJETIVO     : Cabe�alho para a tela PAGFOL
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
 
?>

<form id="frmCons" name="frmCons" class="formulario" onSubmit="return false;" style="display:none">
	<div id="divDados" >
	</div>    
</form>