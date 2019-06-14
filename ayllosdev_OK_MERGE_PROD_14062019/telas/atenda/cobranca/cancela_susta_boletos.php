<?php

set_time_limit(300);

/*************************************************************************
	Fonte: cancela_susta_boletos.php
	Autor: André Clemer						Ultima atualizacao: --/--/----
	Data : Fevereiro/2018
	
	Objetivo: Cancelar ou sustar os boletos.
	
	Alteracoes: 

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
	
$cddopcao = $_POST['cddopcao'];
$flgregis = trim($_POST['flgregis']);
$cdcooper = ($_POST["cdcooper"] ? $_POST["cdcooper"] : $glbvars["cdcooper"]);
$nrdconta = $_POST["nrdconta"];
$nrconven = $_POST["nrconven"];
$nmacao   = ($_POST["fltipo"] ? 'SUSTA_BOLETOS' : 'CANCELA_BOLETOS');

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= " </Dados>";
$xml .= "</Root>";

//var_dump($nmacao, $xml);exit;

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", $nmacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
    exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
}

echo 'hideMsgAguardo();';
echo (($_POST['fltipo']) ? "confirmaImpressaoCancelamento('".$flgregis."', 'confirmaHabilitacaoSerasa(\"".$cddopcao."\")');" : "confirmaSustacaoBoletos('".$cddopcao."');");
//echo (($_POST['fltipo']) ? "confirmaImpressaoCancelamento('".$flgregis."', 'imprimeRelatorio('confirmaHabilitacaoSerasa(\"\".$cddopcao.\"\")');');" : "imprimeRelatorio('confirmaSustacaoBoletos(\'".$cddopcao."\')');");