<?
/*!
 * FONTE        	: insere_param_vinculacao.php
 * CRIAÇÃO      	: Andre Clemer - Supero
 * DATA CRIAÇÃO 	: Agosto/2018
 * OBJETIVO     	: Inserir novo parametro de vinculacao de reciprocidade
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

$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
$idvinculacao = (isset($_POST['idvinculacao'])) ? $_POST['idvinculacao'] : 0;
$cdprodut = (isset($_POST['cdprodut'])) ? $_POST['cdprodut'] : 0;	
$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0;	
$perpeso = (isset($_POST['perpeso'])) ? $_POST['perpeso'] : 0;
$perdesc = (isset($_POST['perdesc'])) ? $_POST['perdesc'] : 0;
 
// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "<cdcooper>".$cdcooper."</cdcooper>";
$xml .= "<idvinculacao>".$idvinculacao."</idvinculacao>";
$xml .= "<cdprodut>".$cdprodut."</cdprodut>";
$xml .= "<inpessoa>".$inpessoa."</inpessoa>";
$xml .= "<perpeso>".$perpeso."</perpeso>";
$xml .= "<perdesc>".$perdesc."</perdesc>";
$xml .= " </Dados>";
$xml .= "</Root>";
	
$xmlResult = mensageria($xml, "TELA_PARIDR", "INSERE_PAR_VINCULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);					

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','$("idvinculacao").focus();',false);
}else{
	echo "showError('inform', 'Parametriza&ccedil;&atilde;o gravada com sucesso!', 'Alerta - Ayllos', 'voltarTabela(); cTodosCabecalho.habilitaCampo(); $(\'#btnOK\', \'#frmCab\').trigger(\'click\')');";
}
