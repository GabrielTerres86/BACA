<?php
	/*!
	* FONTE        : form_tab_historicos.php
	* CRIAÇÃO      : Douglas Quisinski
	* DATA CRIAÇÃO : 14/03/2016
	* OBJETIVO     : Formulario de adicionar o  filedset com os dados dos históricos da Tela HISTOR
	* --------------
	* ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	* --------------
	*/ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>
<form id="frmTabHistoricos" name="frmTabHistoricos" class="formulario" style="display:none;">

	<fieldset id="fsetHistoricos" name="fsetHistoricos" style="padding:0px; margin:0px; padding-bottom:10px; padding-left:2px; padding-right:2px; display:none;">		

		<legend>Hist&oacute;ricos</legend>
		<div id="divHistoricos" name="divHistoricos"></div>
	
	</fieldset>
	
</form>
