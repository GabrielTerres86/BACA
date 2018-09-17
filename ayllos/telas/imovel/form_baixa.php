<?php
/*
 * FONTE        : form_baixa.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 16/06/2016
 * OBJETIVO     : Formulário de baixa manual para a tela IMOVEL
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

<fieldset id="FS_BAIXA">
	<legend id="LG_BAIXA"> Informar Baixa Manual </legend>

	<!-- LINHA 1 -->
	<label for="dtdbaixa">Data da Baixa:</label>
	<input type="text" id="dtdbaixa" name="dtdbaixa"  />
	<div id="divdsjstbxa">
		<label for="dsjstbxa">Justificativa para Baixa Manual:</label>
		<br><br>
		<textarea id="dsjstbxa" name="dsjstbxa" maxlenght="132"></textarea>
	</div>
	
</fieldset>