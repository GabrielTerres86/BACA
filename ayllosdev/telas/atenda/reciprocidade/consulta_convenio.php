<?php
/*************************************************************************
	Fonte: consulta_convenio.php
	Autor: André Clemer						Ultima atualizacao: --/--/----
	Data : Julho/2018
	
	Objetivo: Consultar dados do convênio
	
	Alteracoes: 

*************************************************************************/

session_start();
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");
require_once("../../../class/xmlfile.php");
isPostMethod();

$nrconven = (isset($_POST["nrconven"])) ? $_POST["nrconven"] : '';

// Monta o xml de requisição		
$xml  		= "";
$xml 	   .= "<Root>";
$xml 	   .= " <Dados>";
$xml 	   .= "     <nrconven>".$nrconven."</nrconven>";
$xml 	   .= "     <cddepart>".$glbvars['cddepart']."</cddepart>";
$xml 	   .= "     <cddopcao>A</cddopcao>";
$xml 	   .= "     <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
$xml 	   .= " </Dados>";
$xml 	   .= "</Root>";

// Executa script para envio do XML	
$xmlResult = mensageria($xml, "TELA_CADCCO", "CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#nrconven\',\'#frmFiltro\').habilitaCampo().focus();',false);		
}

$result = $xmlObj->roottag->tags[0]->tags[0]->tags;

$dsorgarq =  getByTagName($result,'dsorgarq'); 
$insitceb =  getByTagName($result,'insitceb'); 
$flgativo = (getByTagName($result,'flgativo') == "yes") ? "ATIVO" : "INATIVO";
$nrcnvceb =  getByTagName($result,'nrcnvceb');
$dtcadast =  getByTagName($result,'dtcadast');
$cdoperad =  getByTagName($result,'cdoperad');		
$inarqcbr =  getByTagName($result,'inarqcbr');
$cddemail =  getByTagName($result,'cddemail');
$flgcruni =  (getByTagName($result,'flgcruni') == "yes") ? "SIM" : "NAO";
$flgcebhm =  (getByTagName($result,'flgcebhm') == "yes") ? "SIM" : "NAO";
$flgregis =  (getByTagName($result,'flgregis') == "yes") ? "SIM" : "NAO";
$flgregon =  (getByTagName($result,'flgregon') == "yes") ? "SIM" : "NAO";
$flgpgdiv =  (getByTagName($result,'flgpgdiv') == "yes") ? "SIM" : "NAO";
$flcooexp =  (getByTagName($result,'flcooexp') == "yes") ? "SIM" : "NAO";
$flceeexp =  (getByTagName($result,'flceeexp') == "yes") ? "SIM" : "NAO";
$cddbanco =  getByTagName($result,'cddbanco');
$flserasa =  (getByTagName($result,'flserasa') == "yes") ? "SIM" : "NAO";
$flsercco =  getByTagName($result,'flsercco');
$qtdfloat =  getByTagName($result,'qtdfloat');		
$flprotes =  (getByTagName($result,'flprotes') == "yes") ? "SIM" : "NAO";
$qtlimaxp =  getByTagName($result,'qtlimmip');
$qtlimmip =  getByTagName($result,'qtlimaxp');
$qtdecprz =  getByTagName($result,'qtdecprz');
$idrecipr =  getByTagName($result,'idrecipr');
$inenvcob =  getByTagName($result,'inenvcob');
$qtbolcob = getByTagName($result,"qtbolcob");
$flgapihm =  (getByTagName($result,'flgapihm') == "yes") ? "SIM" : "NAO";


echo json_encode(
    array(
        'nrconven' => $nrconven,
        'dsorgarq' => $dsorgarq,
        'insitceb' => $insitceb,
        'flgativo' => $flgativo,
        'nrcnvceb' => $nrcnvceb,
        'dtcadast' => $dtcadast,
        'cdoperad' => $cdoperad,
        'inarqcbr' => $inarqcbr,
        'cddemail' => $cddemail,
        'flgcruni' => $flgcruni,
        'flgcebhm' => $flgcebhm,
        'flgregis' => $flgregis,
        'flgregon' => $flgregon,
        'flgpgdiv' => $flgpgdiv,
        'flcooexp' => $flcooexp,
        'flceeexp' => $flceeexp,
        'cddbanco' => $cddbanco,
        'flserasa' => $flserasa,
        'flsercco' => $flsercco,
        'qtdfloat' => $qtdfloat,
        'flprotes' => $flprotes,
        'qtlimaxp' => $qtlimaxp,
        'qtlimmip' => $qtlimmip,
        'qtdecprz' => $qtdecprz,
        'idrecipr' => $idrecipr,
        'inenvcob' => $inenvcob,
        'qtbolcob' => $qtbolcob,
        'flgapihm' => $flgapihm
    )
);