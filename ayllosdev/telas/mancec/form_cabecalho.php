<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann	
 * DATA CRIAÇÃO : 18/10/2016
 * OBJETIVO     : Cabeçalho para a tela MANCEC
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
	<select id="cddopcao" name="cddopcao" style="width: 460px;" tabindex="1">
		<option value="C"> C - Consultar Emitente de Cheque </option> 
		<option value="A"> A - Alterar Emitente de Cheque </option>
		<option value="E"> E - Excluir Emitente de Cheque </option>
		<option value="I"> I - Incluir Emitente de Cheque </option>
	</select>
	<a href="#" class="botao" id="btnOK" name="btnOK" onClick="liberaBusca(); return false;" style = "text-align:right;" tabindex="2">OK</a>
		
	<br style="clear:both" />		
	
</form>

