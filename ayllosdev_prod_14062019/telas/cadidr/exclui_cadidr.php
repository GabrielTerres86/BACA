<?
/*!
 * FONTE        	: exclui_cadidr.php
 * CRIAÇÃO      	: Lucas Reinert
 * DATA CRIAÇÃO 	: Fevereiro/2016
 * OBJETIVO     	: Excluir indicador/vinculacao de reciprocidade
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
 
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E', false)) <> '') {		
   exibirErro('error',$msgError,'Alerta - Ayllos','',false);
}
 
$idaba = (isset($_POST['idaba'])) ? (int) $_POST['idaba'] : null;
$id    = (isset($_POST['id'])) ? $_POST['id'] : '';
 
// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
if ($idaba === 1) {
	$xml .= "<idvinculacao>".$id."</idvinculacao>";
} elseif ($idaba === 0) {
	$xml .= "<idindica>".$id."</idindica>";
}
$xml .= " </Dados>";
$xml .= "</Root>";
	
	
$xmlResult = mensageria($xml, "TELA_CADIDR", (($idaba === 1) ? "EXCLUI_VINCULACAO" : "EXCLUI_IND"), $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);					

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','',false);
}else{
	echo "showError('inform', 'Registro exclu&iacute;do com sucesso!', 'Alerta - Ayllos', (($idaba === 1) ? 'consultaVinculacoes();' : 'consultaIndicadores();'));";
}
