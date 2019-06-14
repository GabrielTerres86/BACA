<?php
/*!
 * FONTE        : form_opcao_p.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 16/07/2014
 * OBJETIVO     : 
 *				 
 * --------------
 * ALTERAÇÕES   : 13/10/2015 - Projeto Reformulacao Cadastral (Tiago Castro - RKAM).
 				  29/03/2018 - Ajustes para inclusão de novo produto. (Alex Sandro - GFT) 
 * --------------
 */ 
?>


<div class="div_opcao">																		
	<form id="form_opcao_p" name="form_opcao_p" class="formulario cabecalho" onSubmit="return false;" style="display:none;">
		<input type="hidden" name="cdbircon" id="cdbircon" value="">
		<input type="hidden" name="cdmodbir" id="cdmodbir" value="">
		
		<table class="class_opcao_p">	
			<tr>
				<td><label style="float: right;" for="inprodut">Produto: </label></td>
				<td>
					<select class='campo' id='inprodut' name='inprodut' style="width:160px;">
						<option value='1'> Empr&eacute;stimo          </option>
						<option value='2'> Financiamento	          </option>
						<option value='3'> Cheque Especial            </option>
						<option value='4'> Desconto de cheque         </option>
						<option value='5'> Desconto de t&iacute;tulos </option>
						<option value='6'> Cadastro Conta </option>
						<option value='7'> Border&ocirc; de T&iacute;tulos </option>
					</select>
				</td>
				<td width="10px"></td>
				<td><label style="float: right;" for="inpessoa">Tipo Pessoa: </label></td>
				<td>
					<select class='campo' id='inpessoa' name='inpessoa' style="width:160px;">
						<option value='1'> F&iacute;sica </option>
						<option value='2'>Jur&iacute;dica </option>
					</select>
				</td>
			</tr>
			<tr>
				<td><label style="float: right;" for="dsbircon">Biro: </label></td>
				<td>
					<select class='campo' id='dsbircon' name='dsbircon' style="width:160px;">
						<option value=""> </option>
					</select>
				</td>
				<td width="10px"></td>
				<td><label style="float: right;" for="dsmodbir">Modalidade: </label></td>
				<td>
					<select class='campo' id='dsmodbir' name='dsmodbir' style="width:160px;">
						<option value=""> </option>
					</select>
				</td>	
			</tr>
			<tr>
				<td><label style="float: right;" for="vlinicio">Valor inicial:</label></td>
				<td><input type="text"  id="vlinicio" name="vlinicio" value="" class="campo somenteNumeros" style="width:160px; text-align:right;" /></td>
			</tr>	
		</table>																				
	</form>
</div>	