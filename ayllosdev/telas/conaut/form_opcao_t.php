<?php
/*!
 * FONTE        : form_opcao_t.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 16/07/2014
 * OBJETIVO     : Formulario para tempo de resposta da Ibratan
 * 
 */ 
?>


<div class="div_opcao">																			
	<form id="form_opcao_t" name="form_opcao_t" class="formulario cabecalho" onSubmit="return false;" style="display:none;">
		<table class="class_opcao_t" style="margin-left:30%">	
			<tr>
				<td><label style="float: right;" for="qtsegrsp">Tempo (segundos):</label></td>
				<td><input type="text"  id="qtsegrsp" name="qtsegrsp" maxlength="4" value="0" class="campo somenteNumeros" style="text-align:right;" /></td>
			</tr>																						
		</table>																				
	</form>
</div>	