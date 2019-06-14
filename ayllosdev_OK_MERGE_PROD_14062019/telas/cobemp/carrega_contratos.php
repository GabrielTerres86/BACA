<?php

/* 
 * FONTE        : carrega_contratos.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 18/08/2015
 * OBJETIVO     : Efetua busca contratos
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>
<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Inicializa variaveis
$procedure = '';
$retornoAposErro = '';

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;

$dtbaixai = (isset($_POST['dtbaixai'])) ? $_POST['dtbaixai'] : '';
$dtbaixaf = (isset($_POST['dtbaixaf'])) ? $_POST['dtbaixaf'] : '';
$dtemissi = (isset($_POST['dtemissi'])) ? $_POST['dtemissi'] : '';
$dtemissf = (isset($_POST['dtemissf'])) ? $_POST['dtemissf'] : '';
$dtvencti = (isset($_POST['dtvencti'])) ? $_POST['dtvencti'] : '';
$dtvenctf = (isset($_POST['dtvenctf'])) ? $_POST['dtvenctf'] : '';
$dtpagtoi = (isset($_POST['dtpagtoi'])) ? $_POST['dtpagtoi'] : '';
$dtpagtof = (isset($_POST['dtpagtof'])) ? $_POST['dtpagtof'] : '';

$idseqttl = $_POST['idseqttl'] == '' ? 1 : $_POST['idseqttl'];

echo $glbvars["nmrotina"];

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'C',false)) <> "") {
	exibeErro($msgError);		
}	

if ($cddopcao == 'M') { // Manutencao

    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdagenci>" . $cdagenci . "</cdagenci>";
    $xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
    $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "   <dtbaixai>" . $dtbaixai . "</dtbaixai>";
    $xml .= "   <dtbaixaf>" . $dtbaixaf . "</dtbaixaf>";
    $xml .= "   <dtemissi>" . $dtemissi . "</dtemissi>";
    $xml .= "   <dtemissf>" . $dtemissf . "</dtemissf>";
    $xml .= "   <dtvencti>" . $dtvencti . "</dtvencti>";
    $xml .= "   <dtvenctf>" . $dtvenctf . "</dtvenctf>";
    $xml .= "   <dtpagtoi>" . $dtpagtoi . "</dtpagtoi>";
    $xml .= "   <dtpagtof>" . $dtpagtof . "</dtpagtof>";
    $xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
    $xml .= "   <nrregist>" . $nrregist . "</nrregist>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // Chamada mensageria
    $xmlResult = mensageria($xml, "TELA_COBEMP", "BUSCA_BOL_CONT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Tratamento de erro
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

        exit();
    } else {
        $registros = $xmlObj->roottag->tags[0]->tags;
        $qtregist = $xmlObj->roottag->tags[1]->cdata;
    }
} else {

    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
    $xml .= "   <nrregist>" . $nrregist . "</nrregist>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_COBEMP", "BUSCA_CONTRATOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

        exit();
    } else {
        $registros = $xmlObj->roottag->tags[0]->tags;
        $qtregist = $xmlObj->roottag->tags[1]->cdata;
    }
}

// Verifica qual tabela sera carregada
if ($cddopcao == 'C') {
    include('tab_contratos.php');
} else {
    include('tab_contratos_manutencao.php');
}


function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
	exit();
}	