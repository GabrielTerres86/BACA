<?
/*!
 * FONTE        : form_saldo_anteriores.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 26/10/2011
 * OBJETIVO     : Formulario com os dados do saldo anteriores
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout (David Kruger).
 * --------------
 */

?>

<form id="frmSaldo" name="frmSaldo" class="formulario" onSubmit="return false;">
		
	<fieldset>	
		
		<legend><? echo utf8ToHtml('Saldo do dia '.$dtlimite) ?></legend>

		<label for="vldsdini"><? echo utf8ToHtml('Saldo Inicial:') ?></label>	
		<input name="vldsdini" id="vldsdini" type="text" value="<? echo getByTagName($registro[0]->tags,'vldsdini'); ?>" />
		<br style="clear:both" /><br />
		
		<label for="vlsuprim"><? echo utf8ToHtml('Suprimento (+):') ?></label>
		<input name="vlsuprim" id="vlsuprim" type="text" value="<? echo getByTagName($registro[0]->tags,'vlsuprim'); ?>" />
		<br />

		<label for="vlrecolh"><? echo utf8ToHtml('Recolhimento (-):') ?></label>
		<input name="vlrecolh" id="vlrecolh" type="text" value="<? echo getByTagName($registro[0]->tags,'vlrecolh'); ?>" />
		<br />

		<label for="vldsaque"><? echo utf8ToHtml('Saques (-):') ?></label>
		<input name="vldsaque" id="vldsaque" type="text" value="<? echo getByTagName($registro[0]->tags,'vldsaque'); ?>" />
		<br />

		<label for="vlestorn"><? echo utf8ToHtml('Estornos (+):') ?></label>
		<input name="vlestorn" id="vlestorn" type="text" value="<? echo getByTagName($registro[0]->tags,'vlestorn'); ?>" />
		<br style="clear:both" /><br />

		<label for="vldsdfin"><? echo utf8ToHtml('Saldo Final:') ?></label>
		<input name="vldsdfin" id="vldsdfin" type="text" value="<? echo getByTagName($registro[0]->tags,'vldsdfin'); ?>" />
		<br />

		<label for="vlrejeit"><? echo utf8ToHtml('Rejeitados:') ?></label>
		<input name="vlrejeit" id="vlrejeit" type="text" value="<? echo getByTagName($registro[0]->tags,'vlrejeit'); ?>" />
		<br style="clear:both" /><br />

		<center><? echo getByTagName($registro[0]->tags,'dsobserv'); ?></center>	
		<br style="clear:both" />
		
	</fieldset>

</form>

<div id="divBotoes" style="margin-bottom:8px">
	<a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmSaldo'));
	});

</script>