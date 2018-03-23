<?
/*!
 * FONTE        : form_contacontrato.php
 * CRIAÇÃO      : Marcel Kohls / AMCom
 * DATA CRIAÇÃO : 20/03/2018
 * OBJETIVO     : Formulario de conta e contrato
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 ?>

<form id="frmCntCtr" name="frmCntCtr" class="formulario">

	<fieldset>
		<legend> <? echo utf8ToHtml('Conta e Contrato');  ?> </legend>	
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="nrctrato">Contrato:</label>
		<input type="text" id="nrctrato" name="nrctrato" value="<?php echo $nrctrato ?>"/>		
	</fieldset>	

</form>