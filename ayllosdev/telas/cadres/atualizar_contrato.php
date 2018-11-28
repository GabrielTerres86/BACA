<?php
/*!
 * FONTE        : atualizar_contrato.php
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 19/07/2018
 * OBJETIVO     : Rotina para controlar aprovação/rejeição dos contratos
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
$cddopcao    = (!empty($_POST['cddopcao']))  ? $_POST['cddopcao']  : '';
$cdcooper    = (!empty($_POST['cdcooper']))  ? $_POST['cdcooper']  : $glbvars['cdcooper'];
$cdalcada    = (!empty($_POST['cdalcada']))  ? $_POST['cdalcada']  : '';
$idrecipr    = (!empty($_POST['idrecipr']))  ? $_POST['idrecipr']  : '';
$justific    = (!empty($_POST['justific']))  ? $_POST['justific']  : '';
$fnconfirm   = (!empty($_POST['fnconfirm'])) ? $_POST['fnconfirm'] : 'hideMsgAguardo();fechaRotina($(\\"#telaAprovacao\\"));estadoInicial();';
$fnreject    = (!empty($_POST['fnreject']))  ? $_POST['fnreject']  : 'hideMsgAguardo();fechaRotina($(\\"#telaRejeicao\\"));estadoInicial();';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
	exibeErroNew($msgError);
}

if ( $cddopcao == 'A' ) {

    $xml = new XmlMensageria();
    $xml->add('cdcooper',$cdcooper);
    $xml->add('cdalcada_aprovacao',$cdalcada);
    $xml->add('idcalculo_reciproci',$idrecipr);
    $xml->add('idstatus','A');
    $xml->add('dsjustificativa','.');

    $xmlResult = mensageria($xml, "TELA_CADRES", "APROVA_CONTRATO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
        exibeErroNew($msgErro);exit;
    }

    echo 'showError("inform","O contrato foi aprovado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","'.$fnconfirm.'");';

} else if ( $cddopcao == 'R' ) {

    $xml = new XmlMensageria();
    $xml->add('cdcooper',$cdcooper);
    $xml->add('cdalcada_aprovacao',$cdalcada);
    $xml->add('idcalculo_reciproci',$idrecipr);
    $xml->add('idstatus','R');
    $xml->add('dsjustificativa',$justific);

    $xmlResult = mensageria($xml, "TELA_CADRES", "APROVA_CONTRATO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
        exibeErroNew($msgErro);exit;
    }

    echo 'showError("inform","O contrato foi rejeitado.","Notifica&ccedil;&atilde;o - Ayllos","'.$fnreject.'");';

}

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");');
}