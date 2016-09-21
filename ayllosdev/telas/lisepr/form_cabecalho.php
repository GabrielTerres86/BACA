<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Andr� Santos / SUPERO					�ltima altera��o: 25/02/2015
 * DATA CRIA��O : 19/07/2013
 * OBJETIVO     : Formul�rio - tela LISEPR
 * --------------
 * ALTERA��ES   : 25/02/2015 - Corre��o e valida��o da convers�o realizada pela SUPERO
							   (Adriano).
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">

	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="T"> T - Visualizar </option>
		<option value="I"> I - Imprimir </option>
	</select>
	
	<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;" >OK</a>

	<br style="clear:both" />
</form>
