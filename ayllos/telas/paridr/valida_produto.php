<?php
	/*************************************************************************
	  Fonte: valida_indicador.php
	  Autor: Lucas Reinert                                          
	  Data : Mar�o/2016                         �ltima Altera��o: --/--/----		   
	                                                                   
	  Objetivo  : Valida o indicador inserido
	                                                                 
	  Altera��es: 
				  
	***********************************************************************/
	session_start();
	
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	$cdproduto = (isset($_POST['cdproduto'])) ? $_POST['cdproduto'] : 0  ;	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "	<cdproduto>".$cdproduto."</cdproduto>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "TELA_PARIDR", "VALIDA_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);					
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','limpaProduto();',false);
	}else{
		$dsproduto = $xmlObj->roottag->tags[0]->tags[0]->tags[0]->cdata;		
		echo 'cDsprodut.val("'.$dsproduto.'");';
	}
?>