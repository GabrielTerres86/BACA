<?
/*!
 * FONTE        	: exclui_indicador.php
 * CRIAÇÃO      	: Lucas Reinert
 * DATA CRIAÇÃO 	: Fevereiro/2016
 * OBJETIVO     	: Excluir indicador de reciprocidade
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
 
$idindica = (isset($_POST['idindica'])) ? $_POST['idindica'] : '';
 
// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .="<idindica>".$idindica."</idindica>";
$xml .= " </Dados>";
$xml .= "</Root>";
	
$xmlResult = mensageria($xml, "TELA_CADIDR", "EXCLUI_IND", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);					

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','',false);
}else{
	echo "showError('inform', 'Indicador exclu&iacute;do com sucesso!', 'Alerta - Ayllos', 'consultaIndicadores();');";
}
?>