<?php

/* !
 * FONTE        : habilita_sms.php
 * CRIAÇÃO      : Ricardo Linhares
 * DATA CRIAÇÃO : 22/02/2017
 * OBJETIVO     : Rotina para exibir a habilitação do serviço de SMS
 */
?>

<?php

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 1;
$idpacote = (isset($_POST['idpacote'])) ? $_POST['idpacote'] : 1;

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <idpacote>".$idpacote."</idpacote>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA", "VALIDAR_CONTRATO_SMS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    exibirErro('error', utf8_encode($msgErro), 'Alerta - Aimaro', "", false);

} else {

    $registro = $xmlObj->roottag->tags[0];
    
    // verifica se o cooperado possui senha
    $flpossnh = getByTagName($registro->tags,'flpossnh');

    // Possui senha
    if($flpossnh == 1) {
        echo 'hideMsgAguardo(); verificaSenhaInternet("habilitarServSMS();",'.$nrdconta.',1);';
        exit();
    } else {
         echo 'hideMsgAguardo(); habilitarServSMS();';
         exit();
    }
}

?>

