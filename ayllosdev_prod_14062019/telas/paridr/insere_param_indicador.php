<?
/*!
 * FONTE        	: insere_param_indicador.php
 * CRIAÇÃO      	: Lucas Reinert
 * DATA CRIAÇÃO 	: Março/2016
 * OBJETIVO     	: Inserir novo parametro de indicador de reciprocidade
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
$idindica = (isset($_POST['idindica'])) ? $_POST['idindica'] : 0;
$cdprodut = (isset($_POST['cdprodut'])) ? $_POST['cdprodut'] : 0;	
$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0;	
$vlminimo = (isset($_POST['vlminimo'])) ? $_POST['vlminimo'] : 0;	
$vlmaximo = (isset($_POST['vlmaximo'])) ? $_POST['vlmaximo'] : 0;
$pertoler = (isset($_POST['pertoler'])) ? $_POST['pertoler'] : 0;
$perscore = (isset($_POST['perscore'])) ? $_POST['perscore'] : 0;
$perpeso = (isset($_POST['perpeso'])) ? $_POST['perpeso'] : 0;
$perdesc = (isset($_POST['perdesc'])) ? $_POST['perdesc'] : 0;
 
// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "<cdcooper>".$cdcooper."</cdcooper>";
$xml .= "<idindica>".$idindica."</idindica>";
$xml .= "<cdprodut>".$cdprodut."</cdprodut>";
$xml .= "<inpessoa>".$inpessoa."</inpessoa>";
$xml .= "<vlminimo>".$vlminimo."</vlminimo>";
$xml .= "<vlmaximo>".$vlmaximo."</vlmaximo>";
$xml .= "<pertoler>".$pertoler."</pertoler>";
$xml .= "<perscore>".$perscore."</perscore>";
$xml .= "<perpeso>".$perpeso."</perpeso>";
$xml .= "<perdesc>".$perdesc."</perdesc>";
$xml .= " </Dados>";
$xml .= "</Root>";
	
$xmlResult = mensageria($xml, "TELA_PARIDR", "INSERE_PAR_IND", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);					

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','$("#idindicador").focus();',false);
}else{
	echo "showError('inform', 'Parametriza&ccedil;&atilde;o gravada com sucesso!', 'Alerta - Ayllos', 'voltarTabela(); cTodosCabecalho.habilitaCampo(); $(\'#btnOK\', \'#frmCab\').trigger(\'click\')');";
}

?>