	<?
	/***********************************************************************
	
	  Fonte: form_tab030.php                                               
	  Autor: Lucas                                                  
	  Data : Nov/2011                       Última Alteração: 22/04/2013
	                                                                   
	  Objetivo  : Mostrar valores da TAB030.              
	                                                                 
	  Alterações: 25/05/2012 - Incluido campo 'diasatrs(Dias atraso para relatorio)'
                               (Tiago).	
						   
				  25/10/2012 - Alteração layout tela e inclução botão Voltar 
							   (Daniel). 
							   
				  22/04/2013 - Ajuste para inclusao do parametro "Dias atraso para inadimplencia"
							   (Adriano).
							   
	***********************************************************************/	
	?>
<form id="frmTab030" name="frmTab030" class="formulario">

	<fieldset>

	<legend> <? echo utf8ToHtml('Dados') ?> </legend>
	
		<table> 
			<tr>			
				<td style = "padding-right;"> <label for="vllimite">Valor a ser Desconsiderado (Arrasto):</label> </td>
				<td>
					<input type="text" class="campo" id="vllimite" name="vllimite" style="text-align:right;">
				</td>
			</tr>
			<tr>
				<td  style = "padding-right;"> <label for="vlsalmin">Valor do Salario M&iacute;nimo:</label></td>
				<td> 
					<input type="text" class="campo" id="vlsalmin" name="vlsalmin" style="text-align:right;">
				</td>
				<td align = "left">
					<label>(Atualiza todas as Cooperativas)</label>
				</td>				
			</tr>
			<tr>
				<td align = "right"> <label for="diasatrs">Dias atraso para relat&oacute;rio de provisão:</label></td>
				<td> 
					<input type="text" class="campo" id="diasatrs" name="diasatrs" style="text-align:right;" maxlength="3">
				</td>
				<td align = "left">
					<label>(Adiantamento a Depositante)</label>
				</td>				

			</tr>
			<tr>
				<td align = "right"> <label for="atrsinad">Dias atraso para inadimpl&ecirc;ncia:</label></td>
				<td> 
					<input type="text" class="campo" id="atrsinad" name="atrsinad" style="text-align:right;" maxlength="4">
				</td>
				<td align = "left">
					<label>(Relat&oacute;rio de Provis&atilde;o)</label>
				</td>				

			</tr>
			
		</table>
		
	</fieldset>
	
</form>
		
	
	