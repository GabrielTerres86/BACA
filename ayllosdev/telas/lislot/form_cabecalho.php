<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Cabeçalho para a tela LISLOT
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
		<option value="T" selected><? echo utf8ToHtml('T - Visualizar listagem dos historicos')?> </option>
		<option value="I" ><? echo utf8ToHtml('I - Imprimir listagem dos historicos') ?> </option>		
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
</form>


