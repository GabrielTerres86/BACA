<?
/**************************************************************************************
	ATEN��O: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODU��O TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

/*
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Tiago
 * DATA CRIA��O : Julho/2012									�LTIMA ALTERA��O: 04/10/2012
 * OBJETIVO     : Cabe�alho para a tela TAB094
 * --------------
 * ALTERA��ES   : 02/10/2012 - Inclu�do o campo Cooperativa (Adriano).
 * 				  04/07/2013 - Alterado para receber o novo layout padr�o do Ayllos Web (Reinert).
 * --------------
 */ 
?>

<form id="frmCabTab094" name="frmCabTab094" class="formulario cabecalho" style="display:none;">	
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="C"> C - Consultar</option> 
		<option value="A"> A - Alterar</option>
	</select>
	
	<label for="cdcooper">Cooperativa:</label>
	<select name="cdcooper" id="cdcooper" >
	</select>
	
	<a href="#" class="botao" id="btnOK" onClick="acesso_opcao();return false;" style="text-align: right;">OK</a>
	
	<br style="clear:both" />	

</form>