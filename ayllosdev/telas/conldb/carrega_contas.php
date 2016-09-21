<?php

/*
 * FONTE        : carrega_contas.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 11/09/2015
 * OBJETIVO     : Efetua busca de contas
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>
<?php

session_cache_limiter("private");
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

$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
$cddregio = (isset($_POST['cddregio'])) ? $_POST['cddregio'] : '';
$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : '';
$dtlanini = (isset($_POST['dtlanini'])) ? $_POST['dtlanini'] : '';
$dtlanfim = (isset($_POST['dtlanfim'])) ? $_POST['dtlanfim'] : '';
$dtarqini = (isset($_POST['dtarqini'])) ? $_POST['dtarqini'] : '';
$dtarqfim = (isset($_POST['dtarqfim'])) ? $_POST['dtarqfim'] : '';
$cdlancto = (isset($_POST['cdlancto'])) ? $_POST['cdlancto'] : '';
$cddoprod = (isset($_POST['cddoprod'])) ? $_POST['cddoprod'] : '';
$cdsituac = (isset($_POST['cdsituac'])) ? $_POST['cdsituac'] : '';
$nmarquiv = (isset($_POST['nmarquiv'])) ? $_POST['nmarquiv'] : '';
$insaida = (isset($_POST['insaida'])) ? $_POST['insaida'] : '1';
// 1 - Consultar 2 - Exportar

$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
$xml .= "   <cddregio>" . $cddregio . "</cddregio>";
$xml .= "   <cdagenci>" . $cdagenci . "</cdagenci>";
$xml .= "   <dtinicio>" . $dtlanini . "</dtinicio>";
$xml .= "   <dtfinal>" . $dtlanfim . "</dtfinal>";
$xml .= "   <dtiniarq>" . $dtarqini . "</dtiniarq>";
$xml .= "   <dtfimarq>" . $dtarqfim . "</dtfimarq>";
$xml .= "   <insituac>" . $cdsituac . "</insituac>";
$xml .= "   <tplancto>" . $cdlancto . "</tplancto>";
$xml .= "   <tpprodut>" . $cddoprod . "</tpprodut>";
$xml .= "   <nmarquiv>" . $nmarquiv . "</nmarquiv>";
$xml .= "   <insaida>" . $insaida . "</insaida>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONLDB", "LISTA_CONTAS_DOMICILIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
    $vltotal = $xmlObj->roottag->tags[2]->cdata;

}

if ($insaida == '1') {
    include('tab_contas.php');
} else {
    
    //Obtém nome do arquivo
    $nmarqpdf = $xmlObj->roottag->cdata;
    
    //Chama função para mostrar arquivo gerado
    visualizaPDF($nmarqpdf);
}

