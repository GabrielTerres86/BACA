<?php
/*************************************************************************
	Fonte: pagamento_titulo_arq.php
	Autor: Andre Santos - SUPERO
	Data : Setembro/2014            Ultima atualizacao:  /  /

	Objetivo: Busca termo de Pagtos de Titulos por Arquivos.

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

// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
if (!isset($_POST["nrdconta"])) {
	exibeErro("Par&acirc;metros incorretos.");
}

$nrdconta = $_POST["nrdconta"];
$nrconven = $_POST["nrconven"];
$tpdtermo = $_POST["tpdtermo"];

// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");

setVarSession("opcoesTela",$opcoesTela);

// Monta o xml para a requisicao
$xmlGetDadosTermo  = "";
$xmlGetDadosTermo .= "<Root>";
$xmlGetDadosTermo .= " <Cabecalho>";
$xmlGetDadosTermo .= "   <Bo>b1wgen0192.p</Bo>";
$xmlGetDadosTermo .= "   <Proc>busca-termo-servico</Proc>";
$xmlGetDadosTermo .= " </Cabecalho>";
$xmlGetDadosTermo .= " <Dados>";
$xmlGetDadosTermo .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlGetDadosTermo .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xmlGetDadosTermo .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xmlGetDadosTermo .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlGetDadosTermo .= "   <nrconven>".$nrconven."</nrconven>";
$xmlGetDadosTermo .= "   <tpdtermo>".$tpdtermo."</tpdtermo>";
$xmlGetDadosTermo .= " </Dados>";
$xmlGetDadosTermo .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlGetDadosTermo);

// Cria objeto para classe de tratamento de XML
$xmlObjDadosTermo = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra cr&iacute;tica
if (strtoupper($xmlObjDadosTermo->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDadosTermo->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

$xmltermo = $xmlObjDadosTermo->roottag->tags[0]->attributes["XMLTERMO"];

$bufferTermo = str_replace('<termo>','',str_replace('</termo>','',$xmltermo));

echo $bufferTermo;

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	echo '</script>';
	exit();
}
?>