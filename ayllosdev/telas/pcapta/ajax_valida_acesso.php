<?php

/* !
 * FONTE        : ajax_valida_acesso.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 14/07/2014
 * OBJETIVO     : Ajax de validacao das opcoes das telas PCAPTA 
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

$cddopcao = (isset($_POST["cddopcao"])) ? trim($_POST["cddopcao"]) : '';
$stropcao = (isset($_POST["stropcao"])) ? trim($_POST["stropcao"]) : '';

if ($cddopcao == 'C') {
    setVarSession('nmrotina', 'CARTEIRA');
} else if ($cddopcao == 'D') {
    setVarSession('nmrotina', 'DEFINICAO');
} else if ($cddopcao == 'H') {
    setVarSession('nmrotina', 'HISTORICO');
} else if ($cddopcao == 'M') {
    setVarSession('nmrotina', 'MODALIDADE');
} else if ($cddopcao == 'N') {
    setVarSession('nmrotina', 'NOMENCLATURA');
} else if ($cddopcao == 'P') {
    setVarSession('nmrotina', 'PRODUTOS');
}

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], $stropcao);
$xmlResult = mensageria($xml, "PCAPTA", "VACESSO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    //$msgErro = $xmlObj->roottag->tags[0]->cdata;
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    echo $msgErro;
}
?>