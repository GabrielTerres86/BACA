<?php
/*!
 * FONTE        : form_combo_motivos.php
 * CRIAÇÃO      : David Valente - Envolti
 * DATA CRIAÇÃO : Abril/2019
 * OBJETIVO     : Componente Combo com os tipos de bloqueio
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	

session_start();
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");
require_once("../../../includes/controla_secao.php");
require_once("../../../class/xmlfile.php");
isPostMethod();

// Parametro passado via AJAX com o tipo do motivo
// se é um motivo de 0 - bloqueio ou 1 - desbloqueio.
$flgtipo = $_POST['pr_flgtipo'];

$xml = "<Root>";
$xml .= "	<Dados>";
$xml .= '		<flgtipo>' . $flgtipo . '</flgtipo>'; 
$xml .= "	</Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_PREAPV", "COMBO_MOTIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
																     $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjetoCombo = getObjectXML($xmlResult);

 
// para os ultimos valores para se alterar

foreach($xmlObjetoCombo->roottag->tags[0]->tags as $key => $registro) 
{ 
	echo "<option value='{$registro->tags[0]->cdata}'>";	
	echo $registro->tags[1]->cdata; 
	echo "</option>";
} 
?>