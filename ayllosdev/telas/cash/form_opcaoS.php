<?
/*!
 * FONTE        : form_opcaoS.php
 * CRIACAO      : Jaison
 * DATA CRIACAO : 27/07/2016
 * OBJETIVO     : Formulario da opcao S da tela Cash
 * --------------
 * ALTERACOES   : 
 * --------------
 */
?>

<form id="frmOpcaoS" name="frmOpcaoS" class="formulario" onSubmit="return false;">
	<input type="hidden" id="cdestado" name="cdestado" value="<?php echo ($taa_cdestado ? $taa_cdestado : $pa_cdufdcop); ?>" />
	<fieldset>	

		<legend><? echo utf8ToHtml('Dados Cadastrais') ?></legend>

		<label for="nmterminal"><? echo utf8ToHtml('Nome:') ?></label>
		<input name="nmterminal" id="nmterminal" type="text" value="<?php echo $nmterminal; ?>" />
		<br />

		<label for="nmresage"><? echo utf8ToHtml('Mesma localidade PA:') ?></label>
		<input name="nmresage" id="nmresage" type="text" value="<?php echo $pa_nmresage; ?>" /> 
        <input name="flganexo_pa" id="flganexo_pa" type="checkbox" value="1" checked="checked" onclick="carregaEnderecoPA();" />
		<br />

		<label for="dslogradouro"><? echo utf8ToHtml('Endereço:') ?></label>
		<input name="dslogradouro" id="dslogradouro" type="text" pa_dsendcop="<?php echo $pa_dsendcop; ?>" taa_dsendcop="<?php echo $taa_dsendcop; ?>" />
		<br />

		<label for="dscomplemento"><? echo utf8ToHtml('Complemento:') ?></label>
		<input name="dscomplemento" id="dscomplemento" type="text" pa_dscomple="<?php echo $pa_dscomple; ?>" taa_dscomple="<?php echo $taa_dscomple; ?>" />
		<br />

		<label for="nrendere"><? echo utf8ToHtml('Número:') ?></label>
		<input name="nrendere" id="nrendere" type="text" pa_nrendere="<?php echo $pa_nrendere; ?>" taa_nrendere="<?php echo $taa_nrendere; ?>" />
		<br />

		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" pa_nmbairro="<?php echo $pa_nmbairro; ?>" taa_nmbairro="<?php echo $taa_nmbairro; ?>" />
		<br />

		<label for="nrcep"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcep" id="nrcep" type="text" pa_nrcepend="<?php echo $pa_nrcepend; ?>" taa_nrcepend="<?php echo $taa_nrcepend; ?>" />
		<br />

		<label for="idcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input type="text" id="idcidade" name="idcidade" pa_idcidade="<?php echo $pa_idcidade; ?>" taa_idcidade="<?php echo $taa_idcidade; ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" id="dscidade" name="dscidade" pa_dscidade="<?php echo $pa_dscidade; ?>" taa_dscidade="<?php echo $taa_dscidade; ?>" />

		<label for="nrlatitude"><? echo utf8ToHtml('Latitude:') ?></label>
        <input name="nrlatitude" id="nrlatitude" type="text" pa_nrlatitude="<?php echo $pa_nrlatitu; ?>" taa_nrlatitude="<?php echo $taa_nrlatitu; ?>" />
		<br />

        <label for="nrlongitude"><? echo utf8ToHtml('Longitude:') ?></label>
        <input name="nrlongitude" id="nrlongitude" type="text" pa_nrlongitude="<?php echo $pa_nrlongit; ?>" taa_nrlongitude="<?php echo $taa_nrlongit; ?>" />
		<br />

		<label for="dshorario"><? echo utf8ToHtml('Horário:') ?></label>
		<textarea name="dshorario" id="dshorario"><?php echo $dshorario; ?></textarea>

		<br style="clear:both" />

	</fieldset>

</form>

<div id="divBotoes" style="margin-bottom:8px">
	<a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Continuar</a>
</div>

<script> 
	$(document).ready(function(){
		highlightObjFocus($('#frmOpcaoS'));
	});

    $('#flganexo_pa', '#frmOpcaoS').prop("checked", <?php echo ($flganexo_pa ? 'true' : 'false'); ?>);

    carregaEnderecoPA();
</script>