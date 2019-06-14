	<?
	/***********************************************************************
	
	  Fonte: form.php                                               
	  Autor: Lucas Ranghetti                                                 
	  Data : Fevereiro/2017                       Última Alteração:
	                                                                   
	  Objetivo  : Mostrar Campos da tela PARLIM              
	                                                                 
	  Alterações: 
	
	***********************************************************************/	
	?>
	

<form id="frmParlim" name="frmParlim" class="formulario">

	<fieldset>
		<legend><? echo utf8ToHtml(' Parametros para cobranca de juros ') ?></legend>
		
		<table> 

			<tr>
				<td  class="txtNormalBold" style="text-align:left;"> <label for="qtdiacor" align = "left">Qtd. Dias corridos:</label></td>
				<td><input  type="text" class="campo" id="qtdiacor" name="qtdiacor"  size = "4" maxlength = "4" style="text-align:right;"/></td>
			</tr>			
			<tr>			
				<td class="txtNormalBold" style="text-align:right;"><label for="vlminchq" align = "left">Valor min. para cobrança de juros de cheque especial:</label></td>
				<td><input  type="text" class="campo" id="vlminchq" name="vlminchq" style="text-align:right;" /></td>
			</tr>
			<tr>			
				<td class="txtNormalBold" style="text-align:right;"><label for="vlminiof" align = "right">Valor min. para cobrança de IOF:</label></td>
				<td><input  type="text" class="campo" id="vlminiof" name="vlminiof" style="text-align:right;" /></td>
			</tr>
			<tr>			
				<td class="txtNormalBold" style="text-align:right;"><label for="vlminadp" align = "right">Valor min. para cobrança de juros de adiantamento a depositante:</label></td>
				<td><input  type="text" class="campo" id="vlminadp" name="vlminadp" style="text-align:right;" /></td>
			</tr>
		</table>			
	</fieldset>
</form>