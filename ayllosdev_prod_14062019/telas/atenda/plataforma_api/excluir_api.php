<?php
/*!
 * FONTE        : excluir_api.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : 02/05/2019
 * OBJETIVO     : Rotina para excluir os serviços
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

// Recebe o rowid que está sendo passado
$rowid = (!empty($_POST['rowid'])) ? $_POST['rowid'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E',false)) <> '') {
	exibeErroNew($msgError);
}

$xml = new XmlMensageria();
$xml->add('dsrowid',$rowid);

$xmlResult = mensageria($xml, "TELA_ATENDA_API", "EXCLUI_SERVICO_API", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
    exibeErroNew($msgErro);exit;
}

echo 'showError("inform","API excluida com sucesso.","Notifica&ccedil;&atilde;o - Aimaro","fechaRotina($(\'#divUsoGenerico\'));exibeRotina($(\'#divRotina\'));controlaOperacao(\'LP\');");';

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Aimaro","fechaRotina($(\'#divUsoGenerico\'));exibeRotina($(\'#divRotina\'));");');
}