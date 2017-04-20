<?php
/*
 * FONTE        : csv.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : Novembro/2016
 * OBJETIVO     : Efetua carga de inconsistencias em arquivo CSV
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_cache_limiter("private");

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao1'])) ? $_POST['cddopcao1'] : '';
$cdcooper = (isset($_POST['cdcooper1'])) ? $_POST['cdcooper1'] : '';
$iddgrupo = (isset($_POST['iddgrupo1'])) ? $_POST['iddgrupo1'] : '';
$dtrefini = (isset($_POST['dtrefini1'])) ? $_POST['dtrefini1'] : '';
$dtreffim = (isset($_POST['dtreffim1'])) ? $_POST['dtreffim1'] : '';
$dsincons = (isset($_POST['dsincons1'])) ? $_POST['dsincons1'] : '';
$dsregist = (isset($_POST['dsregist1'])) ? $_POST['dsregist1'] : '';

$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <tpdsaida>CSV</tpdsaida>";
$xml .= "   <nriniseq>0</nriniseq>";
$xml .= "   <nrregist>0</nrregist>";
$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
$xml .= "   <iddgrupo>".$iddgrupo."</iddgrupo>";
$xml .= "   <dtrefini>".$dtrefini."</dtrefini>";
$xml .= "   <dtreffim>".$dtreffim."</dtreffim>";
$xml .= "   <dsincons>".$dsincons."</dsincons>";
$xml .= "   <dsregist>".$dsregist."</dsregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_CONINC", "CONINC_BUSCA_INCONSIST", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
    $msgErro = $xmlObject->roottag->tags[0]->cdata;
    if ($msgErro == '') {
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
} else {
    //Obtem nome do arquivo
    $nmarquiv = $xmlObject->roottag->cdata;
    //Chama funcao para mostrar arquivo gerado
    visualizaCSV($nmarquiv);
}
?>