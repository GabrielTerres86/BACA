<?php
/*!
 * FONTE        : verifica_cheques_conciliados.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 03/10/2016
 * OBJETIVO     : Rotina para verificar cheques conciliados da remessa
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
$flgcqcon = 0;
$flgocorr = 0;	

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <nrremret>".$nrremret."</nrremret>";
$xml .= "   <intipmvt>".$intipmvt."</intipmvt>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_CUSTOD", "CUSTOD_VERIFICA_CHQ_CONC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'DADOS')){	
		$flgcqcon = $xmlObj->roottag->tags[0]->tags[0]->cdata;
		$flgocorr = $xmlObj->roottag->tags[0]->tags[1]->cdata;
	}
	echo 'confirmaCustodiaConc('.$flgcqcon.','.$flgocorr.')';
}

?>
