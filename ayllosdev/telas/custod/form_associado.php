<?
/*!
 * FONTE        : form_associado.php
 * CRIA��O      : Rogerius Milit�o (DB1)
 * DATA CRIA��O : 31/01/2012
 * OBJETIVO     : Formulario que apresenta os dados do associado
 * --------------
 * ALTERA��ES   :
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


<fieldset>
	<legend> Associado </legend>	
	
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

	<label for="nmprimtl">Titular:</label>
	<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
	
</fieldset>		
