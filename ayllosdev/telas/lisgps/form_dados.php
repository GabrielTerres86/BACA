<?php
	/*!
	* FONTE        : form_dados.php
	* CRIA��O      : Andre Santos - SUPERO
	* DATA CRIA��O : Setembro/2015
	* OBJETIVO     : Mostrar tela LISGPS
	* --------------
	* ALTERA��ES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	* --------------
	*/

	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	isPostMethod();

	require_once("../../class/xmlfile.php");

	$indrowid    = (isset($_POST['indrowid'])) ? $_POST['indrowid'] : '' ;
	$regCdcontar = $_POST["regCdcontar"];
	$regDscontar = $_POST["regDscontar"];
	$regVltarid0 = $_POST["regVltarid0"];
	$regVltarid1 = $_POST["regVltarid1"];
	$regVltarid2 = $_POST["regVltarid2"];

?>
<form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:block">

	<fieldset style="width:600px;height:80px;margin: 20px auto;" align="center">
	<legend>Consulta GPS</legend>
	
	<div id="divConsulta" style="display:none">
		
		<br style="clear:both" />
		
		<label for="dtpagmto">Data Pagamento:</label>
		<input name="dtpagmto" id="dtpagmto" type="text" value="<? echo $glbvars['dtmvtolt'] ; ?>" autocomplete="off" />
		
		<label for="cdagenci">PA:</label>
		<input name="cdagenci" id="cdagenci" type="text" value="" />
		
		<label for="nrdcaixa">Caixa:</label>
		<input name="nrdcaixa" id="nrdcaixa" type="text" value="" />
		
		<br style="clear:both" />
		
		<div id="divVisualizar" style="display:block">
			<label for="cdidenti">Identificador:</label>
			<input name="cdidenti" id="cdidenti" type="text" value="" />
		</div>

	</div>
	
	</fieldset>

</form>