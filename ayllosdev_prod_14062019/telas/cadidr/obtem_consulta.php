<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Lucas Reinert                                          
	  Data : Julho/2015                         �ltima Altera��o: 07/08/2018
	                                                                   
	  Objetivo  : Carrega os dados da tela CADIDR
	                                                                 
	  Altera��es: 10/09/2013 - Inclus�o de vincula��es
				  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$idaba = (isset($_POST['idaba'])) ? (int) $_POST['idaba'] : null;

	if ($idaba === 0) {
		
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

	} elseif ($idaba === 1) {

		// Montar o xml de Requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";	
		$xml .= " </Dados>";
		$xml .= "</Root>";
			
		$xmlResult = mensageria($xml, "TELA_CADIDR", "BUSCA_VINCULACOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);					
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		}
			
		$registros = $xmlObj->roottag->tags[0]->tags;		
		
		include('tabela_vinculacoes.php');

	}
?>
