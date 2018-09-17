<?php
/*!
 * FONTE        : form_opcao_c.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 16/07/2014
 * OBJETIVO     : Formulario para cadastro de Contingencia
 * 
 */ 
?>


<div class="div_opcao">																			
	<form id="form_opcao_c" name="form_opcao_c" class="formulario cabecalho" onSubmit="return false;" style="display:none;">
		<input type="hidden" name="cdbircon" id="cdbircon" value="">
		<table class="class_opcao_c" style="margin-left:15px;">	
			<tr>
				<td><label style="float: right;" for="dsbircon">Biro: </label></td>
				<td>
					<select class='campo' id='dsbircon' name='dsbircon' style="width:160px;">
						<option value=''> </option>
					</select>
				</td>
				<td width="10px"> </td>
				<td><label style="float: right;" for="dtinicon">Inic&iacute;o: </label></td>
				<td><input type="text"  id="dtinicon" name="dtinicon" value="" class="campo data"  style="width:160px; text-align:right;" /></td>

			</tr>																						
		</table>																				
	</form>
</div>	

<script type="text/javascript">

	$("#dtinicon").unbind("focus").bind("focus", function() {
	
		if ($(this).val() == "") {
			$(this).val('<?php echo $glbvars['dtmvtolt']; ?>');
		}
	});
	

</script>