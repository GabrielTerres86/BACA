<?php
/*!
 * FONTE        : cria_trans_pend_resgate_cst.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 19/01/2018
 * OBJETIVO     : Rotina para criar transacao pendente 
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
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
$nrcpfrep = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;
$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : 0;

// Montar o xml de Requisicao
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
	exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	exit();
}

$dscheque = $xmlObj->roottag->tags[0]->tags[1]->cdata;
//Remover formatacao dos CMC7
$dscheque = str_replace(array('<', '>', ':'), '', $dscheque);

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <idseqttl>1</idseqttl>";
$xml .= "   <nrcpfrep>".$nrcpfrep."</nrcpfrep>";
$xml .= "   <nrcpfope>0</nrcpfope>";
$xml .= "   <cdcoptfn>0</cdcoptfn>";
$xml .= "   <cdagetfn>0</cdagetfn>";
$xml .= "   <cdagetfn>0</cdagetfn>";
$xml .= "   <idastcjt>1</idastcjt>";
$xml .= "   <dscheque>".$dscheque."</dscheque>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA", "CRIA_TRANS_PEND_RESGATE_CST", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);		
//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	exit();
}else{
	$msgErro = 'Pendencias de aprovacao criadas com sucesso';
	exibirErro('inform',$msgErro,'Alerta - Ayllos','carregaBorderosCheques();',false);
}

?>
