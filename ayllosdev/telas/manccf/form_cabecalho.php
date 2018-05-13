<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/07/2013
 * OBJETIVO     : Cabeçalho para a tela MANCCF
 * --------------
	* ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">	
	
	<input type="hidden" name="dsseqdig" id="dsseqdig" >
	<input type="hidden" name="nrdcontaImp" id="nrdcontaImp" >
				
	<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
	<input id="nrdconta" name="nrdconta" type="text" tabindex="1" />
	<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisas();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
	
	<a href="#" class="botao" id="btnOK" tabindex="2">OK</a>
	
	<label for="nmprimtl">T&iacute;tular:</label>
	<input id="nmprimtl" name="nmprimtl" type="text"/>
		
	<br style="clear:both" />		
	
</form>

