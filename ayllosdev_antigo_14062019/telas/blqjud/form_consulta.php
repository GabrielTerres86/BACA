<?
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 23/04/2013
 * OBJETIVO     : Mostrar campos da opcao C - Consultar
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>
<div id="divConsulta" style="display:none;">
<form id="frmConsulta" name="frmConsulta" class="formulario" onsubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Consultar por Nr.Of&iacute;cio ou Conta/CPF'); ?></legend>

        <label for="nroficon"><? echo utf8ToHtml('N&uacute;mero do Of&iacute;cio:') ?></label>
        <input id="nroficon" name="nroficon" type="text" maxlength="25"  />
        <br style="clear:both;" />
		<label for="nrctacon"><? echo utf8ToHtml('Conta ou CPF/CNPJ:') ?></label>
		<input id="nrctacon" name="nrctacon" type="text" maxlength="14"  />
        <br style="clear:both;" />
	</fieldset>
	
	<div id="divDadosConsulta" style='display:none;'>
	
		<br/>
		<br style="clear:both;" />
		<hr style="background-color:#666; height:1px;" />
	</div>
	
</form>
</div>
