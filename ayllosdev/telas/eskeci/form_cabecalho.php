<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : 27/06/2011
 * OBJETIVO     : Cabeçalho para a tela ESKECI
 * --------------
 * ALTERAÇÕES   : 18/09/2012 - Alterado layout do botao OK para novo padrao (Lucas R.)
 * --------------
 */ 
?>

<form id="frmCabEskeci" name="frmCabEskeci" class="formulario cabecalho" onsubmit="buscaCartao();return false;">	
	
	<label for="nrcartao">N&uacute;mero do Cart&atilde;o:</label>
	<input type="text" id="nrcartao" name="nrcartao" alt="Informe o nro. do cart&atilde;o do cooperado." />
   	<a href="#" class="botao" id="btBuscaCartao" onClick="buscaCartao();return false;">OK</a>  
	<input type="image" id="btBuscaCartao" src="<? echo $UrlImagens; ?>geral/refresh.png" onclick="estadoInicial();return false;"/>
		
	<br style="clear:both" />	
	
</form>