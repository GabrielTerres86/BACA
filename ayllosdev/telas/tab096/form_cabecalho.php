<?
/*
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Lucas Reinert
 * DATA CRIA��O : Julho/2015									�LTIMA ALTERA��O: --/--/----
 * OBJETIVO     : Cabe�alho para a tela TAB096
 * --------------
 * ALTERA��ES   : 
 * --------------
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="C"> C - Consultar Par&acirc;metros Cobran&ccedil;a de Empr&eacute;stimos</option> 
		<option value="A"> A - Alterar Par&acirc;metros Cobran&ccedil;a de Empr&eacute;stimos</option>
	</select>
	
	<label for="cdcooper">Cooperativa:</label>
	<select name="cdcooper" id="cdcooper" >
	</select>
	
	<a href="#" class="botao" id="btnOK" onClick="controlaOperacao();return false;" style="text-align: right;">OK</a>
	
	<br style="clear:both" />	

</form>

