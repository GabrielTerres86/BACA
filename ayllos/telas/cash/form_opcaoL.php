<?php
/*!
 * FONTE        : form_opcaoL.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 16/11/2011
 * OBJETIVO     : Formulario da opção L da tela Cash
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout, botões (David Kruger).
 * --------------
 */ 
?>

<form id="frmOpcaoL" name="frmOpcaoL" class="formulario" onsubmit="return false;">

	<fieldset>
		
		<label for="tprecolh">Informe Envelopes ou Numerarios:</label>
		<select name="tprecolh" id="tprecolh">
		<option value="yes">Envelopes</option>
		<option value="no">Numerarios</option>
		</select>
		
	</fieldset>	

</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="fechaOpcao(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="btnConfirmar('manterRotina(\'GD\');','fechaOpcao();'); return false;">Continuar</a> 
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmOpcaoL'));
	});

</script>