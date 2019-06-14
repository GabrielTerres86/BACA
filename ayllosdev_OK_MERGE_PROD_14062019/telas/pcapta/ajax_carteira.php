<?php

/* !
 * FONTE        : ajax_carteira.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 14/07/2014
 * OBJETIVO     : Ajax de consulta para tela PCAPTA - carteira de captacao
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

setVarSession('nmrotina','CARTEIRA');

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'', false)) <> '') {		
    exibirErro('error',$msgError,'Alerta - Ayllos','fnVoltar();',false);
}

$retorno = array();

// Verifica se os parametros necessarios foram informados
if (!isset($_POST["dtmvtolt"])) {
    exibirErro('error', 'Par&acirc;metros incorretos.', 'Alerta - Ayllos', "btnVoltar();", true);
} else {
    $dtmvtolt = (isset($_POST["dtmvtolt"])) ? $_POST["dtmvtolt"] : 0;
    $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
    $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 20;

    if (!validaInteiro($cdcooper)) {
        exibirErro('error', 'Cooperativa inv&aacute;lida.', 'Alerta - Ayllos', "btnVoltar();", true);
    }
}

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
$xml .= "   <dtmvtolt>" . $dtmvtolt . "</dtmvtolt>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PCAPTA", "CONCAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
} else {
    $registros = $xmlObj->roottag->tags[0]->tags;
    $qtdregist = $xmlObj->roottag->tags[1]->cdata;

    include('tab_carteira.php');
}
?>