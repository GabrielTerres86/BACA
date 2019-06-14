<?php
/* 
  FONTE        : busca_parametros.php
  CRIA��O      : Kelvin Souza Ott
  DATA CRIA��O : 09/08/2017
  OBJETIVO     : Rotina para controlar as opera��es da tela LIBCRM
  --------------
  ALTERA��ES   : 
  -------------- 
 */
?> 

<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_LIBCRM", "PC_BUSCA_PARAMETROS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibirErro('error', $msgErro, 'Alerta - Ayllos', "", false);    
}

$registros = $xmlObj->roottag->tags;

$fllibcrm  = $registros[0]->tags[0]->cdata;


echo "$('#flgaccrm').val('" .  $fllibcrm . "')";
?>




	
	
    	

