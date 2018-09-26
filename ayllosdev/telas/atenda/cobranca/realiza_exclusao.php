<?php

/*************************************************************************
	Fonte: realiza_exclusao.php
	Autor: Gabriel						Ultima atualizacao: 04/08/2016
	Data : Dezembro/2010
	
	Objetivo: Efetuar a exclusao do convenio CEB.
	
	Alteracoes: 18/02/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

				04/08/2016 - Adicionado campo de forma de envio de 
						     arquivo de cobrança. (Reinert)

*************************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");	

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
	exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
}	
	
$inapurac = $_POST["inapurac"];
$nrdconta = $_POST["nrdconta"];
$nrconven = $_POST["nrconven"];
$nrcnvceb = $_POST["nrcnvceb"];
$nmeacao  = $inapurac == 1 ? "BUSCA_APURACAO" : "EXCLUI_CONVENIO" ;

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <nrcnvceb>".$nrcnvceb."</nrcnvceb>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", $nmeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
    if ($inapurac == 1) {
        exibirConfirmacao($msgError,'Confirma&ccedil;&atilde;o - Aimaro','realizaExclusao(0);','acessaOpcaoAba();',false);
	exit();
    } else {
        exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
    }
}

echo 'hideMsgAguardo();';
echo $inapurac == 1 ? "realizaExclusao(0);" : "acessaOpcaoAba();" ;
?>