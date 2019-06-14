<?php
/*
 * FONTE        : form_baixa.php
 * CRIA��O      : Renato Darosci (Supero)
 * DATA CRIA��O : 16/06/2016
 * OBJETIVO     : Formul�rio de baixa manual para a tela IMOVEL
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

<fieldset id="FS_STATUS">
	<legend> Status </legend>

	<label for="dsstatus">Situa��o dos dados do im�vel:</label>
	<input type="text" id="dsstatus" name="dsstatus"  />
	
	<div id='divdscritic'>
		<label for="dscritic">Cr�tica:</label>
		<input type="text" id="dscritic" name="dscritic"  />
	</div>
		
</fieldset>