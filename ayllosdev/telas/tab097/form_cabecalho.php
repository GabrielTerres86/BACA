<?
/*
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Jaison Fernando
 * DATA CRIA��O : Novembro/2015									�LTIMA ALTERA��O: --/--/----
 * OBJETIVO     : Cabe�alho para a tela TAB097
 * --------------
 * ALTERA��ES   : 
 * --------------
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">	

	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="C"> C - Consultar Parametriza&ccedil;&atilde;o</option> 
		<option value="A"> A - Alterar Parametriza&ccedil;&atilde;o</option>
	</select>
	
	<a href="#" class="botao" id="btnOK" onClick="btnOK();return false;" style="text-align: right;">OK</a>
	
	<br style="clear:both" />	

</form>

