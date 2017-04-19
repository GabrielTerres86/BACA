<?php

/* !
 * FONTE        : consulta_menus.php
 * CRIAÇÃO      : Ricardo Linhares
 * DATA CRIAÇÃO : 17/03/2016
 * OBJETIVO     : Rotina para busca os dados dos contratos
 */
?>

<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$idpacote = (isset($_POST['idpacote'])) ? $_POST['idpacote'] : 0;
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
$flgstatus = (isset($_POST['flgstatus'])) ? $_POST['flgstatus'] : 0;
$perdesconto = $_POST['perdesconto'];
$qtdsms = $_POST['qtdsms'];

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <idpacote>".$idpacote."</idpacote>";
$xml .= "   <cooper>".$cdcooper."</cooper>";
$xml .= "   <flgstatus>".$flgstatus."</flgstatus>";
$xml .= "   <perdesconto>".converteFloat($perdesconto)."</perdesconto>";
$xml .= "   <qtdsms>".$qtdsms."</qtdsms>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADSMS", "ALTERAR_PACOTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
} else {
    $dsmensag = 'Pacote alterado com sucesso!';
    echo "showError('inform','".$dsmensag."','Pacotes SMSs','fechaRotina($(\'#divRotina\'));FormularioPacote.inicializar();');";
}

?>
