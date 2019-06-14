<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Lucas                                                     
	 Data : Nov/2011                Última Alteração: 23/10/2012  
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da Tab002.                                  
	                                                                  
	 Alterações:	23/10/2012 - Alterado select campo cddopcao, incluso
								 botão OK (Daniel).							 		
	 
	**********************************************************************/
	
?>

<form name="frmCabTab002" id="frmCabTab002" class="formulario cabecalho">

	
	<table>
	<tr>	
		<td> <label> Op&ccedil;&atilde;o: </label></td>
		<td>
		  <select name="cddopcao" id="cddopcao" class="campo" style="width: 477px;">
				<option value="C"> C - Consultar os dados para acompanhamento de talonarios</option> 
				<option value="A"> A - Alterar os dados para acompanhamento de talonarios</option>
				<option value="E"> E - Excluir os dados para acompanhamento de talonarios</option>
				<option value="I"> I - Incluir os dados para acompanhamento de talonarios</option>
			</select>
			<a href="#" class="botao" id="btnOK" name="btnOK" onclick="define_operacao(); return false;">OK</a>
		</td>
	</tr>
	</table>	
	
</form>	

