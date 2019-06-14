<?php
/*!
 * FONTE        : concilia_todos_cheques.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 30/09/2016
 * OBJETIVO     : Rotina para conciliar todos os cheques da remessa
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
	
// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <nrremret>".$nrremret."</nrremret>";
$xml .= "   <intipmvt>".$intipmvt."</intipmvt>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_CUSTOD", "CUSTOD_CONCILIA_TODOS_CHEQUES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);		
//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	exibirErro('error',$msgErro,'Alerta - Aimaro','buscaRemessas(glbTabNriniseq, glbTabNrregist);',false);
	exit();
}else{
	$msgErro = 'Opera&ccedil;&atilde;o efetuada com sucesso!';
	exibirErro('inform',$msgErro,'Alerta - Aimaro','buscaRemessas(glbTabNriniseq, glbTabNrregist);',false);
}

?>
