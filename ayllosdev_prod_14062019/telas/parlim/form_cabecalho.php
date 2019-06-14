<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Lucas Ranghetti
	 Data : Fevereiro/2017                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da tela PARLIM.                                  
	                                                                  
	 Alterações:		 		
	 
	**********************************************************************/
	
?>

<form name="frmCab" id="frmCab" class="formulario cabecalho">
	
	<table>
		<tr>	
			<td> <label> Op&ccedil;&atilde;o: </label></td>
			<td>
			  <select name="cddopcao" id="cddopcao" class="campo" style="width: 477px;">
					<option value="C"> C - Consultar os parametros para cobranca de juros</option> 
					<option value="A"> A - Alterar os parametros para cobranca de juros  </option>				
					<option value="I"> I - Incluir os parametros para cobranca de juros  </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onclick="define_operacao(); return false;">OK</a>
			</td>
		</tr>
	</table>	
	
</form>	

