<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/07/2011
 * OBJETIVO     : Cabeçalho para a tela EXTEMP
 * --------------
 * ALTERAÇÕES   : 20/09/2012 - Inclusao de novo layout para botao OK (Lucas R.)
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
		
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK">OK</a>

	<label for="nraplica"><? echo utf8ToHtml('Contrato:') ?></label>
	<input name="nraplica" id="nraplica" type="text" autocomplete="off" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

	<label for="dtiniper"><? echo utf8ToHtml('Data Ini.:') ?></label>
	<input name="dtiniper" id="dtiniper" type="text" />
	
	<label for="dtfimper"><? echo utf8ToHtml('Data Fim:') ?></label>
	<input name="dtfimper" id="dtfimper" type="text" />
	
	<br style="clear:both" />	
	
</form>