<?
/*!
 * FONTE        	: insere_indicador.php
 * CRIAÇÃO      	: Lucas Reinert
 * DATA CRIAÇÃO 	: Fevereiro/2016
 * OBJETIVO     	: Inserir novo indicador de reciprocidade
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
 
$idindica = (isset($_POST['idindica'])) ? $_POST['idindica'] : '';
$nmindica = (isset($_POST['nmindica'])) ? utf8_decode($_POST['nmindica']) : '';	
$tpindica = (isset($_POST['tpindica'])) ? $_POST['tpindica'] : '';	
$flgativo = (isset($_POST['flgativo'])) ? $_POST['flgativo'] : 0;	
$dsindica = (isset($_POST['dsindica'])) ? utf8_decode($_POST['dsindica']) : '';		
 
// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .="<idindica>".$idindica."</idindica>";
$xml .="<nmindica>".$nmindica."</nmindica>";
$xml .="<tpindica>".$tpindica."</tpindica>";
$xml .="<flgativo>".$flgativo."</flgativo>";
$xml .="<dsindica>".$dsindica."</dsindica>";
$xml .= " </Dados>";
$xml .= "</Root>";
	
$xmlResult = mensageria($xml, "TELA_CADIDR", "INSERE_IND", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);					

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','cNmindica.focus();',false);
}else{
	echo "showError('inform', 'Indicador cadastrado com sucesso!', 'Alerta - Ayllos', 'consultaIndicadores();trocaVisao(\'\');');";
}

?>