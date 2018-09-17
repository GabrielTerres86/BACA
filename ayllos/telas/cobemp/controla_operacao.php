<?php

/* !
 * FONTE        : controla_operacao.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 27/08/2015
 * OBJETIVO     : Controla opercações da Tela COBEMP
 * --------------
 * ALTERAÇÕES   : 01/03/2017 - Funcionamento de justificativa de baixa e Importacao de arquivo. (P210.2 - Jaison/Daniel)
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
$dsjustif = (isset($_POST['dsjustif'])) ? $_POST['dsjustif'] : '';
$nmarquiv = (isset($_POST['nmarquiv'])) ? $_POST['nmarquiv'] : '';
$flgreimp = (isset($_POST['flgreimp'])) ? $_POST['flgreimp'] : 0;

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
    $xml .= "   <dsjustif><![CDATA[".utf8_decode($dsjustif)."]]></dsjustif>";
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
        exibirErro('error', $msgErro, 'Alerta - Ayllos', 'fechaRotina($(\'#divRotina\'));', false);

        exit();
    } else {
        echo 'showError("inform","Operacao Efetuada com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));buscaContratos(1, 15);fechaRotina($(\'#divRotina\'));");';
    }
}

if ( $operacao == 'IMPORTAR_ARQUIVO' ) {

	// Montar o xml de Requisicao
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nmarquiv>" . $nmarquiv . "</nmarquiv>";
    $xml .= "   <flgreimp>" . $flgreimp . "</flgreimp>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_COBEMP", "COBEMP_IMP_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    // Tratamento de erro
    if (strtoupper($xmlObject->roottag->tags [0]->name == 'ERRO')) {
        $msgErro = $xmlObject->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', utf8_encode($msgErro), 'Alerta - Ayllos', 'fechaRotina($(\'#divRotina\'));', false);
    } else {
        $flgreimp = (int) $xmlObject->roottag->tags[0]->cdata;
        if ($flgreimp) { // Solicitar confirmacao
            echo "$('#flgreimp', '#frmNomArquivo').val(1);";
            echo 'confirmaImportacao();';
        } else {
            echo "$('#flgreimp', '#frmNomArquivo').val(0);";
            echo 'showError("inform","Operacao Efetuada com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaArquivos(1, 15);fechaRotina($(\'#divRotina\'));");';
        }
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
