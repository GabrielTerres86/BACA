<?php

/* !
 * FONTE        : consulta_menus.php
 * CRIAÇÃO      : Ricardo Linhares
 * DATA CRIAÇÃO : 22/02/2017
 * OBJETIVO     : Rotina para busca de valor de tarifa
 */
?>

<?php

class Error {
    var $erro;
    public function __construct($erro) {
        $this->erro = $erro;
    }
}

class TarifaPacoteSMS {

    var $vlsms;
    var $vlsmsad;
    var $vlpacote;
    var $erro;

    public function __construct($vlsms, $vlsmsad, $vlpacote) {
        $this->vlsms = formataMoeda($vlsms);
        $this->vlsmsad = formataMoeda($vlsmsad);
        $this->vlpacote = formataMoeda($vlpacote);
    }
}

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Guardo os parâmetos do POST em variáveis

$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
$cdtarifa = (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0;
$perdesconto = (isset($_POST['perdesconto'])) ? $_POST['perdesconto'] : 0;
$qtdsms = (isset($_POST['qtdsms'])) ? $_POST['qtdsms'] : 0;

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
$xml .= "   <cdtarifa>".$cdtarifa."</cdtarifa>";
$xml .= "   <qtdsms>".$qtdsms."</qtdsms>";
$xml .= "   <perdesconto>".converteFloat($perdesconto)."</perdesconto>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADSMS", "CALCULAR_TARIFA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    $erro = new Error($msgErro);

    echo json_encode($erro);

} else {

    $registro = $xmlObj->roottag->tags[0];

    $vlsms =   converteFloat(getByTagName($registro->tags,'vlsms'));
    $vlsmsad =   converteFloat(getByTagName($registro->tags,'vlsmsad'));
    $vlpacote =  converteFloat(getByTagName($registro->tags,'vlpacote'));

    $tarifas = new TarifaPacoteSMS($vlsms, $vlsmsad, $vlpacote);

    echo json_encode($tarifas);
}

?>
