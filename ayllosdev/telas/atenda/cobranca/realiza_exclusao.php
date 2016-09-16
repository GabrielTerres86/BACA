<?php

/*************************************************************************
	Fonte: realiza_exclusao.php
	Autor: Gabriel						Ultima atualizacao:
	Data : Dezembro/2010
	
	Objetivo: Efetuar a exclusao do convenio CEB.
	
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
$nrcnvceb = $_POST["nrcnvceb"];
$flgregis = $_POST["flgregis"];

$xmlExcluiConvenio  = "";
$xmlExcluiConvenio .= "<Root>";
$xmlExcluiConvenio .= " <Cabecalho>";
$xmlExcluiConvenio .= "  <Bo>b1wgen0082.p</Bo>";
$xmlExcluiConvenio .= "  <Proc>exclui-convenio</Proc>";
$xmlExcluiConvenio .= " </Cabecalho>";
$xmlExcluiConvenio .= " <Dados>";
$xmlExcluiConvenio .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlExcluiConvenio .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xmlExcluiConvenio .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xmlExcluiConvenio .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xmlExcluiConvenio .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xmlExcluiConvenio .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";
$xmlExcluiConvenio .= "	  <nrdconta>".$nrdconta."</nrdconta>";
$xmlExcluiConvenio .= "   <nrconven>".$nrconven."</nrconven>";
$xmlExcluiConvenio .= "   <nrcnvceb>".$nrcnvceb."</nrcnvceb>";
$xmlExcluiConvenio .= "   <idseqttl>1</idseqttl>";
$xmlExcluiConvenio .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xmlExcluiConvenio .= " </Dados>";
$xmlExcluiConvenio .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlExcluiConvenio);

$xmlObjCarregaDados = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

echo 'hideMsgAguardo();';
echo 'acessaOpcaoAba();';

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}

?>