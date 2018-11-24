<?php
/*************************************************************************
	Fonte: obtem_consulta.php                                               
	Autor: Lucas Reinert                                          
	Data : Fevereiro/2016                     Última Alteração: 16/08/2018
																	
	Objetivo  : Carrega os dados da tela PARIDR
																	
	Alterações: 16/08/2018 - Adicionada vinculação (André Clemer - Supero)
				
**************************************************************************/

session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");	
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	
	
$indaba   = (isset($_POST['indaba'])) ? (int) $_POST['indaba'] : null;
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
$nmdeacao = ($indaba === 1) ? 'OBTEM_VINCULACAO' : 'OBTEM_IND';
	
// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "	<cdcooper>".$cdcooper."</cdcooper>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_PARIDR", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
} else {
	$registros = $xmlObj->roottag->tags[0]->tags;

	if ($indaba === 1) {
		include('tabela_vinculacao.php');
	} elseif ($indaba === 0) {
		include('tabela_paridr.php');
	}
}
