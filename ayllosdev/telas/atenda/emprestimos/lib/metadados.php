<?
/**
 * FONTE         : metadados.php
 * CRIAÇÃO       : Petter Rafael (Envolti)
 * DATA CRIAÇÃO  : 18/09/2018
 * OBJETIVO      : Funções para busca de metadados para alimentar formulário de empréstimos.
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');	
require_once('../../../class/xmlfile.php');
isPostMethod();	

 //Captura de dados via POST
 $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
 $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
 $nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0 ;
 $nraditiv = (isset($_POST['nraditiv'])) ? $_POST['nraditiv'] : 0 ;
 $cdaditiv = (isset($_POST['cdaditiv'])) ? $_POST['cdaditiv'] : 0 ;
 $tpaplica = (isset($_POST['tpaplica'])) ? $_POST['tpaplica'] : '';
 $tpctrato = (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : 0;

//Buscar metadados para montar o formulário de empréstimos
$xml  = "";
$xml .= "<Root>";
$xml .= "  <Cabecalho>";
$xml .= "	    <Bo>b1wgen0115.p</Bo>";
$xml .= "        <Proc>Busca_Dados</Proc>";
$xml .= "  </Cabecalho>";
$xml .= "  <Dados>";
$xml .= '       <cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
$xml .= '		<cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
$xml .= '		<nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
$xml .= '		<cdoperad>' . $glbvars['cdoperad'] . '</cdoperad>';
$xml .= '		<nmdatela>' . $glbvars['nmdatela'] . '</nmdatela>';
$xml .= '		<idorigem>' . $glbvars['idorigem'] . '</idorigem>';
$xml .= '		<dtmvtolt>' . $glbvars['dtmvtolt'] . '</dtmvtolt>';
$xml .= '		<dtmvtopr>' . $glbvars['dtmvtopr'] . '</dtmvtopr>';
$xml .= '		<inproces>' . $glbvars['inproces'] . '</inproces>';
$xml .= '		<cddopcao>' . $cddopcao . '</cddopcao>';
$xml .= '		<nrdconta>' . $nrdconta . '</nrdconta>';
$xml .= '		<nrctremp>' . $nrctremp . '</nrctremp>';
$xml .= '		<dtmvtolx>' . $dtmvtolx . '</dtmvtolx>';
$xml .= '		<nraditiv>' . $nraditiv . '</nraditiv>';
$xml .= '		<cdaditiv>' . $cdaditiv . '</cdaditiv>';
$xml .= '		<tpaplica>' . $tpaplica . '</tpaplica>';
$xml .= '		<nrctagar>' . $nrctagar . '</nrctagar>';
$xml .= '		<tpctrato>' . $tpctrato . '</tpctrato>';
$xml .= "  </Dados>";
$xml .= "</Root>";

$xmlResult = getDataXML($xml);
$xmlObj = getObjectXML($xmlResult);

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
  exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
}

$dados 		= $xmlObj->roottag->tags[0]->tags[0]->tags;

//Busca lista de bens
$xmlBens  = "<Root>";
$xmlBens .= " <Dados>";
$xmlBens .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xmlBens .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
$xmlBens .= "   <tpctrato>" . $tpctrato . "</tpctrato>";
$xmlBens .= " </Dados>";
$xmlBens .= "</Root>";

$xmlBensResult = mensageria($xmlBens, "TELA_ADITIV", "BUSCA_BENS_TP5", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlBensObj = getObjectXML($xmlBensResult);

if ( strtoupper($xmlBensObj->roottag->tags[0]->name) == 'ERRO' ) {
  exibirErro('error',$xmlBensObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
}

$registrosBens 	= $xmlBensObj->roottag->tags[0]->tags;
$dadosBens 		= $xmlBensObj->roottag->tags[0]->tags[0]->tags;
?>