<?php 

	/************************************************************************
	 Fonte: rotinas_analise.php                                        
	 Autor: Luis Fernando (GFT)
	 Data : 24/01/2019                Última Alteração: 
	                                                                  
	 Objetivo  : Agrupa as rotinas de analise dos pagadores e dos titulos

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");


	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC TITS - BORDERO");

	
	function erroJson($mensagem){
		$json = array();
		$json["status"] = 'erro';
		$json["mensagem"] = $mensagem;
		echo json_encode($json);
		exit();
	}

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		erroJson("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$rotina   = $_POST["rotina"];
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		erroJson("Conta/dv inv&aacute;lida.");
	}
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		erroJson("Contrato inv&aacute;lido.");
	}
	
	$selecionados = isset($_POST["selecionados"]) ? $_POST["selecionados"] : array();
	if(count($selecionados)==0){
		erroJson("Selecione ao menos um t&iacute;tulo");
	}
	$selecionados = implode($selecionados,",");

	switch($rotina){
		case "biro":
			$xml = "<Root>";
		    $xml .= " <Dados>";
		    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
		    $xml .= "   <chave>".$selecionados."</chave>";
		    $xml .= " </Dados>";
		    $xml .= "</Root>";
		    
		 	// CONSULTA DA IBRATAN	
		    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","SOLICITA_BIRO_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		    $xmlObj = getClassXML($xmlResult);
		    $root = $xmlObj->roottag;
			if ($root->erro){
				// erroJson(htmlentities($root->erro->registro->dscritic));
			}
		break;
		case "analise_pagadores":
			$xml = "<Root>";
		    $xml .= " <Dados>";
		    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
		    $xml .= "   <chave>".$selecionados."</chave>";
		    $xml .= " </Dados>";
		    $xml .= "</Root>";
		    
		 	// CONSULTA DA IBRATAN	
		    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","SOLICITA_ANALISE_PAGADOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		    $xmlObj = getClassXML($xmlResult);
		    $root = $xmlObj->roottag;
			if ($root->erro){
				erroJson(htmlentities($root->erro->registro->dscritic));
			}
		break;
		case "valida_alteracao":
			// FAZ VALIDAÇÃO DOS TITULOS SE BATEM COM AS REGRAS DA TAB052 DE VALOR E PRAZO
			$xml = "<Root>";
		    $xml .= " <Dados>";
		    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		    $xml .= "   <chave>".$selecionados."</chave>";
			$xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		    $xml .= " </Dados>";
		    $xml .= "</Root>";

		    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","VALIDAR_TITULOS_ALTERACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		    $xmlObj = getClassXML($xmlResult);
		    $root = $xmlObj->roottag;
			if ($root->erro){
				erroJson(htmlentities($root->erro->registro->dscritic));
			}
		break;
	}

	$json = array();
	$json['status'] = 'sucesso';
	echo json_encode($json);