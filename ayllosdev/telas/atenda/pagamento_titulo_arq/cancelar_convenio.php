<?php
/*************************************************************************
	Fonte: cancelar_convenio.php
	Autor: Tiago - CECRED				Ultima atualizacao:  /  /
	Data : Agosto/2017
	
	Objetivo: Efetua cancelamento do convenio.
	
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

$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
$nrconven = isset($_POST["nrconven"]) ? $_POST["nrconven"] : 1;

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PGTA0001", "CANCELARCONVENIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);		
	
//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------
if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	

	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	
	if($msgErro == null || $msgErro == ''){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	}
	
	exibeErro($msgErro);
	
} 

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}
?>