<?php 
	/*******************************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Tiago Castro - RKAM                                                    
	 Data : Jul/2015                Última Alteração:  
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela SITCTA.                                  
	                                                                  
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
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"",'A')) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}
	
	// Guardo os parâmetos do POST em variáveis	
	$cdsituacao            = (isset($_POST['cdsituacao'])) 				? $_POST['cdsituacao']				: 0;
	$inimpede_credito      = (isset($_POST['inimpede_credito'])) 		? $_POST['inimpede_credito'] 		: 0;
	$inimpede_talionario   = (isset($_POST['inimpede_talionario'])) 	? $_POST['inimpede_talionario']		: 0;
	$incontratacao_produto = (isset($_POST['incontratacao_produto'])) 	? $_POST['incontratacao_produto']	: 0;
	$tpacesso              = (isset($_POST['tpacesso'])) 				? $_POST['tpacesso'] 				: 0;
	$lancamentos           = (isset($_POST['lancamentos'])) 			? $_POST['lancamentos'] 			: 0;
	
	// Monta o xml de requisição
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cdsituacao>".				$cdsituacao				."</cdsituacao>";
	$xml .= "    <inimpede_credito>".		$inimpede_credito		."</inimpede_credito>";
	$xml .= "    <inimpede_talionario>".	$inimpede_talionario	."</inimpede_talionario>";
	$xml .= "    <incontratacao_produto>".	$incontratacao_produto	."</incontratacao_produto>";
	$xml .= "    <tpacesso>".				$tpacesso				."</tpacesso>";
	$xml .= "    <lancamentos>".			$lancamentos			."</lancamentos>";
	$xml .= " </Dados>";
	$xml .= "</Root>";		
	
	$xmlResult = mensageria($xml, "TELA_SITCTA", "ALTERAR_SITUACAO_CONTA_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xml_dados = simplexml_load_string($xmlResult);
	
	if ( $xml_dados->Erro != "" ) {
		exibirErro('error',$xml_dados->Erro,'Alerta - Ayllos','',false);
	}
	
	exibirErro('inform','Situa&ccedil;&atilde;o de Conta cadastrado com sucesso!','Alerta - Ayllos','estadoInicial();',false);
	
?>
