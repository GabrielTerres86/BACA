<?php 
	/*******************************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Tiago Castro - RKAM                                                    
	 Data : Jul/2015                Última Alteração:  
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela CADSOA.                                  
	                                                                  
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
	$tpproduto = (isset($_POST['tpproduto'])) ? $_POST['tpproduto'] : '0';
	$tpconta   = (isset($_POST['tpconta'])) ? $_POST['tpconta'] : '';
	$inpessoa  = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : 'CONSULTA';
	$servicos = (isset($_POST['servicos'])) ? $_POST['servicos'] : '';
	$vlmincapi = (isset($_POST['vlmincapi'])) ? $_POST['vlmincapi'] : '0';
	
	// Verifica Permissão
	/* if (($msgError = validaPermissao($glbvars["nmdatela"],"",substr($cddopcao,0,1))) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}  */
	
	
	
	// Consulta servicos
	if ($operacao == 'CONSULTA')	{
		// Monta o xml de requisição
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <tpproduto>".$tpproduto."</tpproduto>";
		$xml .= "    <tpconta>".$tpconta."</tpconta>";	
		$xml .= "    <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= " </Dados>";
		$xml .= "</Root>";		
		
		$xmlResult = mensageria($xml, "cada0003", "CONS_SERV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xml_dados = simplexml_load_string($xmlResult);
	}
	else if ($operacao == 'CONSISTENCIA') {
		// Monta o xml de requisição
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <tpproduto>".$tpproduto."</tpproduto>";
		$xml .= "    <tpconta>".$tpconta."</tpconta>";
		$xml .= "    <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= "    <servico>".$servicos."</servico>";		
		$xml .= " </Dados>";
		$xml .= "</Root>";		
		
		$xmlResult = mensageria($xml, "cada0003", "VAL_SERV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xml_dados = simplexml_load_string($xmlResult);
	}
	//Inserir servicos
	else{
		// Monta o xml de requisição
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <tpproduto>".$tpproduto."</tpproduto>";
		$xml .= "    <tpconta>".$tpconta."</tpconta>";
		$xml .= "    <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= "    <servicos>".$servicos."</servicos>";		
		$xml .= "    <vlmincapi>".$vlmincapi."</vlmincapi>";		
		$xml .= " </Dados>";
		$xml .= "</Root>";		
		
		$xmlResult = mensageria($xml, "cada0003", "INS_SERV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xml_dados = simplexml_load_string($xmlResult);
	}
		
	if ( $xml_dados->Erro != "" ) {
		exibirErro('error',$xml_dados->Erro,'Alerta - Ayllos','fechaOpcao()',false);
	}
	
	echo $xml_dados->asXML(); 
		
?>
