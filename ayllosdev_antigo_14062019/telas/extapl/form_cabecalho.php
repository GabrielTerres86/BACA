<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 01/08/2011
 * OBJETIVO     : Cabeçalho para a tela EXTRAT
 * --------------
 * ALTERAÇÕES   : 30/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> novo layout, alterado para não mostrar
 * 							   form ao carregar a tela (Daniel).
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
		
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo getByTagName($dados,'nrdconta'); ?>" />
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK">OK</a>


	<label for="nmprimtl">Titular:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo getByTagName($dados,'nmprimtl'); ?>" />
	
	<br style="clear:both" />	
	
</form>