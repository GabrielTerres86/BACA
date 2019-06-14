<?
/*!
 * FONTE        : busca_responsaveis_assinatura.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 11/01/2018
 * OBJETIVO     : Rotina para buscar os responsaveis pela assinatura de autorizacao
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

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA", "BUSCA_RESP_ASSINATURA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

if(strtoupper($xmlObj->roottag->tags[0]->name == 'RESPONSAVEIS')){
	$count = 0;
	foreach($xmlObj->roottag->tags[0]->tags as $responsavel){
		echo '<input type="hidden" id="resp'. $count .'" name="resp' . $count .'" value="' . $responsavel->tags[0]->cdata . '" />';
		$count++;
	}
	echo '<input type="hidden" id="qtdresp" name="qtdresp" value="' . $count . '" />';
}