<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : Maio/2015
 * OBJETIVO     : Mostrar tela ESTFOL
 * --------------
 * ALTERA��ES   : 02/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<div id="divCab" style="display:none">
	</div>
</form>