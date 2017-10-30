<?php
/* 
  FONTE        : reenvia_solicitacao.php
  CRIAÇÃO      : Kelvin Souza Ott
  DATA CRIAÇÃO : 29/06/2017
  OBJETIVO     : Rotina para reenviar solicitacao de cartão da tela mancrd
  --------------
  ALTERAÇÕES   : 27/10/2017 - Efetuar ajustes e melhorias na tela (Lucas Ranghetti #742880)
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
$nrctrcrd = (isset($_POST['nrctrcrd'])) ? $_POST['nrctrcrd'] : 0;

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrcrcard>" . $nrcrcard . "</nrcrcard>";
$xml .= "   <nrctrcrd>" . $nrctrcrd . "</nrctrcrd>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_MANCRD", "PC_REENVIAR_SOLICITACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', "", false);    
}
else{
	exibirErro('inform', 'Solicitacao do cartao reenviada com sucesso.', 'Alerta - Ayllos', "buscaCartoes();", false);
}

?>