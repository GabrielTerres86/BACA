<?
/*
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : 27/06/2011
 * OBJETIVO     : Cabeçalho para a tela TAB042
 * --------------
 * ALTERAÇÕES   : 25/10/2012 - Alteração layout da tela e inclusão
							   botão Ok (Daniel).
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