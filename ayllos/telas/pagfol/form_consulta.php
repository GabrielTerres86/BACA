<?
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Renato Darosci - SUPERO
 * DATA CRIAÇÃO : Junho/2015
 * OBJETIVO     : Cabeçalho para a tela PAGFOL
 * --------------
 * ALTERAÇÕES   : 
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