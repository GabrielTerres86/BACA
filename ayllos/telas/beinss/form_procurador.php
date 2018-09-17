<? 
 /*!
 * FONTE        : form_procurador.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 03/05/2011 
 * OBJETIVO     : Formulário de exibição
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<form name="frmProcurador" id="frmProcurador" class="formulario">

<fieldset>
	<legend><? echo utf8ToHtml('Dados do Procurador') ?></legend>
	
	<label for="nmprocur"><? echo utf8ToHtml('Nome:') ?></label>
	<input name="nmprocur" id="nmprocur" type="text" />

	<label for="dsdocpcd"><? echo utf8ToHtml('RG:') ?></label>
	<input name="dsdocpcd" id="dsdocpcd" type="text" />

	<label for="cdoedpcd"><? echo utf8ToHtml('OE:') ?></label>
	<input name="cdoedpcd" id="cdoedpcd" type="text" />

	<label for="cdufdpcd"><? echo utf8ToHtml('UF:') ?></label>
	<input name="cdufdpcd" id="cdufdpcd" type="text" />

	<label for="dtvalprc"><? echo utf8ToHtml('Validade:') ?></label>
	<input name="dtvalprc" id="dtvalprc" type="text" />
</fieldset>
	
</form>
