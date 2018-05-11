<?php
/*
 * FONTE        : exporta_arquivos.php
 * CRIAÇÃO      : Marcos Lucas (Mout's)
 * DATA CRIAÇÃO : 09/01/2018
 * OBJETIVO     : Exporta arquivos filtrados para csv
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();

$dtinicio = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '';
$dtafinal = (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : '';
$tparquivo = (isset($_POST['tparquivo'])) ? $_POST['tparquivo'] : 0;
$bcoliquidante = (isset($_POST['bcoliquidante'])) ? $_POST['bcoliquidante'] : '';
$credenciadora = (isset($_POST['credenciadora'])) ? $_POST['credenciadora'] : '';

//montagem xml de params
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <dtinicio>" . $dtinicio . "</dtinicio>";
$xml .= "   <dtfinal>" . $dtafinal . "</dtfinal>";
$xml .= "   <tparquivo>" . $tparquivo . "</tparquivo>";
$xml .= "   <bcoliquidante>" . $bcoliquidante . "</bcoliquidante>";
$xml .= "   <credenciadora>" . $credenciadora . "</credenciadora>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONCIP", "EXPORTA_ARQUIVOS_DOMICILIO_SILOC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

    exit();
}
else {
    //Chama função para mostrar arquivo gerado
    visualizaCSV($xmlObj->roottag->cdata);
}