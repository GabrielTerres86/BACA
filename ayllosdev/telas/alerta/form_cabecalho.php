<?
/*****************************************************************
  Fonte        : form_cabecalho.php
  Cria��o      : Adriano
  Data cria��o : Fevereiro/2013
  Objetivo     : Cabe�alho para a tela ALERTA
  --------------
  Altera��es   : 15/09/2014 - Chamado 152916 (Jonata-RKAM).
  --------------
 ****************************************************************/ 
?>

<form id="frmCabAlerta" name="frmCabAlerta" class="formulario cabecalho" style="display:none;">	
	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="C"> C - Consultar </option> 
		<option value="E"> E - Excluir </option>
		<option value="I"> I - Incluir </option>
		<option value="L"> L - Liberar com justificativa </option>
		<option value="R"> R - Relat�rios </option> <!--  de alerta emitidos -->
		<option value="V"> V - Vinculos </option>
		
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
	
	<br style="clear:both" />	
	
</form>