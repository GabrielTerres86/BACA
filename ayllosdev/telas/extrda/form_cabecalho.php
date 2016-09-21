<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 01/08/2011
 * OBJETIVO     : Cabeçalho para a tela EXTRAT
 * --------------
 * ALTERAÇÕES   : 26/10/2012 - Alteração layout, retirado gif e incluso
							   botão OK (Daniel).
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
		
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo getByTagName($dados,'nrdconta'); ?>" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK">OK</a>

	<label for="nmprimtl">Titular:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo getByTagName($dados,'nmprimtl'); ?> <? echo getByTagName($dados,'nmsegntl'); ?>" />
	
	<br style="clear:both" />	
	
</form>