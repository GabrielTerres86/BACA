<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Lucas                                                     
	 Data : Nov/2011                Última Alteração: 25/10/2012  
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da TAB036.                                  
	                                                                  
	 Alterações: 25/10/2012 - Alteração layout da tela e inclusão botão
							  OK (Daniel).
	**********************************************************************/
?>

<form name="frmCabTab036" id="frmCabTab036" class="formulario cabecalho">
	<table>
	<tr>		
		<td> <label> Op&ccedil;&atilde;o: </label></td>
		<td>
		  <select name="cddopcao" id="cddopcao" class="campo" style="width: 477px;" >
				<option value="C"> C - Consultar Par&acirc;metro</option> 
				<option value="P"> A - Alterar Par&acirc;metro</option>
			</select>
			<a href="#" class="botao" id="btnOK" name="btnOK" onclick="define_operacao(); return false;">OK</a>
		</td>
	</tr>
	</table>
</form>	



