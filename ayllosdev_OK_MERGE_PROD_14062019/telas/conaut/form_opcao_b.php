<?php
/*!
 * FONTE        : form_opcao_b.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 16/07/2014
 * OBJETIVO     : Formulario para cadastro de biros
 * 
 */ 
?>


<div class="div_opcao">																			
	<form id="form_opcao_b" name="form_opcao_b" class="formulario cabecalho" onSubmit="return false;" style="display:none;">
	    <input type="hidden" id="cdbircon" name="cdbircon" value="" >
		<table class="class_opcao_b" style="width:100%">	
			<tr>
				<td style="width:30%"><label style="float: right;" for="dsbircon">Descri&ccedil;&atilde;o:</label></td>
				<td><input type="text"  id="dsbircon" name="dsbircon" maxlength="30" value="" class="campo" style="width:200px" /></td>
			</tr>
			<tr>
				<td style="width:30%"><label style="float: right;" for="nmtagbir">Tag XML:</label></td>
				<td><input type="text"  id="nmtagbir" name="nmtagbir" value="" class="campo"  style="width:200px" /></td>
			</tr>																						
		</table>																				
	</form>
</div>