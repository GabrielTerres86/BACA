<?
/*!
 * FONTE        	: form_cadidr.php
 * CRIAÇÃO      	: Lucas Reinert
 * DATA CRIAÇÃO 	: Fevereiro/2016
 * OBJETIVO     	: Form da tela CADIDR
 * ÚLTIMA ALTERAÇÃO : 08/08/2018
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */ 

session_start();	
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');		
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();	

$idaba    = (isset($_POST['idaba'])) ? (int) $_POST['idaba'] : null;
$nmdeacao = (($idaba === 1) ? 'BUSCA_IDVINCULACAO' : (($idaba === 0) ? 'BUSCA_IDIND' : false));

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= " </Dados>";
$xml .= "</Root>";
	
$xmlResult = mensageria($xml, "TELA_CADIDR", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);					

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
}
	
$id = 0;
if ($idaba === 0) {
	$id = getByTagName($xmlObj->roottag->tags[0]->tags,'idindicador');
	echo "$('#idindica',form).val($id);";
}elseif ($idaba === 1) {
	$id = getByTagName($xmlObj->roottag->tags[0]->tags,'idvinculacao');
	echo "$('#idvinculacao',form).val($id);";
}
