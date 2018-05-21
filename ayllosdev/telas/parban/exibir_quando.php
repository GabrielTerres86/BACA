<?php
	/*!
	 * FONTE        : enviar_em.php
	 * CRIAÇÃO      : Gustavo Meyer        
	 * DATA CRIAÇÃO : 26/02/2018
	 * OBJETIVO     : Arquivo com parte responsável pelos periódo de exibição do banner
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
		<legend><b><? echo utf8ToHtml('Exibir quando:')?></b></legend>
		<table>
			<tr>
				<td><input type="radio" value="0" name="inexibir_quando" id="inexibir_quando_sem_expiracao" style="clear:both;"  onClick="acaoBotaoExibirQuandoRadio(0,'','');" /></td>
				<td colspan="4"><? echo utf8ToHtml('Exibir por tempo indeterminado'); ?>
				</td>
			</tr>
			<tr>
				<td><input type="radio" value="1" name="inexibir_quando" id="inexibir_quando_periodo_valido" style="clear:both;"  onClick="acaoBotaoExibirQuandoRadio(1,'<?php echo($dtexibir_de); ?>','<?php echo($dtexibir_ate); ?>');"/>
				</td>
				<td><label for="dtexibir_de"><? echo utf8ToHtml('Exibir de'); ?></label></td>
				<td>
					<input type="text" class="campo" name="dtexibir_de" id="dtexibir_de" style="width:70px;" readonly="readonly" value="<?php echo($dtexibir_de); ?>" />
				</td>
				<td><label for="dtexibir_ate" style="margin-left: 5px;"><? echo utf8ToHtml('at&eacute;:'); ?></label></td>
				<td>
					<input type="text" class="campo" name="dtexibir_ate" id="dtexibir_ate" style="width:70px;" readonly="readonly" value="<?php echo($dtexibir_ate); ?>" />
				</td>
			</tr>
		</table>
	</fieldset>
</div>
<script type="text/javascript">
	$.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );

	/*Mascara referente a campo de inicio de periodo de Ano*/
	$('#dtexibir_de').datepicker({
		dateFormat: "dd/mm/yy",
		changeYear: true,
		changeMonth: false,
		changeDay: false,
		showOn: "button",
		buttonImage: "../../imagens/geral/btn_calendario.gif",
		buttonImageOnly: true
	});

	$('#dtexibir_ate').datepicker({
		dateFormat: "dd/mm/yy",
		changeYear: true,
		changeMonth: false,
		changeDay: false,
		showOn: "button",
		buttonImage: "../../imagens/geral/btn_calendario.gif",
		buttonImageOnly: true
	});

	acaoBotaoExibirQuandoRadio(<?php echo($inexibir_quando); ?>,'<?php echo($dtexibir_de); ?>','<?php echo($dtexibir_ate); ?>');
	
</script>