<?
/*!
 * FONTE        : form_cabecalho.php                             Última alteração: 29/10/2015 
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 18/08/2015
 * OBJETIVO     : Cabeçalho para a tela CADINF
 * --------------
 * ALTERAÇÕES   : 29/10/2015 - Ajustes de homologação refente a conversão realizada pela DB1
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

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="A" ><? echo utf8ToHtml('A - Alterar os Informativos cadastrados') ?> </option>
		<option value="C" selected><? echo utf8ToHtml('C - Consultar os Informativos cadastrados')?> </option>
		<option value="I" ><? echo utf8ToHtml('I - Incluir Informativo') ?> </option>	
		<option value="E" ><? echo utf8ToHtml('E - Excluir Informativo') ?> </option>	
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
	<div id="divCab" style="display:none"></div>
	
</form>


