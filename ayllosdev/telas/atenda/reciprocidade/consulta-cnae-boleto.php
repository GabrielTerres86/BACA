<?php
/*************************************************************************
	Fonte: consulta-cnae-boleto.php
	Autor: Jaison Fernando						Ultima atualizacao: --/--/----
	Data : Dezembro/2015
	
	Objetivo: Consultar dados do CNAE ou Boleto em aberto.
	
	Alteracoes: 20/09/2017 - Alterar mensageria para ZOOM0001. PRJ339 - CRM(Odirlei-AMcom)

*************************************************************************/

session_start();
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");
require_once("../../../class/xmlfile.php");
isPostMethod();

$consulta = (isset($_POST["consulta"])) ? $_POST["consulta"] : '';
$cdcnae = (isset($_POST["cdclcnae"])) ? $_POST["cdclcnae"] : '';
$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : '';
$nrconven = (isset($_POST["nrconven"])) ? $_POST["nrconven"] : '';

if ($consulta == 1) { // CNAE
	$nmprogra = "ZOOM0001";
	$nmeacao = "BUSCA_CNAE";
} else { // Boleto em aberto
	$nmprogra = "SSPC0002";
	$nmeacao = "VERIFICA_BOLETO";
}

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <cdcnae>".$cdcnae."</cdcnae>";
$xml .= "   <dscnae/>";
$xml .= "   <flserasa>1</flserasa>"; // Ativo
$xml .= "   <nriniseq>1</nriniseq>";
$xml .= "   <nrregist>1</nrregist>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= " </Dados>";
$xml .= "</Root>";

// Requisicao dos dados
$xmlResult = mensageria($xml, $nmprogra, $nmeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if ($consulta == 1) { // CNAE
	echo (int) $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
} else { // Boleto em aberto
	echo (int) $xmlObj->roottag->tags[0]->attributes['POSSUI'];
}
?>