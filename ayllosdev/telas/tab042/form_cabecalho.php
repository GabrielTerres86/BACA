<?
/*
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Henrique
 * DATA CRIA��O : 27/06/2011
 * OBJETIVO     : Cabe�alho para a tela TAB042
 * --------------
 * ALTERA��ES   : 25/10/2012 - Altera��o layout da tela e inclus�o
							   bot�o Ok (Daniel).
 * --------------
 */ 
?>

<form id="frmCabTab042" name="frmCabTab042" class="formulario cabecalho" >	
	<table>
	<tr>		
		<td> <label> Op&ccedil;&atilde;o: </label></td>
		<td>
		  <select id="cddopcao" name="cddopcao" class="campo" style="width: 460px;" >
				<option value="C"> C - Consultar contas liberadas do prazo minimo exigido para movimentar.</option> 
				<option value="A"> A - Alterar contas para liberacao de prazo minimo exigido para movimentar.</option>
			</select>
			<a href="#" class="botao" id="btnOK" name="btnOK" onClick="carrega_dados()">OK</a>
		</td>
	</tr>
	</table>
</form>