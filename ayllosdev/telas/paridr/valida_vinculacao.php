<?php
/*************************************************************************
	Fonte: valida_vinculacao.php
	Autor: André Clemer - Supero
	Data : Agosto/2018                         Última Alteração: --/--/----		   
																	
	Objetivo  : Valida a vinculação inserida
																	
	Alterações: 
				
***********************************************************************/
session_start();


// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	
	
$idvinculacao = (isset($_POST['idvinculacao'])) ? $_POST['idvinculacao'] : 0  ;	
	
// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "	<idvinculacao>".$idvinculacao."</idvinculacao>";
$xml .= " </Dados>";
$xml .= "</Root>";
	
$xmlResult = mensageria($xml, "TELA_PARIDR", "VALIDA_VINCULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);					

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','limpaVinculacao();',false);
}else{
	$nmvinculacao = $xmlObj->roottag->tags[0]->tags[0]->tags[0]->cdata;		
	echo '$("#nmvinculacao", frmVinculacao).val("'.$nmvinculacao.'");';
}
