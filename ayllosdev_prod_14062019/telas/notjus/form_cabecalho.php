<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 14/01/2013
 * OBJETIVO     : Cabeçalho para a tela NOTJUS
 * --------------
 * ALTERAÇÕES   : 19/11/2013 - Ajustes para homologação (Adriano)
 * --------------
 */ 

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">
		
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
	
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK">OK</a>
	
	<label for="nmprimtl">Titular:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo $nmprimtl; ?>" />
	
	<br style="clear:both" />	
	
</form>
