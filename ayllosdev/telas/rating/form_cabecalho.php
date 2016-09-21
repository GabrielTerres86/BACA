<?
/*!
 * FONTE        : form_cabecalho.php                             Última alteração: 
 * CRIAÇÃO      : Jonathan - RKAM
 * DATA CRIAÇÃO : 14/01/2016
 * OBJETIVO     : Cabeçalho para a tela RATING
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

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="A" ><? echo utf8ToHtml('A - Alterar as notas de risco do cooperado') ?> </option>
		<option value="C" selected><? echo utf8ToHtml('C - Consultar classificação de risco')?> </option>
		<option value="R" ><? echo utf8ToHtml('R - Imprimir classificação de risco') ?> </option>
	</select>

	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
	<div id="divCab" style="display:none"></div>
	
</form>


