<?php
	/*!
	 * FONTE        : enviar_em.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 26/09/2017
	 * OBJETIVO     : Arquivo com parte responsável pelos datas de envio
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>
<style>
	.ui-datepicker-trigger{
		float:left;
		margin-left:6px;
		margin-top:6px;
	}
</style> 

<div class="condensado">
	<br/>
	<fieldset>
		<legend><b><? echo utf8ToHtml('Enviar em:')?></b></legend>
		<table>
			<tr>
			<td><label for="dtenvio_mensagem"><? echo utf8ToHtml('Data:'); ?></label></td>
			<td>
				<input type="text" class="campo" name="dtenvio_mensagem" id="dtenvio_mensagem" style="width:70px;" readonly="readonly" value="<?php echo($dtenvio_mensagem); ?>" />
			</td>
			<td><label for="hrenvio_mensagem"><? echo utf8ToHtml('Hora:'); ?></label></td>
			<td>
				<input type="text" class="campo" name="hrenvio_mensagem" id="hrenvio_mensagem" value="<?php echo($hrenvio_mensagem); ?>" style="width:40px;" maxlength="5" />
			</td>
			</tr>
		</table>
	</fieldset>
</div>
<script type="text/javascript">
	$.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );

	/*Mascara referente a campo de inicio de periodo de Ano*/
	$('#dtenvio_mensagem').datepicker({
		dateFormat: "dd/mm/yy",
		changeYear: true,
		changeMonth: false,
		changeDay: false,
		showOn: "button",
		buttonImage: "../../imagens/geral/btn_calendario.gif",
		buttonImageOnly: true
	});
	$('#hrenvio_mensagem').css({ 'width': '40px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
</script>