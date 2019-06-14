<?php
/*!
 * FONTE        : form_opcao_m.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 16/07/2014
 * OBJETIVO     : Formulario para cadastrar modalidades
 * 
 */ 
?>


<div class="div_opcao">																			
	<form id="form_opcao_m" name="form_opcao_m" class="formulario cabecalho" onSubmit="return false;" style="display:none;" >
		<input type="hidden" id="cdmodbir" name="cdmodbir" value="">
		<input type="hidden" id="cdbircon" name="cdbircon" value="">
		<table class="class_opcao_m">	
			<tr>
				<td><label style="float: right;" for="dsbircon">Biro: </label></td>
				<td>
					<select class='campo' id='dsbircon' name='dsbircon' style="width:200px;">
						<option value=""> </option>
					</select>
				</td>
				<td width="10px"> </td>
				<td><label style="float: right;" for="dsmodbir">Descri&ccedil;&atilde;o:</label></td>
				<td><input type="text"  id="dsmodbir" name="dsmodbir" maxlength="30" value="" class="campo" /></td>
			</tr>
			<tr>
				<td><label style="float: right;" for="inpessoa">Tipo pessoa: </label></td>
				<td>
					<select class='campo' id='inpessoa' name='inpessoa' style="width:200px;">
						<option value='1'> F&iacute;sica </option>
						<option value='2'>Jur&iacute;dica </option>
					</select>
				</td>
				<td width="10px"> </td>
				<td><label style="float: right;" for="nmtagmod">Tag XML:</label></td>
				<td><input type="text"  id="nmtagmod" name="nmtagmod" value="" class="campo" /></td>
			</tr>	
		    <tr>
				<td><label style="float: right;" for="nrordimp">Ordem import&acirc;ncia:</label></td>
				<td><input type="text"  id="nrordimp" name="nrordimp" value="" class="campo somenteNumeros" style="width:200px; text-align:right;" maxlength="3" /></td>
			</tr>		
		</table>																				
	</form>
</div>	