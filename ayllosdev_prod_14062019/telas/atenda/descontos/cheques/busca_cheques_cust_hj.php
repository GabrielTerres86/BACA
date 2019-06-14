<?
/*!
 * FONTE        : busca_cheques_cust_hj.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 24/01/2018
 * OBJETIVO     : Retornar os cheques custodiados hoje
 * --------------
 * ALTERAÇÕES   :
 */		

session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../../includes/config.php");
require_once("../../../../includes/funcoes.php");
require_once("../../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../../class/xmlfile.php");	

// Guardo os parâmetos do POST em variáveis	
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : 0;

// // Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrborder>".$nrborder."</nrborder>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "BUSCA_CHEQUES_CUST_HJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	exit();
}

if(strtoupper($xmlObj->roottag->tags[0]->name == 'DADOS')){
	echo '<input type="hidden" id="dscheque" name="dscheque" value="' . $xmlObj->roottag->tags[0]->tags[0]->cdata . '" />';
}