<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Diego Simas/Guilherme Boettcher - AMcom
 * DATA CRIAÇÃO : 15/01/2018
 * OBJETIVO     : Rotina para controlar as operações da tela TAB089
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

$prtlmult = isset($_POST['prtlmult']) ? $_POST['prtlmult'] : 0;
$prestorn = isset($_POST['prestorn']) ? $_POST['prestorn'] : 0;
$prpropos = isset($_POST['prpropos']) ? $_POST['prpropos'] : '';
$vlempres = isset($_POST['vlempres']) ? $_POST['vlempres'] : 0;
$pzmaxepr = isset($_POST['pzmaxepr']) ? $_POST['pzmaxepr'] : 0;
$vlmaxest = isset($_POST['vlmaxest']) ? $_POST['vlmaxest'] : 0;
$pcaltpar = isset($_POST['pcaltpar']) ? $_POST['pcaltpar'] : 0;
$vltolemp = isset($_POST['vltolemp']) ? $_POST['vltolemp'] : 0;
$qtdpaimo = isset($_POST['qtdpaimo']) ? $_POST['qtdpaimo'] : 0;
$qtdpaaut = isset($_POST['qtdpaaut']) ? $_POST['qtdpaaut'] : 0;
$qtdpaava = isset($_POST['qtdpaava']) ? $_POST['qtdpaava'] : 0;
$qtdpaapl = isset($_POST['qtdpaapl']) ? $_POST['qtdpaapl'] : 0;
$qtdpasem = isset($_POST['qtdpasem']) ? $_POST['qtdpasem'] : 0;
$qtdibaut = isset($_POST['qtdibaut']) ? $_POST['qtdibaut'] : 0;
$qtdibapl = isset($_POST['qtdibapl']) ? $_POST['qtdibapl'] : 0;
$qtdibsem = isset($_POST['qtdibsem']) ? $_POST['qtdibsem'] : 0;

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

    $xmlResult = mensageria($xml, "TELA_TAB089", "TAB089_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
} else {
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <prtlmult>".$prtlmult."</prtlmult>";
    $xml .= "   <prestorn>".$prestorn."</prestorn>";
    $xml .= "   <prpropos>".$prpropos."</prpropos>";
    $xml .= "   <vlempres>".str_replace(',','.', $vlempres)."</vlempres>";
    $xml .= "   <pzmaxepr>".$pzmaxepr."</pzmaxepr>";
    $xml .= "   <vlmaxest>".str_replace(',','.', $vlmaxest)."</vlmaxest>";
                 
	$xml .= "   <pcaltpar>".str_replace(',','.', $pcaltpar)."</pcaltpar>";
    $xml .= "   <vltolemp>".str_replace(',','.', $vltolemp)."</vltolemp>";
                 
	$xml .= "   <qtdpaimo>".$qtdpaimo."</qtdpaimo>";
    $xml .= "   <qtdpaaut>".$qtdpaaut."</qtdpaaut>";
    $xml .= "   <qtdpaava>".$qtdpaava."</qtdpaava>";
    $xml .= "   <qtdpaapl>".$qtdpaapl."</qtdpaapl>";
    $xml .= "   <qtdpasem>".$qtdpasem."</qtdpasem>";
                 
	$xml .= "   <qtdibaut>".$qtdibaut."</qtdibaut>";
    $xml .= "   <qtdibapl>".$qtdibapl."</qtdibapl>";
    $xml .= "   <qtdibsem>".$qtdibsem."</qtdibsem>";

    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_TAB089", "TAB089_ALTERAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
        echo '$("#prtlmult", "#frmTab089").val("' . getByTagName($r->tags, 'prtlmult') . '");';
        echo '$("#prestorn", "#frmTab089").val("' . getByTagName($r->tags, 'prestorn') . '");';
        echo '$("#prpropos", "#frmTab089").val("' . getByTagName($r->tags, 'prpropos') . '");';
        echo '$("#vlempres", "#frmTab089").val("' . getByTagName($r->tags, 'vlempres') . '");';
        echo '$("#pzmaxepr", "#frmTab089").val("' . getByTagName($r->tags, 'pzmaxepr') . '");';
        echo '$("#vlmaxest", "#frmTab089").val("' . getByTagName($r->tags, 'vlmaxest') . '");';
		// NOVOS (2)
        echo '$("#pcaltpar", "#frmTab089").val("' . getByTagName($r->tags, 'pcaltpar') . '");';
        echo '$("#vltolemp", "#frmTab089").val("' . getByTagName($r->tags, 'vltolemp') . '");';
		// NOVOS (5)
		echo '$("#qtdpaimo", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpaimo') . '");';
        echo '$("#qtdpaaut", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpaaut') . '");';
        echo '$("#qtdpaava", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpaava') . '");';
        echo '$("#qtdpaapl", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpaapl') . '");';
        echo '$("#qtdpasem", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpasem') . '");';
		// NOVOS (3)
        echo '$("#qtdibaut", "#frmTab089").val("' . getByTagName($r->tags, 'qtdibaut') . '");';
        echo '$("#qtdibapl", "#frmTab089").val("' . getByTagName($r->tags, 'qtdibapl') . '");';
        echo '$("#qtdibsem", "#frmTab089").val("' . getByTagName($r->tags, 'qtdibsem') . '");';
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
