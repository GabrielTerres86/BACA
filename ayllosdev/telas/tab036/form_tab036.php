	<?
	/***********************************************************************
	
	  Fonte: form_tab036.php                                               
	  Autor: Lucas                                                  
	  Data : Nov/2011                       Última Alteração: 24/10/2012		   
	                                                                   
	  Objetivo  : Mostrar valores da TAB036.              
	                                                                 
	  Alterações: 24/10/2012 - Alteração layout da tela. (Daniel) 	  
	
	***********************************************************************/	
	?>
	
<form id="frmTab036" name="frmTab036" class="formulario">

	<fieldset>
		<legend><? echo utf8ToHtml('Par&acirc;metros') ?></legend>
	
		<table> 
			<tr>	
				<td style = "padding-right;"> <label for="vlrating">Valor de Rating:</label> </td>
				<td>
					<input class="campo" id="vlrating" name="vlrating" style="text-align:right;">
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td style = "padding-right;"> <label for="vlgrecon">Grupo Econ&ocirc;mico:</label> </td>
				<td> 
					<input class="campo" id="vlgrecon" name="vlgrecon" style="text-align:right;"><label for="percent">&nbsp;%&nbsp;</label>
				</td>
			</tr>			
		</table>
	</fieldset>
	
</form>
		
	
	