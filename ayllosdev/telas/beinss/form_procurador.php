<? 
 /*!
 * FONTE        : form_procurador.php
 * CRIA��O      : Rog�rius Milit�o (DB1)
 * DATA CRIA��O : 03/05/2011 
 * OBJETIVO     : Formul�rio de exibi��o
 * --------------
 * ALTERA��ES   :
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
