<?php
/*!
 * FONTE        : incluir_finalidade.php
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 11/02/2019
 * OBJETIVO     : Rotina para incluir finalidade da API
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
$idservico_api  = (!empty($_POST['idservico_api']))       ? $_POST['idservico_api']       : '';
$ls_finalidades = (!empty($_POST['ls_finalidades']))  ? $_POST['ls_finalidades']  : '';

if (($msgError = validaPermissao('TELA_CADAPI','','F')) <> '') {
	exibeErroNew($msgError);
}

$xml = new XmlMensageria();
$xml->add('idservico_api',$idservico_api);
$xml->add('ls_finalidades',utf8_decode($ls_finalidades));

$xmlResult = mensageria($xml, "TELA_CADAPI", "GRAVAR_FINALIDADES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
    exibeErroNew($msgErro);exit;
}

echo 'showError("inform","Finalidades gravadas com sucesso.","Notifica&ccedil;&atilde;o - Aimaro","hideMsgAguardo();popup.onClick_Voltar();form.onClick_Prosseguir();");';

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Aimaro","bloqueiaFundo($(\'#divRotina\')");');
}