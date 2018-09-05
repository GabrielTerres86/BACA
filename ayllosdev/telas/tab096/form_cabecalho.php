<?
/*
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Lucas Reinert
 * DATA CRIA��O : Julho/2015									�LTIMA ALTERA��O: --/--/----
 * OBJETIVO     : Cabe�alho para a tela TAB096
 * --------------
 * ALTERA��ES   : 
 * --------------
 * 20/06/2018 - Adicionado tipo de produto desconto de t�tulo - Luis Fernando (GFT)
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="C"> C - Consultar Par&acirc;metros Cobran&ccedil;a</option> 
		<option value="A"> A - Alterar Par&acirc;metros Cobran&ccedil;a</option>
	</select>
	
	<label for="cdcooper">Cooperativa:</label>
	<select name="cdcooper" id="cdcooper" >
	</select>

	<label for="tpproduto">Produto:</label>
	<select name="tpproduto" id="tpproduto" >
		<option value="0">Empr&eacute;stimo</option>
		<option value="3">Desconto de T&iacute;tulo</option>
	</select>
	
	<a href="#" class="botao" id="btnOK" onClick="controlaOperacao();return false;" style="text-align: right;">OK</a>
	
	<br style="clear:both" />	

</form>

