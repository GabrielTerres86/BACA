<?php
/* !
 * FONTE        : consulta_tarifas.php
 * CRIAÇÃO      : André Clemer (Supero)
 * DATA CRIAÇÃO : 29/10/2018
 * OBJETIVO     : Rotina para busca os dados das tarifas
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Busca os parâmetos do POST guardando em variáveis
$cddopcao   = (!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
$cddgrupo   = (!empty($_POST['cddgrupo'])) ? (int) $_POST['cddgrupo'] : null;
$cdtarifa   = (!empty($_POST['cdtarifa'])) ? (int) $_POST['cdtarifa'] : null;
$nrconven   = (!empty($_POST['nrconven'])) ? $_POST['nrconven'] : '';
$flgativo   = (!empty($_POST['flgativo'])) ? $_POST['flgativo'] : '';
$cdlcremp   = (!empty($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '';
$nrregist   = (!empty($_POST['nrregist'])) ? $_POST['nrregist'] : 50;
$nriniseq   = (!empty($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') { // passado cddopcao fixo enquanto houver apenas um tipo de opcao
	exibeErroNew($msgError);
}
$xml = new XmlMensageria();

$xml->add('cddgrupo',$cddgrupo);
$xml->add('cdtarifa',$cdtarifa);
$xml->add('nrconven',$nrconven);
$xml->add('flgativo',$flgativo);
$xml->add('cdlcremp',$cdlcremp);
// paginacao
$xml->add('nrregist',$nrregist);
$xml->add('nriniseq',$nriniseq);

$xmlResult = mensageria($xml, "TELA_CONTAR", "CONSULTA_TARIFAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
    exibeErroNew($msgErro);exit;
}

$qtregist = $xmlObj->roottag->attributes['QTREGIST'];

$registros = $xmlObj->roottag->tags;

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");');
}

include('grid_tarifas.php');