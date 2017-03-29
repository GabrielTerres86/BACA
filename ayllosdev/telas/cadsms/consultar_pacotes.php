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

// Guardo os parâmetos do POST em variáveis	
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
$flgstatus = (isset($_POST['flgstatus'])) ? $_POST['flgstatus'] : -1;
$pagina = (isset($_POST['pagina'])) ? $_POST['pagina'] : 1;

$tamanho_pagina = 20;

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
$xml .= "   <flgstatus>".$flgstatus."</flgstatus>";
$xml .= "   <pagina>".$pagina."</pagina>";
$xml .= "   <tamanho_pagina>".$tamanho_pagina."</tamanho_pagina>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADSMS", "LISTAR_PACOTES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', "", true);
}

$registros = $xmlObj->roottag->tags;

include('grid_pacotes.php');

?>