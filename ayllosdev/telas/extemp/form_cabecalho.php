<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/07/2011
 * OBJETIVO     : Cabeçalho para a tela EXTEMP
 * --------------
 * ALTERAÇÕES   : 29/11/2012 - Alterado layout da tela e incluso ocultamento do
 *							   form ao carregar a tela (Daniel).
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
		
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" />
	<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK">OK</a>

	<label for="nmprimtl">Titular:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" />
	
	<br style="clear:both" />	
	
</form>