<?
/*!
 * FONTE        : form_cabecalho.php					Último ajuste: 08/12/2015
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 18/08/2015
 * OBJETIVO     : Cabeçalho para a tela CADINF
 * --------------
 * ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1
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
		<option value="C" selected><? echo utf8ToHtml('C - Consulta') ?> </option>
		<option value="B" ><? echo utf8ToHtml('B - Geracao')?> </option>
		<option value="L" ><? echo utf8ToHtml('L - Lancamentos') ?> </option>	
		<option value="X" ><? echo utf8ToHtml('X - Desfazer') ?> </option>	
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
	<div id="divCab" style="display:none"></div>
	
</form>


