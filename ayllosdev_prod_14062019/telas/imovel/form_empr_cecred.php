<?php
/*
 * FONTE        : form_empr_cecred.php
 * CRIA��O      : Renato Darosci (Supero)
 * DATA CRIA��O : 07/06/2016
 * OBJETIVO     : Formul�rio de associado para a tela IMOVEL
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

$nrctremp = 0;
?>

<fieldset>
    <legend> Empr�stimo </legend>	

	<label for="cdcooper">Cooperativa:</label>
	<select id="cdcooper" name="cdcooper"></select>

    <label for="nrdconta">Conta/DV:</label>
    <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
	<input type="hidden" id="contaaux" name="contaaux" value="<?php echo $nrdconta ?>"/>
    <a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
    <label for="nmprimtl">Titular:</label>
    <input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />

	<label for="nrctremp">Contrato:</label>
    <select id="nrctremp" name="nrctremp"> </select>

</fieldset>		
