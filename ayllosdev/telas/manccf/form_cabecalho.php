<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/07/2013
 * OBJETIVO     : Cabeçalho para a tela MANCCF
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
	
	<input type="hidden" name="dsseqdig" id="dsseqdig" >
	<input type="hidden" name="nrdcontaImp" id="nrdcontaImp" >
				
	<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
	<input id="nrdconta" name="nrdconta" type="text"/>
	<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisas();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<label for="nmprimtl"><? echo utf8ToHtml('Titular:') ?></label>
	<input id="nmprimtl" name="nmprimtl" type="text"/>
		
	<br style="clear:both" />		
	
</form>

