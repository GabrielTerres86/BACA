<?php

/* !
 * FONTE        : busca_regional.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Rotina para buscarpa
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

// Inicializa
$retornoAposErro = '';

// Recebe a operação que está sendo realizada
$cddregio = (isset($_POST['cddregio'])) ? $_POST['cddregio'] : 0;
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;

// Procedure a ser chamada
$cddopcao = 'C';

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
$xml .= "   <cddregio>" . $cddregio . "</cddregio>";
//$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
//$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONLDB", "LISTA_REGIONAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

//----------------------------------------------------------------------------------------------------------------------------------	
// Controle de Erros
//----------------------------------------------------------------------------------------------------------------------------------
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Ayllos', $retornoAposErro, false);
}

$dsdregio = $xmlObj->roottag->tags[0]->tags[0]->tags[1]->cdata;


echo "$('#dsdregio','#frmConta').val('$dsdregio');";
 