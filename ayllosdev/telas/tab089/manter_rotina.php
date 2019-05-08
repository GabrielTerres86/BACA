<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Diego Simas/Guilherme Boettcher - AMcom
 * DATA CRIAÇÃO : 15/01/2018
 * OBJETIVO     : Rotina para controlar as operações da tela TAB089
 * --------------
 * ALTERAÇÕES   : 30/05/2018 - Inclusão de campo de taxa de juros remuneratório de prejuízo (pctaxpre)
 *                             PRJ 450 - Diego Simas (AMcom)
 *
 *                20/06/2018 - Inclusão do campo Prazo p/ transferência de valor da conta transitória para a CC	
 *							   PRJ 450 - Diego Simas (AMcom)
 *  
 * 10/07/2018 - PJ 438 - Agilidade nas Contratações de Crédito - Márcio (Mouts)
 * 
 *				  14/09/2018 - Adicionado campo do valor max de estorno para desconto de titulo (Cássia de Oliveira - GFT)
 *                30/10/2018 - PJ 438 - Adicionado 2 novos parametros (avtperda e vlperavt) - Mateus Z (Mouts)
 *                11/12/2018 - PRJ 470 - Adicionado 2 novos parametros (inpreapv e vlmincnt) - Mateus Z (Mouts)
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
$pctaxpre = isset($_POST['pctaxpre']) ? $_POST['pctaxpre'] : 0;
$qtdictcc = isset($_POST['qtdictcc']) ? $_POST['qtdictcc'] : 0;
$vltolemp = isset($_POST['vltolemp']) ? $_POST['vltolemp'] : 0;
$qtdpaimo = isset($_POST['qtdpaimo']) ? $_POST['qtdpaimo'] : 0;
$qtdpaaut = isset($_POST['qtdpaaut']) ? $_POST['qtdpaaut'] : 0;
$qtdpaava = isset($_POST['qtdpaava']) ? $_POST['qtdpaava'] : 0;
$qtdpaapl = isset($_POST['qtdpaapl']) ? $_POST['qtdpaapl'] : 0;
$qtdpasem = isset($_POST['qtdpasem']) ? $_POST['qtdpasem'] : 0;
$qtdpameq = isset($_POST['qtdpameq']) ? $_POST['qtdpameq'] : 0; //PJ 438 - Márcio (Mouts)
$qtdibaut = isset($_POST['qtdibaut']) ? $_POST['qtdibaut'] : 0;
$qtdibapl = isset($_POST['qtdibapl']) ? $_POST['qtdibapl'] : 0;
$qtdibsem = isset($_POST['qtdibsem']) ? $_POST['qtdibsem'] : 0;
$qtditava = isset($_POST['qtditava']) ? $_POST['qtditava'] : 0; //PJ 438 - Márcio (Mouts)
$qtditapl = isset($_POST['qtditapl']) ? $_POST['qtditapl'] : 0; //PJ 438 - Márcio (Mouts)
$qtditsem = isset($_POST['qtditsem']) ? $_POST['qtditsem'] : 0; //PJ 438 - Márcio (Mouts)
$avtperda = isset($_POST['avtperda']) ? $_POST['avtperda'] : 0; // PJ438 - Sprint 5 - Mateus Z (Mouts)
$vlperavt = isset($_POST['vlperavt']) ? $_POST['vlperavt'] : 0; // PJ438 - Sprint 5 - Mateus Z (Mouts)
$vlmaxdst = isset($_POST['vlmaxdst']) ? $_POST['vlmaxdst'] : 0;
$inpreapv = isset($_POST['inpreapv']) ? $_POST['inpreapv'] : ''; // PRJ 470
$vlmincnt = isset($_POST['vlmincnt']) ? $_POST['vlmincnt'] : 0;  // PRJ 470

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
	$xml .= "   <qtdpameq>".$qtdpameq."</qtdpameq>"; // PJ438 - Márcio (Mouts)
                 
	$xml .= "   <qtdibaut>".$qtdibaut."</qtdibaut>";
    $xml .= "   <qtdibapl>".$qtdibapl."</qtdibapl>";
    $xml .= "   <qtdibsem>".$qtdibsem."</qtdibsem>";

	$xml .= "   <qtditava>".$qtditava."</qtditava>"; // PJ438 - Márcio (Mouts)
	$xml .= "   <qtditapl>".$qtditapl."</qtditapl>"; // PJ438 - Márcio (Mouts)
	$xml .= "   <qtditsem>".$qtditsem."</qtditsem>"; // PJ438 - Márcio (Mouts)	
    $xml .= "   <pctaxpre>".str_replace(',','.', $pctaxpre)."</pctaxpre>";
    $xml .= "   <qtdictcc>".$qtdictcc."</qtdictcc>";
	$xml .= "   <avtperda>".$avtperda."</avtperda>"; // PJ438 - Sprint 5 - Mateus Z (Mouts)
    $xml .= "   <vlperavt>".str_replace(',','.', $vlperavt)."</vlperavt>"; // PJ438 - Sprint 5 - Mateus Z (Mouts)
    $xml .= "   <vlmaxdst>".str_replace(',','.', $vlmaxdst)."</vlmaxdst>";
    $xml .= "   <inpreapv>".$inpreapv."</inpreapv>"; // PRJ 470
    $xml .= "   <vlmincnt>".str_replace(',','.', $vlmincnt)."</vlmincnt>"; // PRJ 470

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

        //prj 438 - bug 14179 - bruno
        $aux_vlperavt = getByTagName($r->tags, 'vlperavt');
        $aux_vlperavt = str_replace(',','.',str_replace('.','',$aux_vlperavt));

        echo '$("#prtlmult", "#frmTab089").val("' . getByTagName($r->tags, 'prtlmult') . '");';
        echo '$("#prestorn", "#frmTab089").val("' . getByTagName($r->tags, 'prestorn') . '");';
        echo '$("#prpropos", "#frmTab089").val("' . getByTagName($r->tags, 'prpropos') . '");';
        echo '$("#vlempres", "#frmTab089").val("' . getByTagName($r->tags, 'vlempres') . '");';
        echo '$("#pzmaxepr", "#frmTab089").val("' . getByTagName($r->tags, 'pzmaxepr') . '");';
        echo '$("#vlmaxest", "#frmTab089").val("' . getByTagName($r->tags, 'vlmaxest') . '");';
		// NOVOS (2)
        echo '$("#pcaltpar", "#frmTab089").val("' . getByTagName($r->tags, 'pcaltpar') . '");';
        echo '$("#pctaxpre", "#frmTab089").val("' . getByTagName($r->tags, 'pctaxpre') . '");';
        echo '$("#qtdictcc", "#frmTab089").val("' . getByTagName($r->tags, 'qtdictcc') . '");';
        echo '$("#vltolemp", "#frmTab089").val("' . getByTagName($r->tags, 'vltolemp') . '");';
		// NOVOS (5)
		echo '$("#qtdpaimo", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpaimo') . '");';
        echo '$("#qtdpaaut", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpaaut') . '");';
        echo '$("#qtdpaava", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpaava') . '");';
        echo '$("#qtdpaapl", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpaapl') . '");';
        echo '$("#qtdpasem", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpasem') . '");';
		echo '$("#qtdpameq", "#frmTab089").val("' . getByTagName($r->tags, 'qtdpameq') . '");'; // PJ438 - Márcio (Mouts)
		// NOVOS (3)
        echo '$("#qtdibaut", "#frmTab089").val("' . getByTagName($r->tags, 'qtdibaut') . '");';
        echo '$("#qtdibapl", "#frmTab089").val("' . getByTagName($r->tags, 'qtdibapl') . '");';
        echo '$("#qtdibsem", "#frmTab089").val("' . getByTagName($r->tags, 'qtdibsem') . '");';
		
		echo '$("#qtditava", "#frmTab089").val("' . getByTagName($r->tags, 'qtditava') . '");'; // PJ438 - Márcio (Mouts)
		echo '$("#qtditapl", "#frmTab089").val("' . getByTagName($r->tags, 'qtditapl') . '");'; // PJ438 - Márcio (Mouts)
		echo '$("#qtditsem", "#frmTab089").val("' . getByTagName($r->tags, 'qtditsem') . '");'; // PJ438 - Márcio (Mouts)		
		echo '$("#avtperda", "#frmTab089").val("' . getByTagName($r->tags, 'avtperda') . '");'; // PJ438 - Sprint 5 - Mateus Z (Mouts)
	    //BUG 14179 - Prj 438 - bruno
        echo '$("#vlperavt", "#frmTab089").val("' .($aux_vlperavt > 0 ? getByTagName($r->tags, 'vlperavt') : '') . '");'; // PJ438 - Sprint 5 - Mateus Z (Mouts)
        echo '$("#vlmaxdst", "#frmTab089").val("' . getByTagName($r->tags, 'vlmaxdst') . '");';	
		echo '$("#inpreapv", "#frmTab089").val("' . getByTagName($r->tags, 'inpreapv') . '");'; // PRJ 470
        echo '$("#vlmincnt", "#frmTab089").val("' . getByTagName($r->tags, 'vlmincnt') . '");'; // PRJ 470

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
