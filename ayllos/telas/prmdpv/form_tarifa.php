<?
/*!
 * FONTE        : form_prmdpv.php
 * CRIAÇÃO      : Lucas Moreira
 * DATA CRIAÇÃO : 04/09/2015
 * OBJETIVO     : Formulario para tela PRMDPV
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<div id="divPrmdpv" name="divPrmdpv">
	<form id="frmTarifaPorCanal" name="frmTarifaPorCanal" class="formulario" onSubmit="return false;">
		<fieldset>
			<legend>Tarifa por canal</legend>
			<table width="100%">
				<tr>		
					<td width="60px">
						<label for="caixa"><? echo utf8ToHtml('Caixa:') ?></label>	
					</td>
					<td>
					<input name="caixa" type="text"  id="caixa" class='campo' value="<?php echo $caixa ?>" />
					</td>
				</tr>
				<tr>		
					<td width="60px">
						<label for="internet"><? echo utf8ToHtml('Internet:') ?></label>
					</td>
					<td>
						<input name="internet" type="text"  id="internet" class='campo' value="<?php echo $internet ?>" />
					</td>
				</tr>
				<tr>		
					<td width="60px">
						<label for="taa"><? echo utf8ToHtml('TAA:') ?></label>
					</td>
					<td>
						<input name="taa" type="text"  id="taa" class='campo' value="<?php echo $taa ?>" />
					</td>
				</tr>
			</table>
		</fieldset>
		
		<div id="divBotoes" style="margin-top:5px; margin-bottom :10px;">
			<a href="#" class="botao" id="btVoltar"  onclick="controlaOperacao('');">Voltar</a>
			<a href="#" class="botao" id="btGravar"  onClick="controlaOperacao('GT');">Gravar</a>
		</div>
	</form>
</div>