<?php
/*!
 * FONTE        : form_depositante.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Formulário tela DEVOLU
 * --------------
	* ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmDepositante" name="frmDepositante" class="formulario" onSubmit="return false;" style="display:block">
	
	<fieldset id="fsDepositante" style="display:block;">				       
		<legend style="text-align: center">Dados do Depositante</legend>
		<label for="cdbandep"><? echo utf8ToHtml("Banco:") ?></label>
		<input name="cdbandep" type="text"  id="cdbandep" class="campo" values= "" style="width: 55px;" disabled>
		<label for="cdagedep"><? echo utf8ToHtml("Agência:") ?></label>
		<input name="cdagedep" type="text"  id="cdagedep" class="campo" values= ""  style="width: 55px;" disabled>
		<label for="nrctadep"><? echo utf8ToHtml("Conta:") ?></label>
		<input name="nrctadep" type="text"  id="nrctadep" class="campo" values= ""  style="width: 55px;" disabled>
	</fieldset>
	
</form>
