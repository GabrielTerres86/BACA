<?php
/*
 * FONTE        : form_inclusao.php
 * CRIA��O      : Renato Darosci (Supero)
 * DATA CRIA��O : 16/06/2016
 * OBJETIVO     : Formul�rio de inclus�o manual para a tela IMOVEL
 * --------------
 * ALTERA��ES   :
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

?>
<style>
textarea.campoTelaSemBorda {
    color: #555 !important;
    border-color: #ddd !important;
}
</style>

<fieldset id="FS_INCLUSAO">
	<legend id="LG_INCLUSAO"> Informar Inclus�o Manual </legend>

	<label for="nrreginc">N�mero do Registro:</label>
	<input type="text" id="nrreginc" name="nrreginc" maxlength="10" />
	<label for="dtinclus">Data da Inclus�o:</label>
	<input type="text" id="dtinclus" name="dtinclus"  />
	<div id="divdsjstinc">
		<label for="dsjstinc">Justificativa para Inclus�o Manual:</label>
		<br><br>
		<textarea id="dsjstinc" name="dsjstinc" maxlenght="132"></textarea>
	</div>
	
</fieldset>