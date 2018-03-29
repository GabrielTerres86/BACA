<?php
/*!
 * FONTE        : form_opcao_r.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 16/07/2014
 * OBJETIVO     : Formulario para cadastro de reaproveitamento de consultas
 * 
 * --------------
 * ALTERAÇÕES   : 13/10/2015 - Projeto Reformulacao Cadastral (Tiago Castro - RKAM). 
 				  29/03/2018 - Ajustes para inclusão de novo produto. (Alex Sandro - GFT)
 * --------------
 */  
?>


<div class="div_opcao">																			
	<form id="form_opcao_r" name="form_opcao_r" class="formulario cabecalho" onSubmit="return false;" style="display:none;">
		<input type="hidden" name="flgselec" id="flgselec" value="">
		<table class="class_opcao_r">	
			<tr>
				<td><label style="float: right;" for="inprodut">Produto: </label></td>
				<td>
					<select class='campo' id='inprodut' name='inprodut' style="width:180px;">
						<option value='1'> Empr&eacute;stimo          </option>
						<option value='2'> Financiamento	          </option>
						<option value='3'> Cheque Especial            </option>
						<option value='4'> Desconto de cheque         </option>
						<option value='5'> Desconto de t&iacute;tulos </option>
						<option value='6'> Cadastro Conta </option>
						<option value='7'> Border&ocirc; de T&iacute;tulos </option>
					</select>
				</td>
				<td width="2px"> </td>
				<td><label style="float: right;" for="inpessoa">Tipo pessoa: </label></td>
				<td>
					<select class='campo' id='inpessoa' name='inpessoa' style="width:180px;">
						<option value='1'> F&iacute;sica </option>
						<option value='2'>Jur&iacute;dica </option>
					</select>
				</td>
			</tr>	
			<tr>	
				<td><label style="float: right;" for="qtdiarpv">Qtde Dias:</label></td>
				<td><input type="text"  id="qtdiarpv" name="qtdiarpv" value="" class="campo somenteNumeros" maxlength="3" style="width:180px; text-align:right;" /></td>
			</tr>																							
		</table>																				
	</form>
</div>	