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

<fieldset id="FS_STATUS">
	<legend> Status </legend>

	<label for="dsstatus">Situação dos dados do imóvel:</label>
	<input type="text" id="dsstatus" name="dsstatus"  />
	
	<div id='divdscritic'>
		<label for="dscritic">Crítica:</label>
		<input type="text" id="dscritic" name="dscritic"  />
	</div>
		
</fieldset>