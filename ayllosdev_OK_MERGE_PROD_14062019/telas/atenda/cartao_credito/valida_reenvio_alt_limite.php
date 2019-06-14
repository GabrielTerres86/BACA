<?php

/*************************************************************************
	Fonte: valida_reenvio_alt_limite.php
	Autor: Augusto - Supero			Ultima atualizacao: --/--/----
	Data : Fevereiro/2019
	
	Objetivo: Validar o reenvio da última proposta de alteração de limite
	
	Alteracoes: 

*************************************************************************/

session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	
    
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

// Verifica se o número da conta foi informado
if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcctitg"])) {
    exibeErro("Par&acirc;metros incorretos.");
}	

$nrdconta = $_POST["nrdconta"];
$nrcctitg = $_POST["nrcctitg"];

// Verifica se o número da conta é um inteiro valido
if (!validaInteiro($nrdconta)) {
    exibeErro("Conta/dv inv&aacute;lida.");
}

// Verifica se número do cartão é um inteiro valido
if (!validaInteiro($nrcctitg)) {
    exibeErro("Cart&atilde;o inv&aacute;lido.");
}

// Função para exibir erros na tela através de javascript
function exibeErro($msgErro) { 
    echo 'hideMsgAguardo();';
    echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
    exit();
}

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrcctitg>".$nrcctitg."</nrcctitg>";	
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA_CRD", "VALIDA_REENVIO_ALT_LIMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
    exibeErro($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

$proposta = $xmlObj->roottag->tags[0]->tags[0];

if (empty($proposta)) {
    exibeErro("Erro ABC");
}

$nrcrcard = getByTagName($proposta->tags,"nrcrcard");
$cdadmcrd = getByTagName($proposta->tags,"cdadmcrd");
$nrctrcrd = getByTagName($proposta->tags,"nrctrcrd");

echo "reenviarUltimaPropostaLimite($nrcrcard, $cdadmcrd, $nrctrcrd);";