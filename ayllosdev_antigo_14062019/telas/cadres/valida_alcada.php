<?php
/*!
 * FONTE        : valida_alcada.php
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 23/08/2018
 * OBJETIVO     : Rotina para validar se existe alçada para cooperativa atual
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Recebe a operação que está sendo realizada
$cdcooper = (!empty($_POST['cdcooper'])) ? $_POST['cdcooper'] : $glbvars['cdcooper'];

$xml = new XmlMensageria();
$xml->add('cdcooprt',$cdcooper);

$xmlResult = mensageria($xml, "TELA_CADRES", "VALIDA_ALCADA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" || true) {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro)
        exit('showError("error","' . $msgErro . '","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");');
}
