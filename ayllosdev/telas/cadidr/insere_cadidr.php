<?
/*!
 * FONTE        	: insere_cadidr.php
 * CRIAÇÃO      	: Lucas Reinert
 * DATA CRIAÇÃO 	: Fevereiro/2016
 * OBJETIVO     	: Inserir novo indicador/vinculacao de reciprocidade
 * ÚLTIMA ALTERAÇÃO : --/--/----
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
$idindica = (isset($_POST['idindica'])) ? $_POST['idindica'] : '';
$idvinculacao = (isset($_POST['idvinculacao'])) ? $_POST['idvinculacao'] : '';
$nmindica = (isset($_POST['nmindica'])) ? utf8_decode($_POST['nmindica']) : '';	
$nmvinculacao = (isset($_POST['nmvinculacao'])) ? utf8_decode($_POST['nmvinculacao']) : '';	
$tpindica = (isset($_POST['tpindica'])) ? $_POST['tpindica'] : '';	
$flgativo = (isset($_POST['flgativo'])) ? $_POST['flgativo'] : 0;	
$dsindica = (isset($_POST['dsindica'])) ? utf8_decode($_POST['dsindica']) : '';		

if ($idaba === 1) { 
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .="    <idvinculacao>".$idvinculacao."</idvinculacao>";
	$xml .="    <nmvinculacao>".$nmvinculacao."</nmvinculacao>";
	$xml .="    <flgativo>".$flgativo."</flgativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_CADIDR", "INSERE_VINCULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

} elseif ($idaba === 0) {
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .="    <idindica>".$idindica."</idindica>";
	$xml .="    <nmindica>".$nmindica."</nmindica>";
	$xml .="    <tpindica>".$tpindica."</tpindica>";
	$xml .="    <flgativo>".$flgativo."</flgativo>";
	$xml .="    <dsindica>".$dsindica."</dsindica>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_CADIDR", "INSERE_IND", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
}

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos',(($idaba === 1) ? '$("#nmindica",form).focus();' : '$("#nmvinculacao",form).focus();'),false);
}else{
	echo "showError('inform', 'Registro cadastrado com sucesso!', 'Alerta - Ayllos', (($idaba === 1) ? 'consultaVinculacoes();trocaVisao(\'\');' : 'consultaIndicadores();trocaVisao(\'\');'));";
}

