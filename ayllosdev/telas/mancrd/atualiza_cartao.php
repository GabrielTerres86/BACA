<?php
/* 
  FONTE        : atualiza_cartao.php
  CRIA��O      : Kelvin Souza Ott
  DATA CRIA��O : 29/06/2017
  OBJETIVO     : Rotina para controlar as opera��es da tela MANCRD
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

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrcrcard = (isset($_POST['nrcrcard'])) ? $_POST['nrcrcard'] : 0;
$nrcctitg = (isset($_POST['nrcctitg'])) ? $_POST['nrcctitg'] : 0;
$cdadmcrd = (isset($_POST['cdadmcrd'])) ? $_POST['cdadmcrd'] : 0;
$nrcpftit = (isset($_POST['nrcpftit'])) ? $_POST['nrcpftit'] : 0;
$flgdebit = (isset($_POST['flgdebit'])) ? $_POST['flgdebit'] : 0;
$nmtitcrd = (isset($_POST['nmtitcrd'])) ? $_POST['nmtitcrd'] : "";

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrcrcard>" . $nrcrcard . "</nrcrcard>";
$xml .= "   <nrcctitg>" . $nrcctitg . "</nrcctitg>";
$xml .= "   <cdadmcrd>" . $cdadmcrd . "</cdadmcrd>";
$xml .= "   <nrcpftit>" . $nrcpftit . "</nrcpftit>";
$xml .= "   <flgdebit>" . $flgdebit . "</flgdebit>";
$xml .= "   <nmtitcrd>" . $nmtitcrd . "</nmtitcrd>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_MANCRD", "PC_ATUALIZA_CARTAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', "", false);    
} 
else{
	exibirErro('inform', 'Cartao atualizado com sucesso.', 'Alerta - Ayllos', "fechaRotina($('#divRotina'));buscaCartoes();", false);
}

?>