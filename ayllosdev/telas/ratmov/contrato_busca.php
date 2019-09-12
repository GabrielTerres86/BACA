<?
/*!
 * FONTE        : contrato_busca.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 29/01/2019
 * OBJETIVO     : Rotina para busca dos contratos
 * ALTERAÇÕES   : 
 *
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Guardo os parâmetos do POST em variáveis    
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;

// Monta o xml de requisicao
$xml  = "<Root>";
$xml .= "    <Dados>";
$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "        <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "    </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "RATI0003", "CONSULTAR_CONTRATOS_ATIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
	if ($msgErro == "") {
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
	}
	exibirErro('error',$msgErro,'Alerta - Ayllos',"",false);
}

$registros = $xmlObjeto->roottag->tags[0]->tags;

include('contrato_tab.php');
?>