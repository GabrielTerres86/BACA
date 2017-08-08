<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 19/06/2017
 * OBJETIVO     : Cabecalho para a tela CADCUR
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

<form id="frmCadcur" name="frmCadcur" class="formulario" onSubmit="return false;" style="display:none">
	<label for="cdfrmttl">C&oacute;digo:</label>
	<input type="text" id="cdfrmttl" name="cdfrmttl" value="<? echo $cdfrmttl == 0 ? '' : $cdfrmttl ?>" />	
	<input type="text" class="campo alphanum" name="rsfrmttl" id="rsfrmttl"  value="<? echo $rsfrmttl; ?>" />				
	<label for="dsfrmttl">Descri&ccedil;&atilde;o:</label>
	<input type="text" class="campo alphanum" name="dsfrmttl" id="dsfrmttl"  value="<? echo $dsfrmttl; ?>" />					
</form>