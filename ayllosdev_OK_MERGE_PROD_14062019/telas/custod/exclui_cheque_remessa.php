<?php
/*!
 * FONTE        : exclui_cheque_remessa.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 29/09/2016
 * OBJETIVO     : Rotina para excluir cheque da remessa
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */		

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();			

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;	
$nrconven = (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0;
$nrremret = (isset($_POST['nrremret'])) ? $_POST['nrremret'] : 0;
$intipmvt = (isset($_POST['intipmvt'])) ? $_POST['intipmvt'] : 0;
$dsdocmc7 = (isset($_POST['dsdocmc7'])) ? $_POST['dsdocmc7'] : '';
	
// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <nrremret>".$nrremret."</nrremret>";
$xml .= "   <intipmvt>".$intipmvt."</intipmvt>";
$xml .= "   <dsdocmc7>".$dsdocmc7."</dsdocmc7>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_CUSTOD", "CUSTOD_EXCLUI_CHEQUE_REMESSA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
}else{
	echo 'buscaChequesRemessa();';
	// echo 'hideMsgAguardo();';
	echo 'bloqueiaFundo($(\'#divRotina\'));';
	$msgErro = 'Cheque removido com sucesso!';
	exibirErro('inform',$msgErro,'Alerta - Aimaro','hideMsgAguardo();',false);
}

?>
