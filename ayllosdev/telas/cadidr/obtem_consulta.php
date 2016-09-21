<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Lucas Reinert                                          
	  Data : Julho/2015                         Última Alteração: --/--/----		   
	                                                                   
	  Objetivo  : Carrega os dados da tela CADIDR
	                                                                 
	  Alterações: 
				  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
		
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "TELA_CADIDR", "BUSCA_IND", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);					
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}
		
	$registros = $xmlObj->roottag->tags[0]->tags;		
	
	include('tabela_cadidr.php');
?>
