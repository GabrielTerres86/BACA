<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 27/07/2015
 * OBJETIVO     : Cabeçalho para a tela BANCOS
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

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="A" ><? echo utf8ToHtml('A - Alterar os dados das IFs cadastradas') ?> </option>
		<option value="C" selected><? echo utf8ToHtml('C - Consultar as IFs cadastradas')?> </option>
		<option value="I" ><? echo utf8ToHtml('I - Incluir novo codigo de IF') ?> </option>	
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
</form>


