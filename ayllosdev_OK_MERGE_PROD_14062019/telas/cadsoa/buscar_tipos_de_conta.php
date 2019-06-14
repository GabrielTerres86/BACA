<?php 
	/*******************************************************************************
	 Fonte: buscar_tipos_de_conta.php                                                 
	 Autor: Lombardi
	 Data : Jan/2018                Última Alteração:  
	
	 Objetivo  : Buscar os tipos de conta.                                  
	
	 Alterações: 
	
	********************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
		
	// Guardo os parâmetos do POST em variáveis	
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '0';
	
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <inpessoa>".$inpessoa."</inpessoa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0006", "BUSCAR_TIPOS_DE_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = simplexml_load_string($xmlResult);
	
	if ( $xmlObj->Erro != "" ) {
		exibirErro('error',$xmlObj->Erro,'Alerta - Ayllos','fechaOpcao()',false);
	}
	
	echo $xmlObj->asXML();
?>