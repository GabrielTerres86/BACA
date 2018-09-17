<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Lucas                                                     
	 Data : Nov/2011                Última Alteração: 25/10/2012 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da TAB030.                                  
	                                                                  
	 Alterações: 25/10/2012 - Alteração Layout da Tela, inclusao botão OK,
							  desativado evento onChange do campo cddopcao
							  (Daniel). 				
	**********************************************************************/
?>

<form name="frmCabTab030" id="frmCabTab030" class="formulario cabecalho">
	<table>
	<tr>		
		<td> <label> Op&ccedil;&atilde;o: </label></td>
		<td>
		  <select name="cddopcao" id="cddopcao" class="campo" style="width: 477px;">
				<option value="C"> C - Alterar risco (valor a ser desprezado).</option> 
				<option value="A"> A - Consultar risco (valor a ser desprezado).</option>
			</select>
			<a href="#" class="botao" id="btnOK" name="btnOK" onclick="define_operacao(); return false;">OK</a>
		</td>
	</tr>
	</table>
</form>	
