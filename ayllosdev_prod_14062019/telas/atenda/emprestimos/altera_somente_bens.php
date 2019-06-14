<?
/*!
 * FONTE        : altera_somente_bens.php
 * CRIAÇÃO      : Christian Grauppe (Envolti)
 * DATA CRIAÇÃO : 10/10/2018
 * OBJETIVO     : Verificas conta e traz dados do associados.
 *
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

// Guardo os parâmetos do POST em variáveis
$arrAlienacoes = json_decode($_POST['arrayAlienacoes'], true);
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '0';
$nrctrato = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
$dsdalien = (isset($_POST['dsdalien'])) ? $_POST['dsdalien'] : '';
$dsinterv = (isset($_POST['dsinterv'])) ? $_POST['dsinterv'] : '';

$cddopcao = 'A';
$tpctrato = '90';

// Montar o xml de Requisicao
$xmlCarregaDados  = "";
$xmlCarregaDados .= "<Root>";
$xmlCarregaDados .= "	<Dados>";
$xmlCarregaDados .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xmlCarregaDados .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xmlCarregaDados .= "		<tpctrato>" . $tpctrato . "</tpctrato>";
$xmlCarregaDados .= "		<nrctrato>" . $nrctrato . "</nrctrato>";
$xmlCarregaDados .= "		<cddopcao>" . $cddopcao . "</cddopcao>";
$xmlCarregaDados .= "		<dsdalien>" . $dsdalien . "</dsdalien>";
$xmlCarregaDados .= "		<dsinterv>" . $dsinterv . "</dsinterv>";
$xmlCarregaDados .= "	</Dados>";
$xmlCarregaDados .= "</Root>";

$xmlResult = mensageria($xmlCarregaDados,"TELA_MANBEM","GRAVA_ALIENACAO_HIPOTEC",$glbvars["cdcooper"],$glbvars["cdagenci"],$glbvars["nrdcaixa"],$glbvars["idorigem"],$glbvars["cdoperad"],"</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
     $msgErro = $xmlObject->roottag->tags[0]->cdata;
     if ($msgErro == '') {
         $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
     }
     exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
} else {
	$msgAviso = "Bens atualizados com sucesso!";
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "AVISO") {
		$msgAviso  .= "<br/><br/>" . $xmlObject->roottag->tags[0]->cdata;
	}
	$metodo = "controlaOperacao();";

	exibirErro('inform',$msgAviso,'Alerta - Ayllos',$metodo,false);
}
