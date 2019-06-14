<?
/*!
 * FONTE        : form_cabecalho.php				Última alteração: 27/11/2015 
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 18/09/2015
 * OBJETIVO     : Cabeçalho para a tela CADREG
 * -------------- 
 * ALTERAÇÕES   :  27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
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
		<option value="A" ><? echo utf8ToHtml('A - Alterar as Regionais cadastradas') ?> </option>
		<option value="C" selected><? echo utf8ToHtml('C - Consultar as Regionais cadastradas')?> </option>
		<option value="I" ><? echo utf8ToHtml('I - Incluir Regional') ?> </option>			
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
	<div id="divCab" style="display:none"></div>
	
</form>


