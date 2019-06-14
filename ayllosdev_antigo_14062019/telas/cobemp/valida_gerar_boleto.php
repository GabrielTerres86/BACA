<?php
/* !
 * FONTE        : valida_gerar_boleto.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 05/10/2015
 * OBJETIVO     : Rotina para validação da conta para gerar novos boletos.
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
$nrctacob = (isset($_POST['nrctacob'])) ? $_POST['nrctacob'] : 0;
$nrcnvcob = (isset($_POST['nrcnvcob'])) ? $_POST['nrcnvcob'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G",false)) <> "") {
	exibeErro($msgError);		
}	

// Montar o xml de Requisicao
$xmlData = "<Root>";
$xmlData .= " <Dados>";
$xmlData .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xmlData .= "		<nrctacob>" . $nrctacob . "</nrctacob>";
$xmlData .= "		<nrcnvcob>" . $nrcnvcob . "</nrcnvcob>";
$xmlData .= "		<nrctremp>" . $nrctremp . "</nrctremp>";
$xmlData .= " </Dados>";
$xmlData .= "</Root>";

$xmlResultado = mensageria($xmlData, "TELA_COBEMP", "VERIFICA_GERAR_BOLETO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResultado);


if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;

    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }

    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);
    
} else {
	
   echo "hideMsgAguardo(); gerarBoleto();";

}

function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
	exit();
}	

?>
