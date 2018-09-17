<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 22/07/2011
 * OBJETIVO     : Cabeçalho para a tela DESEXT
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Inclusão de novo layout para botao OK (Lucas R.)
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
		
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK"  >OK</a>
	

	<label for="cdsecext">Destino</label>
	<input type="text" id="cdsecext" name="cdsecext" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
	<label for="tpextcta">Extrato:</label>
	<input type="text" id="tpextcta" name="tpextcta" />

	<label for="tpavsdeb">Avisos:</label>
	<input type="text" id="tpavsdeb" name="tpavsdeb" />

	<br />
	
	<label for="nmprimtl">Titular:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" />
	
	<br style="clear:both" />	
	
</form>