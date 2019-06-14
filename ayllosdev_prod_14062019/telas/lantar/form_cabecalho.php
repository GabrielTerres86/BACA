<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 13/03/2013
 * OBJETIVO     : Cabeçalho para a tela LANTAR
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
		
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta ?>" />
	<a href="#" onclick="pesquisaAssociados(); return false;" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK" >OK</a>

	<br style="clear:both" />	
	
	<input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />
</form>