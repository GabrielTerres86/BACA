<?php
/* !
 * FONTE        : efetua_geracao_boleto.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 04/09/2015
 * OBJETIVO     : Rotina para geracao boleto
 * --------------
 * ALTERAÇÕES   : 02/03/2017 - Inclusao de CPF do avalista. (P210.2 - Jaison/Daniel)
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

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$tpparepr = (isset($_POST['tpparepr'])) ? $_POST['tpparepr'] : 0;
$dsparepr = (isset($_POST['dsparepr'])) ? $_POST['dsparepr'] : '';
$dtvencto = (isset($_POST['dtvencto'])) ? $_POST['dtvencto'] : '';
$vlparepr = (isset($_POST['vlparepr'])) ? $_POST['vlparepr'] : 0;
$tpemprst = (isset($_POST['tpemprst'])) ? $_POST['tpemprst'] : '';
$nrcpfava = (isset($_POST['nrcpfava'])) ? $_POST['nrcpfava'] : 0;
     
if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G",false)) <> "") {
	exibeErro($msgError);		
}	
	 
	 
// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
$xml .= "   <dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xml .= "   <tpparepr>" . $tpparepr . "</tpparepr>";
$xml .= "   <dsparepr>" . $dsparepr . "</dsparepr>";
$xml .= "   <dtvencto>" . $dtvencto . "</dtvencto>";
$xml .= "   <vlparepr>" . $vlparepr . "</vlparepr>";
$xml .= "   <nrcpfava>" . $nrcpfava . "</nrcpfava>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "EMPR0007", "GERA_BOLETO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));', false);

    exit();
} else {
    echo 'showError("inform","<center>Boleto Gerado com Sucesso.</center>","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaRotina($(\'#divRotina\'));chamaRotinaManutencao();");';	
}

function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}	

