<?php

/* !
 * FONTE        : controla_operacao.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 27/08/2015
 * OBJETIVO     : Controla opercações da Tela COBEMP
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
isPostMethod();

$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$nrctacob = (isset($_POST['nrctacob'])) ? $_POST['nrctacob'] : 0;
$nrcnvcob = (isset($_POST['nrcnvcob'])) ? $_POST['nrcnvcob'] : 0;
$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : '';
$dsdemail = (isset($_POST['dsdemail'])) ? $_POST['dsdemail'] : '';

// 1 - Email ou 2 - SMS
$tpdenvio = (isset($_POST['tpdenvio'])) ? $_POST['tpdenvio'] : 0;

$indretor = (isset($_POST['indretor'])) ? $_POST['indretor'] : 0;
$textosms = (isset($_POST['textosms'])) ? $_POST['textosms'] : '';
$nrdddtfc = (isset($_POST['nrdddtfc'])) ? $_POST['nrdddtfc'] : '';
$nrtelefo = (isset($_POST['nrtelefo'])) ? $_POST['nrtelefo'] : '';
$nmpescto = (isset($_POST['nmpescto'])) ? $_POST['nmpescto'] : '';

$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';


if ( ($operacao == 'ENVIAR_SMS') || ( $operacao ==  'ENVIAR_EMAIL') ) {
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X",false)) <> "") {
		exibeErro($msgError);		
	}	

    // Montar o xml de Requisicao
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
    $xml .= "   <nrctacob>" . $nrctacob . "</nrctacob>";
    $xml .= "   <nrcnvcob>" . $nrcnvcob . "</nrcnvcob>";
    $xml .= "   <nrdocmto>" . $nrdocmto . "</nrdocmto>";
    $xml .= "   <nmcontat>" . $nmpescto . "</nmcontat>";
    $xml .= "   <tpdenvio>" . $tpdenvio . "</tpdenvio>";
    $xml .= "   <dsdemail>" . $dsdemail . "</dsdemail>";
    $xml .= "   <indretor>" . $indretor . "</indretor>";
    $xml .= "   <nrdddsms>" . $nrdddtfc . "</nrdddsms>";
    $xml .= "   <nrtelsms>" . $nrtelefo . "</nrtelsms>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // Chamada mensageria
    $xmlResult = mensageria($xml, "EMPR0007", "ENVIA_BOLETO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Tratamento de erro
    if (strtoupper($xmlObj->roottag->tags [0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

        exit();
    } else {
        echo 'showError("inform","Operacao Efetuada com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaRotina($(\'#divRotina\'));;");';
    }
}

if ( $operacao == 'BAIXA_BOLETO' ) {
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"B",false)) <> "") {
		exibeErroBaixa($msgError);		
	}	
    
    // Montar o xml de Requisicao
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
    $xml .= "   <nrctacob>" . $nrctacob . "</nrctacob>";
    $xml .= "   <nrcnvcob>" . $nrcnvcob . "</nrcnvcob>";
    $xml .= "   <nrdocmto>" . $nrdocmto . "</nrdocmto>";
    $xml .= "   <dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "EMPR0007", "EFETUA_BAIXA_BOLETO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Tratamento de erro
    if (strtoupper($xmlObj->roottag->tags [0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

        exit();
    } else {
        echo 'showError("inform","Operacao Efetuada com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));buscaContratos(1, 15);fechaRotina($(\'#divRotina\'));");';
    }
    
    
}


function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}	

function exibeErroBaixa($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
	exit();
}	
