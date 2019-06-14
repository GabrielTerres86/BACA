<?
/*
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Andr� Clemer
 * DATA CRIA��O : Abril/2018									�LTIMA ALTERA��O: --/--/----
 * OBJETIVO     : Cabe�alho para a tela MANCAR
 * --------------
 * ALTERA��ES   : 
 * --------------
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">	

	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="I">I - Incluir Cart&oacute;rios</option>
		<option value="C">C - Consultar Cart&oacute;rios</option>
		<option value="A">A - Alterar Cart&oacute;rio</option>
		<option value="E">E - Excluir Cart&oacute;rio</option>
	</select>

	<a href="#" class="botao" id="btnOK" onClick="btnOK();return false;" style="text-align: right;">OK</a>
	<br style="clear:both" />	

</form>

