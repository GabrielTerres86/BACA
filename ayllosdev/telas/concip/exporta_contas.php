<?php

/*
 * FONTE        : exporta_contas.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 11/09/2015
 * OBJETIVO     : Efetua busca de contas em arquivo csv
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
$cddopcao = (isset($_POST['cddopcao1'])) ? $_POST['cddopcao1'] : '';
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;

$cdcooper = (isset($_POST['cdcooper1'])) ? $_POST['cdcooper1'] : '';
$cddregio = (isset($_POST['cddregio1'])) ? $_POST['cddregio1'] : '';
$cdagenci = (isset($_POST['cdagenci1'])) ? $_POST['cdagenci1'] : '';
$dtlanini = (isset($_POST['dtlanini1'])) ? $_POST['dtlanini1'] : '';
$dtlanfim = (isset($_POST['dtlanfim1'])) ? $_POST['dtlanfim1'] : '';
$dtarqini = (isset($_POST['dtarqini1'])) ? $_POST['dtarqini1'] : '';
$dtarqfim = (isset($_POST['dtarqfim1'])) ? $_POST['dtarqfim1'] : '';
$cdlancto = (isset($_POST['cdlancto1'])) ? $_POST['cdlancto1'] : '';
$cdsituac = (isset($_POST['cdsituac1'])) ? $_POST['cdsituac1'] : '';
$nmarquiv = (isset($_POST['nmarquiv1'])) ? $_POST['nmarquiv1'] : '';
$insaida = (isset($_POST['insaida1'])) ? $_POST['insaida1'] : '2';
// 1 - Consultar 2 - Exportar

$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
$xml .= "   <cddregio>" . $cddregio . "</cddregio>";
$xml .= "   <cdagenci>" . $cdagenci . "</cdagenci>";
$xml .= "   <dtinicio>" . $dtlanini . "</dtinicio>";
$xml .= "   <dtfinal>"  . $dtlanfim . "</dtfinal>";
$xml .= "   <dtiniarq>" . $dtarqini . "</dtiniarq>";
$xml .= "   <dtfimarq>" . $dtarqfim . "</dtfimarq>";
$xml .= "   <insituac>" . $cdsituac . "</insituac>";
$xml .= "   <tplancto>" . $cdlancto . "</tplancto>";
$xml .= "   <nmarquiv>" . $nmarquiv . "</nmarquiv>";
$xml .= "   <insaida>"  . $insaida . "</insaida>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONCIP", "LISTA_CONTAS_DOMICILIO_SILOC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

    exit();
} else {

    //Obtém nome do arquivo
    $nmarqpdf = $xmlObj->roottag->cdata;

    //Chama função para mostrar arquivo gerado
    visualizaCSV($nmarqpdf);
}