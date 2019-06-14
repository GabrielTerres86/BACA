<?php
/*
 * FONTE        : form_inclusao.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 16/06/2016
 * OBJETIVO     : Formulário de inclusão manual para a tela IMOVEL
 * --------------
 * ALTERAÇÕES   :
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
	<legend id="LG_INCLUSAO"> Informar Inclusão Manual </legend>

	<label for="nrreginc">Número do Registro:</label>
	<input type="text" id="nrreginc" name="nrreginc" maxlength="10" />
	<label for="dtinclus">Data da Inclusão:</label>
	<input type="text" id="dtinclus" name="dtinclus"  />
	<div id="divdsjstinc">
		<label for="dsjstinc">Justificativa para Inclusão Manual:</label>
		<br><br>
		<textarea id="dsjstinc" name="dsjstinc" maxlenght="132"></textarea>
	</div>
	
</fieldset>