<?php

/*
 * FONTE        : calculo_cet.php
 * CRIAÇÃO      : Lucas Ranghetti.
 * DATA CRIAÇÃO : 31/07/2014
 * OBJETIVO     : Efetuar o calculo do cet
 * --------------
 * ALTERAÇÕES   : 12/11/2015 - Implementacao do parametro cdfinemp na chamada da
 *                             procedure calcula_cet_novo. (Projeto Portabilidade -
 *                             Carlos Rafael Tanholi)
 *				   03/2019 - Projeto 437 - AMcom JDB Calculo do CET com consignado
 * --------------
 * 
 */
session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

$dtdpagto = $_POST['dtdpagto'];
$dtlibera = $_POST['dtlibera'];
$vlemprst = $_POST['vlemprst'];
$vlpreemp = $_POST['vlpreemp'];
$qtpreemp = $_POST['qtpreemp'];
$inpessoa = $_POST['inpessoa'];
$cdlcremp = $_POST['cdlcremp'];
$tpemprst = $_POST['tpemprst'];
$nrctremp = $_POST['nrctremp'];
$nrdconta = $_POST['nrdconta'];
$cdfinemp = $_POST['cdfinemp'];
$dsctrliq = isset($_POST['dsctrliq']) ? $_POST['dsctrliq'] : '';
$idfiniof = isset($_POST['idfiniof']) ? $_POST['idfiniof'] : '0';
$dtcarenc = isset($_POST['dtcarenc']) ? $_POST['dtcarenc'] : '';
//P437
$vliofepr = '-1';
$gConsig = isset($_POST['gConsig']) ? $_POST['gConsig'] : '0';
if ($gConsig == '1'){
	$vliofepr = isset($_POST['vliofepr']) ? $_POST['vliofepr'] : '';
}

$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';

// valida se eh uma portabilidade
$portabilidade = $_POST['portabilidade'];

$xml = "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0002.p</Bo>";
$xml .= "		<Proc>calcula_cet_novo</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "       <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
$xml .= "		<cdagenci>" . $glbvars["cdpactra"] . "</cdagenci>";
$xml .= "		<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>";
$xml .= "		<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
$xml .= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
$xml .= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
$xml .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xml .= "		<inpessoa>" . $inpessoa . "</inpessoa>";
$xml .= "		<cdlcremp>" . $cdlcremp . "</cdlcremp>";
$xml .= "		<tpemprst>" . $tpemprst . "</tpemprst>";
$xml .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "		<vlemprst>" . $vlemprst . "</vlemprst>";
$xml .= "		<vlpreemp>" . $vlpreemp . "</vlpreemp>";
$xml .= "		<dtdpagto>" . $dtdpagto . "</dtdpagto>";
$xml .= "		<cdfinemp>" . $cdfinemp . "</cdfinemp>";
$xml .= "		<dtlibera>" . $dtlibera . "</dtlibera>";
$xml .= "		<vlemprst>" . $vlemprst . "</vlemprst>";
$xml .= "		<vlpreemp>" . $vlpreemp . "</vlpreemp>";
$xml .= "		<qtpreemp>" . $qtpreemp . "</qtpreemp>";
$xml .= "		<dsctrliq>" . $dsctrliq . "</dsctrliq>";
$xml .= "		<idfiniof>" . $idfiniof . "</idfiniof>";
$xml .= "		<dtcarenc>" . $dtcarenc . "</dtcarenc>";
//P437
$xml .= "		<vlrdoiof>" . $vliofepr . "</vlrdoiof>";
$xml .= "	</Dados>";
$xml .= "</Root>";

$xmlResult = getDataXML($xml);

$xmlObjeto = getObjectXML($xmlResult);

$txcetano = $xmlObjeto->roottag->tags[0]->attributes['TXCETANO'];

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    $mtdErro = "bloqueiaFundo(divRotina);controlaOperacao('" . $operacao . "');";
    exibirErro('error', $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata, 'Alerta - Aimaro: Calculo do CET', $mtdErro, false);
}
echo "arrayProposta['percetop'] = '" . $txcetano . "';";
echo "$('#percetop','#frmNovaProp').val('" . $txcetano . "');";
?>	