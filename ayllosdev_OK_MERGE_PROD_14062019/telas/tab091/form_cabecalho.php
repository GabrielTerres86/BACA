<?
/*******************************************************************************************
  FONTE        : form_cabecalho.php
  CRIAÇÃO      : Adriano
  DATA CRIAÇÃO : Agosto/2011
  OBJETIVO     : Cabeçalho para a tela TAB091
  Última Alteração: 18/02/2013.
  --------------
  ALTERAÇÕES   : 18/02/2013 - Ajustes referente ao projeto Cadastro Restritivo (Adriano).
  --------------
 ******************************************************************************************/ 
?>

<form id="frmCabTab091" name="frmCabTab091" class="formulario cabecalho" style="display:none;">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" alt="Informe a op&ccedil;&atilde;o desejada (A ou C).">
		<option value="C"> C - Consultar</option> 
		<option value="A"> A - Alterar</option>
	</select>
	
	<label for="cdcooper">Cooperativa:</label>
	<select name="cdcooper" id="cdcooper" >
	</select>
	
	<a href="#" class="botao" id="btOK"  onClick="obtemConsulta();return false;" style="text-align: right;">OK</a>
	
	<br style="clear:both" />	

</form>