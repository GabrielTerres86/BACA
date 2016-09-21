	<?
	/***********************************************************************
	
	  Fonte: form_tab002.php                                               
	  Autor: Lucas                                                  
	  Data : Nov/2011                       Última Alteração: 23/10/2012 		   
	                                                                   
	  Objetivo  : Mostrar valores da Tab002.              
	                                                                 
	  Alterações: 23/10/2012 - Alterado layout tela. (Daniel)	  
	
	***********************************************************************/	
	?>
	

<form id="frmTab002" name="frmTab002" class="formulario">

	<fieldset>
		<legend><? echo utf8ToHtml('Qtd. Folhas') ?></legend>
		
		<table> 

			<tr>
				<td  class="txtNormalBold" style="text-align:right;"> <label for="qtfolind" align = "right">Qtd. Folhas para Contas Individuais:</label></td>
				<td><input  type="text" class="campo" id="qtfolind" name="qtfolind"  size = "4" maxlength = "3" style="text-align:right;"/></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>			
				<td class="txtNormalBold" style="text-align:right;"><label for="qtfolcjt" align = "right">Qtd. Folhas para Contas Conjuntas:</label></td>
				<td><input  type="text" class="campo" id="qtfolcjt" name="qtfolcjt"  size = "4" maxlength = "3" style="text-align:right;" /></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
			</tr>
		</table>
							
	</fieldset>
	
</form>