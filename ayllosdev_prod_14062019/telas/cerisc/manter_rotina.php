<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Douglas Pagel - AMcom
 * DATA CRIAÇÃO : 06/11/2018
 * OBJETIVO     : Rotina para controlar as operações da tela CERISC
 * --------------
 * ALTERAÇÕES   :
 * 
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

$prperliq = isset($_POST['prperliq']) ? $_POST['prperliq'] : 0;
$prpercob = isset($_POST['prpercob']) ? $_POST['prpercob'] : 0;
$prnivelr = isset($_POST['prnivelr']) ? $_POST['prnivelr'] : 0;


$cdopcao = $cddopcao == 'AC' ? $cdopcao = 'C' : $cdopcao = $cddopcao;

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cdopcao)) <> '') {
    exibeErroNew($msgError);
}

if ($cdopcao == 'C') {
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_CERISC", "CERISC_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
} else {
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <perceliq>".str_replace(',','.', $prperliq)."</perceliq>";
	$xml .= "   <percecob>".str_replace(',','.', $prpercob)."</percecob>";
    $xml .= "   <nivelris>".$prnivelr."</nivelris>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_CERISC", "CERISC_ALTERAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
}

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;

    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    $nmdcampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
    exibeErroNew($msgErro,$nmdcampo);

    exit();
}

$registros = $xmlObj->roottag->tags[0]->tags;

if ($cdopcao == 'C') {
    foreach ($registros as $r) {
        echo '$("#percliq", "#frmCERISC").val("' . getByTagName($r->tags, 'perceliq') . '");';
        echo '$("#perccob", "#frmCERISC").val("' . getByTagName($r->tags, 'percecob') . '");';
        echo '$("#nivel", "#frmCERISC").val("' . getByTagName($r->tags, 'nivelris') . '");';
        
    }
}

if ($cddopcao == "A") {
    echo 'showError("inform","Parâmetros alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
}

function exibeErroNew($msgErro, $nmdcampo) {
    echo 'hideMsgAguardo();';

    if ($nmdcampo <> ""){
        $nmdcampo = '$(\'#'.$nmdcampo.'\', \'#frmTab089\').focus();';
    }

    $msgErro = str_replace('"', '', $msgErro);
    $msgErro = preg_replace('/\s/',' ',$msgErro);

    echo 'showError("error","' .$msgErro. '","Alerta - Ayllos","liberaCampos(); '.$nmdcampo.'");';

    exit();
}
