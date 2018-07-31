<?php
/*
 * FONTE        : carrega_conciliacao.php
 * CRIAÇÃO      : Marcos Lucas (Mout's)
 * DATA CRIAÇÃO : 20/02/2018
 * OBJETIVO     : Consulta conciliacao liquidacao STR
 * --------------
 * ALTERAÇÕES   : 23/07/2018 - Adicionado campo Credenciadora no Filtro (PRJ 486 - Mateus Z / Mouts)
 * --------------
 */
//session_cache_limiter("private");
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$dtlcto = (isset($_POST['dtlcto'])) ? $_POST['dtlcto'] : '';
$credenciadorasstr = (isset($_POST['credenciadorasstr'])) ? $_POST['credenciadorasstr'] : '';

$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <dtlcto>".$dtlcto."</dtlcto>";
$xml .= "   <ispb>".$credenciadorasstr."</ispb>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONCIP", "BUSCA_CONCILIACAO_LIQUIDACAO_STR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
    $xmlRes = simplexml_load_string($xmlResult);
    $qdeCreditado = $xmlRes->item->qdecreditado;
    $vlCreditado = $xmlRes->item->vlcreditado;
    $qdePagamentos = $xmlRes->item->qdepagamentos;
    $vlPagamentos = $xmlRes->item->vlpagamentos;
}

include('tab_conciliacao.php');
