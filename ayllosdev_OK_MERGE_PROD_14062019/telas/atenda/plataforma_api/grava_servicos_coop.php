<?php
/*!
 * FONTE        : grava_servicos_coop.php
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 22/02/2019
 * OBJETIVO     : Rotina para gravar os serviços
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

// Recebe a operação que está sendo realizada
$cddopcao           = (!empty($_POST['cddopcao']))           ? $_POST['cddopcao']                 : '';
$nrdconta           = (!empty($_POST['nrdconta']))           ? $_POST['nrdconta']                 : '';
$idservico_api      = (!empty($_POST['idservico_api']))      ? $_POST['idservico_api']            : '';
$tp_autorizacao     = (!empty($_POST['tp_autorizacao']))     ? $_POST['tp_autorizacao']           : '';
$idsituacao_adesao  = (isset($_POST['idsituacao_adesao']))   ? (int) $_POST['idsituacao_adesao']  : '';
$ls_finalidades     = (!empty($_POST['ls_finalidades']))     ? $_POST['ls_finalidades']           : '';
$ls_desenvolvedores = (!empty($_POST['ls_desenvolvedores'])) ? $_POST['ls_desenvolvedores']       : '';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
	exibeErroNew($msgError);
}

$xml = new XmlMensageria();

$xml->add('nrdconta',$nrdconta);
$xml->add('idservico_api',$idservico_api);
$xml->add('dtadesao',$glbvars["dtmvtolt"]);
$xml->add('idsituacao_adesao',$idsituacao_adesao);
$xml->add('tp_autorizacao',$tp_autorizacao);
$xml->add('ls_finalidades',$ls_finalidades);
$xml->add('ls_desenvolvedores',$ls_desenvolvedores);
$xml->add('cddopcao',$cddopcao);

$xmlResult = mensageria($xml, "TELA_ATENDA_API", "GRAVA_SERVICOS_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
    exibeErroNew($msgErro);exit;
}

if ($tp_autorizacao == 2){
	echo 'showError("inform","Registro gravado com sucesso - Imprima o termo de ades&atilde;o.","Notifica&ccedil;&atilde;o - Aimaro","fechaRotina($(\'#divUsoGenerico\'));exibeRotina($(\'#divRotina\'));controlaOperacao(\'P\');");';
}else{
	echo 'showError("inform","Registro gravado com sucesso.","Notifica&ccedil;&atilde;o - Aimaro","fechaRotina($(\'#divUsoGenerico\'));exibeRotina($(\'#divRotina\'));controlaOperacao(\'P\');");';
}

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Aimaro","bloqueiaFundo($(\'#divUsoGenerico\'))");');
}