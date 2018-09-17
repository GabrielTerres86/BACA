	<?
	/***********************************************************************
	
	  Fonte: form_tab007.php                                               
	  Autor: Lucas                                                  
	  Data : Nov/2011                       Última Alteração: 25/10/2012 		   
	                                                                   
	  Objetivo  : Mostrar valores da TAB007.              
	                                                                 
	  Alterações: 25/10/2012 - Alteração layout dos campos na tela (Daniel).

                  15/08/2013 - Alteração da sigla PAC para PA (Carlos)

	***********************************************************************/	
	?>
	
<form id="frmTab007" name="frmTab007" class="formulario">

	<fieldset>

		<legend> <? echo utf8ToHtml('Valores') ?> </legend>

		<table> 
				<tr>
					<td  class="txtNormalBold" style="text-align:right;"> <label for="vlmaidep" align = "right">Depositos acima de (geral):</label></td>
					<td><input type="text" class="campo" id="vlmaidep" name="vlmaidep" style="text-align:right;"></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
				<tr>			
					<td class="txtNormalBold" style="text-align:right;"><label for="vlmaiapl" align = "right">Aplicacoes acima de (geral):</label></td>
					<td><input type="text" class="campo" id="vlmaiapl" name="vlmaiapl" style="text-align:right;"></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td class="txtNormalBold" style="text-align:right;" ><label for="vlmaicot" align = "right">Cotas acima de (geral):</label></td>
					<td><input type="text" class="campo" id="vlmaicot" name="vlmaicot" style="text-align:right;"></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td class="txtNormalBold" style="text-align:right;"><label for="vlmaisal" align = "right">Saldos acima de (por PA):</label></td>			
					<td><input type="text" class="campo" id="vlmaisal" name="vlmaisal" style="text-align:right;"></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
				<tr>	
					<td class="txtNormalBold" style="text-align:right;"><label for="vlsldneg" align = "right">Maiores negativos (por PA):</label></td>		
					<td><input type="text" class="campo" id="vlsldneg" name="vlsldneg" style="text-align:right;"></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
		</table>
		
</fieldset>

</form>