<?php
/*************************************************************************
	Fonte: valida_exclusao.php
	Autor: Andre Santos - SUPERO			Ultima atualizacao:  /  /
	Data : Setembro/2014
	
	Objetivo: Efetua exclusao do convenio.
	
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
	exibeErro($msgError);		
}

$nrdconta = $_POST["nrdconta"];
$nrconven = $_POST["nrconven"];
$tpdtermo = $_POST["tpdtermo"];

// Monta xml
$xmlValidaExclusao  = "";
$xmlValidaExclusao .= "<Root>";
$xmlValidaExclusao .= " <Cabecalho>";
$xmlValidaExclusao .= "  <Bo>b1wgen0192.p</Bo>";
$xmlValidaExclusao .= "  <Proc>efetua-aceite-cancel</Proc>";
$xmlValidaExclusao .= " </Cabecalho>";
$xmlValidaExclusao .= " <Dados>";
$xmlValidaExclusao .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlValidaExclusao .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xmlValidaExclusao .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xmlValidaExclusao .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlValidaExclusao .= "   <nrconven>".$nrconven."</nrconven>";
$xmlValidaExclusao .= "   <tpdtermo>".$tpdtermo."</tpdtermo>";
$xmlValidaExclusao .= " </Dados>";
$xmlValidaExclusao .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlValidaExclusao);

// Cria objeto para classe de tratamento de XML
$xmlObjDados = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra cr&iacute;tica
if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}
?>