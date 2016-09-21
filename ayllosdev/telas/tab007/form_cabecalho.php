<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Lucas                                                     
	 Data : Nov/2011                Última Alteração: 25/10/2012  
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da TAB007.                                  
	                                                                  
	 Alterações: 25/10/2012 - Alterado layout da tela, incluso botão ok,
							  desativado evento onChange do campo cddopcao
						      (Daniel).							  
	**********************************************************************/
?>

<form name="frmCabTab007" id="frmCabTab007" class="formulario cabecalho">
	<table>
	<tr>
		<td> <label> Op&ccedil;&atilde;o: </label></td>
		<td>
		  <select name="cddopcao" id="cddopcao" class="campo"  style="width: 477px;">
				<option value="C"> C - Consultar valores cadastrados para maiores depositantes a serem listados.</option> 
				<option value="P"> A - Alterar valores para maiores depositantes a serem listados.</option>
			</select>
			<a href="#" class="botao" id="btnOK" name="btnOK" onclick="define_operacao(); return false;">OK</a>
		</td>
	</tr>
	</table>
</form>	


