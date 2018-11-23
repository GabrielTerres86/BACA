<?php
	/*!
	 * FONTE        : form_cadastro_tarifa.php
	 * CRIAÇÃO      : Alcemir Junior - Mout's
	 * DATA CRIAÇÃO : 21/09/2018
	 * OBJETIVO     : Cadastro de parametros para a tela PARCBA
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divCadastroTarifa" name="divCadastroTarifa">
	<form id="frmCadTarifa" name="frmCadTarifa" class="formulario" onSubmit="return false;" style="display:block">
		<fieldset id="fscadtar" style="display: none">
		<legend>Tarifa Bancoob</legend>
			<label for="cdhistor"><? echo utf8ToHtml("Hist&oacute;rico:") ?></label>
			<input name="cdhistor" type="text"  id="cdhistor" class="inteiro campo" style="width: 50px;">

			<label for="dsexthst"><? echo utf8ToHtml("Descri&ccedil;&atilde;o:") ?></label>
			<input name="dsexthst" type="text"  id="dsexthst" class="campo" style="width: 300px;">		

			<br style="clear:both" />

			<label for="dscontabil"><? echo utf8ToHtml("Descri&ccedil;&atilde;o Cont&aacute;bil:") ?></label>
			<input class="campo" id="dscontabil" name="dscontabil" type="text" style="width: 350px;">

			<br style="clear:both" />
			
			<label for="nrctadeb_pf"><? echo utf8ToHtml("Conta D&eacute;bito PF:") ?></label>
			<input name="nrctadeb_pf" type="text"  id="nrctadeb_pf" class="inteiro campo" style="width: 75px;">
			
			<label for="nrctacrd_pf"><? echo utf8ToHtml("Conta Cr&eacute;dito PF:") ?></label>
			<input name="nrctacrd_pf" type="text"  id="nrctacrd_pf" class="inteiro campo" style="width: 75px;">
			
			<br style="clear:both" />
			
			<label for="nrctadeb_pj"><? echo utf8ToHtml("Conta D&eacute;bito PJ:") ?></label>
			<input name="nrctadeb_pj" type="text"  id="nrctadeb_pj" class="inteiro campo" style="width: 75px;">
			
			<label for="nrctacrd_pj"><? echo utf8ToHtml("Conta Cr&eacute;dito PJ:") ?></label>
			<input name="nrctacrd_pj" type="text"  id="nrctacrd_pj" class="inteiro campo" style="width: 75px;">
        </fieldset>
	</form>
</div>