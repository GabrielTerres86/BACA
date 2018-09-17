<?php
/*************************************************************************
	Fonte: alterar_convenio.php
	Autor: Tiago - CECRED				Ultima atualizacao:  /  /
	Data : Agosto/2017
	
	Objetivo: Efetua alteracao do convenio.
	
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
$flghomol = isset($_POST["flghomol"]) ? $_POST["flghomol"] : 0;
$cdopehom = isset($_POST["cdopehom"]) ? $_POST["cdopehom"] : '';
$idretorn = isset($_POST["idretorn"]) ? $_POST["idretorn"] : 1;
$flgativo = isset($_POST["flgativo"]) ? $_POST["flgativo"] : 0;
$lstemail = isset($_POST["lstemail"]) ? $_POST["lstemail"] : '';

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <flghomol>".$flghomol."</flghomol>";
$xml .= "   <cdopehom>".$cdopehom."</cdopehom>";
$xml .= "   <idretorn>".$idretorn."</idretorn>";
$xml .= "   <flgativo>".$flgativo."</flgativo>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PGTA0001", "ALTERARCONVENIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

//Caso não for InternetBanking a forma de envio
//Não é necessario cadastrar E-mails
if($idretorn != 1){
	exit();
}


//------------------------------------------------------------------------------------------------
// Inclusao dos emails
//------------------------------------------------------------------------------------------------
// Montar o xml de Requisicao
$xml = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <flghomol>".$flghomol."</flghomol>";
$xml .= "   <lstemail>".$lstemail."</lstemail>";
$xml .= "   <cddopcao>I</cddopcao>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PGTA0001", "INCLUIREMAILCONVENIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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