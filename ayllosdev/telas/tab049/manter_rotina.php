<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Márcio(Mouts)
 * DATA CRIAÇÃO : 08/2018
 * OBJETIVO     : Rotina para controlar as operações da tela TAB049
 * --------------
 * ALTERAÇÕES
  */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$valormin = isset($_POST['valormin']) ? $_POST['valormin'] : 0;
$valormax = isset($_POST['valormax']) ? $_POST['valormax'] : 0;
$datadvig = isset($_POST['datadvig']) ? $_POST['datadvig'] : 0;
$pgtosegu = isset($_POST['pgtosegu']) ? $_POST['pgtosegu'] : 0;
$vallidps = isset($_POST['vallidps']) ? $_POST['vallidps'] : 0;
$subestip = isset($_POST['subestip']) ? $_POST['subestip'] : 0;
$sglarqui = isset($_POST['sglarqui']) ? $_POST['sglarqui'] : 0;
$nrsequen = isset($_POST['nrsequen']) ? $_POST['nrsequen'] : 0;

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

    $xmlResult = mensageria($xml, "TELA_TAB049", "TAB049_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
} else {
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <valormin>".str_replace(',','.', $valormin)."</valormin>";
    $xml .= "   <valormax>".str_replace(',','.', $valormax)."</valormax>";	
    $xml .= "   <datadvig>".$datadvig."</datadvig>";
    $xml .= "   <pgtosegu>".str_replace(',','.', $pgtosegu)."</pgtosegu>";
                 
	$xml .= "   <subestip>".$subestip."</subestip>";
    $xml .= "   <sglarqui>".$sglarqui."</sglarqui>";
	$xml .= "   <nrsequen>".$nrsequen."</nrsequen>"; 
    $xml .= "   <vallidps>".str_replace(',','.', $vallidps)."</vallidps>";	
	
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_TAB049", "TAB049_ALTERAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
        echo '$("#valormin", "#frmTab049").val("' . getByTagName($r->tags, 'valormin') . '");';
        echo '$("#valormax", "#frmTab049").val("' . getByTagName($r->tags, 'valormax') . '");';
   	    echo '$("#datadvig", "#frmTab049").val("' . getByTagName($r->tags, 'datadvig') . '");';	
   	    echo '$("#pgtosegu", "#frmTab049").val("' . getByTagName($r->tags, 'pgtosegu') . '");';			
   	    echo '$("#vallidps", "#frmTab049").val("' . getByTagName($r->tags, 'vallidps') . '");';	
   	    echo '$("#subestip", "#frmTab049").val("' . getByTagName($r->tags, 'subestip') . '");';	
  	    echo '$("#sglarqui", "#frmTab049").val("' . getByTagName($r->tags, 'sglarqui') . '");';	
   	    echo '$("#nrsequen", "#frmTab049").val("' . getByTagName($r->tags, 'nrsequen') . '");';
    }
}

if ($cddopcao == "A") {
    echo 'showError("inform","Parâmetros alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
}

function exibeErroNew($msgErro, $nmdcampo) {
    echo 'hideMsgAguardo();';

    if ($nmdcampo <> ""){
        $nmdcampo = '$(\'#'.$nmdcampo.'\', \'#frmTab049\').focus();';
    }

    $msgErro = str_replace('"', '', $msgErro);
    $msgErro = preg_replace('/\s/',' ',$msgErro);

    echo 'showError("error","' .$msgErro. '","Alerta - Ayllos","liberaCampos(); '.$nmdcampo.'");';

    exit();
}
