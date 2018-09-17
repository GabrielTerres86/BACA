<?php

/*
 * FONTE        : carrega_arquivos.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 11/09/2015
 * OBJETIVO     : Efetua busca de arquivos
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>
<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Inicializa variaveis
$procedure = '';
$retornoAposErro = '';

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$dtinicio = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '';
$dtafinal = (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : '';


$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <dtinicio>" . $dtinicio . "</dtinicio>";
$xml .= "   <dtfinal>" . $dtafinal . "</dtfinal>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONLDB", "LISTA_ARQUIVOS_DOMICILIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

    exit();
} else {
    $registros = $xmlObj->roottag->tags[0]->tags;
    $qtregist = $xmlObj->roottag->tags[1]->cdata;
    $totalpro = $xmlObj->roottag->tags[2]->cdata;
    $totalpen = $xmlObj->roottag->tags[3]->cdata;
    $totalerr = $xmlObj->roottag->tags[4]->cdata;
}

include('tab_arquivos.php');

 