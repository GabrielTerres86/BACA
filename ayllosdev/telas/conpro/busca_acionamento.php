<?php

/* !
 * FONTE        : busca_acionamento.php
 * CRIA��O      : Daniel Zimmermann
 * DATA CRIA��O : 22/03/2016 
 * OBJETIVO     : Rotina para controlar a busca de acionamentos
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();


// Recebe a opera��o que est� sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$dtinicio = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '';
$dtafinal = (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : '';
$tpproduto = (isset($_POST['tpproduto'])) ? $_POST['tpproduto'] : '9';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibeErroNew($msgError);
}

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
$xml .= "   <dtinicio>" . $dtinicio . "</dtinicio>";
$xml .= "   <dtafinal>" . $dtafinal . "</dtafinal>";
$xml .= "   <tpproduto>".$tpproduto."</tpproduto>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONPRO", "CONPRO_ACIONAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', "", true);
    exit();
}

$registros = $xmlObj->roottag->tags[0]->tags;
$qtregist = $xmlObj->roottag->tags[1]->cdata;

include('tab_acionamento.php');