<?php 

/*************************************************************************
	Fonte: valida_exclusao.php
	Autor: Gabriel						Ultima atualizacao:
	Data : Dezembro/2010
	
	Objetivo: Validar a exclusao do convenio CEB.
	
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

// Monta xml
$xmlValidaExclusao  = "";
$xmlValidaExclusao .= "<Root>";
$xmlValidaExclusao .= " <Cabecalho>";
$xmlValidaExclusao .= "  <Bo>b1wgen0082.p</Bo>";
$xmlValidaExclusao .= "  <Proc>valida-exclusao-convenio</Proc>";
$xmlValidaExclusao .= " </Cabecalho>";
$xmlValidaExclusao .= " <Dados>";
$xmlValidaExclusao .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlValidaExclusao .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xmlValidaExclusao .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xmlValidaExclusao .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>"; 
$xmlValidaExclusao .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xmlValidaExclusao .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";           
$xmlValidaExclusao .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlValidaExclusao .= "   <nrconven>".$nrconven."</nrconven>";
$xmlValidaExclusao .= "   <idseqttl>1</idseqttl>";         
$xmlValidaExclusao .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xmlValidaExclusao .= " </Dados>";
$xmlValidaExclusao .= "</Root>";


// Executa script para envio do XML
$xmlResult = getDataXML($xmlValidaExclusao);

// Cria objeto para classe de tratamento de XML
$xmlObjDadosCobranca = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra cr&iacute;tica
if (strtoupper($xmlObjDadosCobranca->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDadosCobranca->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

echo 'hideMsgAguardo();';
echo 'confirmaExclusao();';


// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}	

?>