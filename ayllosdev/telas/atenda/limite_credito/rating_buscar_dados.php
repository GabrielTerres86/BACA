<?php
    /**
     * Autor: Bruno Luiz katzjarowski - Mout's
     * Data: 04/12/2018
     * Ultima alteração:
     * 
     * Alterações:
     */
    // error_reporting(E_ALL);
    // ini_set('display_errors', 1);

    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
    require_once("../../../includes/controla_secao.php");	
	require_once("../../../class/xmlfile.php");
    isPostMethod();	
    require_once("../../../includes/controla_secao.php");
    
    $nrdconta = $_POST['nrdconta'];

	$xmlGetRating  = "";
	$xmlGetRating .= "<Root>";
	$xmlGetRating .= "  <Cabecalho>";
	$xmlGetRating .= "    <Bo>b1wgen0043.p</Bo>";
	$xmlGetRating .= "    <Proc>busca_dados_rating</Proc>";
	$xmlGetRating .= "  </Cabecalho>";
	$xmlGetRating .= "  <Dados>";
	$xmlGetRating .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetRating .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetRating .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetRating .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetRating .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetRating .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetRating .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetRating .= "    <idseqttl>1</idseqttl>";
	$xmlGetRating .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetRating .= "  </Dados>";
    $xmlGetRating .= "</Root>";
    
    $nrinfcad = 0;
	$nrpatlvr =	0;
	$nrperger =	0;
	$vltotsfn =	0;
	$perfatcl =	0;
	$nrgarope =	0;
    $nrliquid =	0;

    // Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetRating,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRating = getObjectXML($xmlResult);
    
    $nrinfcad = $xmlObjRating->roottag->tags[0]->tags[0]->tags[0]->cdata;
    $nrpatlvr = $xmlObjRating->roottag->tags[0]->tags[0]->tags[1]->cdata;
    $nrperger = $xmlObjRating->roottag->tags[0]->tags[0]->tags[2]->cdata;
    $vltotsfn = number_format(str_replace(",",".",$xmlObjRating->roottag->tags[0]->tags[0]->tags[3]->cdata),2,",",".");
    $perfatcl = number_format(str_replace(",",".",$xmlObjRating->roottag->tags[0]->tags[0]->tags[4]->cdata),2,",",".");
    $nrgarope = $xmlObjRating->roottag->tags[0]->tags[0]->tags[5]->cdata;
    $nrliquid = $xmlObjRating->roottag->tags[0]->tags[0]->tags[6]->cdata;


    $retorno = Array(
        'rating' => Array(
            "nrinfcad" => $nrinfcad,
            "nrpatlvr" => $nrpatlvr,
            "nrperger" => $nrperger,
            "vltotsfn" => $vltotsfn,
            "perfatcl" => $perfatcl,
            "nrgarope" => $nrgarope,
            "nrliquid" => $nrliquid
        )
    );

    echo json_encode($retorno);
    exit();
?>
