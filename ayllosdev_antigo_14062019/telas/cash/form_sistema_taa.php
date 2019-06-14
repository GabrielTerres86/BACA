<?php
/*!
 * FONTE        : form_sistema_taa.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 11/11/2011
 * OBJETIVO     : Formulario sistema TAA
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout (David Kruger).
 * --------------
 */ 
?>

<form id="frmSistemaTAA" name="frmSistemaTAA" class="formulario" onsubmit="return false;">

	<fieldset>
		
		<label for="flsistaa">Sistema TAA:</label>
		<select name="flsistaa" id="flsistaa">
		<option value="yes">Liberado</option>
		<option value="no">Bloqueado</option>
		</select>
		
	</fieldset>	

</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="fechaOpcao(); return false;">Voltar</a>
    <a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">Continuar</a>	
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmSistemaTAA'));
	});

</script>