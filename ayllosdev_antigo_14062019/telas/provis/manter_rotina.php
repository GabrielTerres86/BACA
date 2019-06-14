<?php 
	/*********************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Renato Darosci                                                   
	 Data : Ago/2016                �ltima Altera��o: 29/08/2016
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela PROVIS                                 
	                                                                  
	 Altera��es: 

	**********************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	$vlriscoA = $_POST["vlriscoA"]; 
	$vlriscoB = $_POST["vlriscoB"]; 
	$vlriscoC = $_POST["vlriscoC"]; 
	$vlriscoD = $_POST["vlriscoD"]; 
	$vlriscoE = $_POST["vlriscoE"]; 
	$vlriscoF = $_POST["vlriscoF"]; 
	$vlriscoG = $_POST["vlriscoG"]; 
	$vlriscoH = $_POST["vlriscoH"]; 
	$vlriscAA = $_POST["vlriscAA"]; 
	
	
    // Verifica Permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],"","A")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
	
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <vlriscoA>".$vlriscoA."</vlriscoA>";
	$xml .= "    <vlriscoB>".$vlriscoB."</vlriscoB>";
	$xml .= "    <vlriscoC>".$vlriscoC."</vlriscoC>";
	$xml .= "    <vlriscoD>".$vlriscoD."</vlriscoD>";
	$xml .= "    <vlriscoE>".$vlriscoE."</vlriscoE>";
	$xml .= "    <vlriscoF>".$vlriscoF."</vlriscoF>";
	$xml .= "    <vlriscoG>".$vlriscoG."</vlriscoG>"; 
	$xml .= "    <vlriscoH>".$vlriscoH."</vlriscoH>"; 
	$xml .= "    <vlriscAA>".$vlriscAA."</vlriscAA>"; 
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_PROVIS", "PROVISCL_GRAVA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjeto 	= getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Ayllos',$dsComand,false);
	} 
		
?>