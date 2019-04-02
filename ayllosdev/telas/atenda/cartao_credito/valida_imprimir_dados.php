<?php 

	/************************************************************************  
	  Fonte: imprimir_dados.php                                             
	  Autor: Anderson Alan                                                         
	  Data : Abril/2019                   Última Alteração: 00/00/0000         
																			
	  Objetivo  : Carregar dados para impressões de cartão de crédito       
																			 
	  Alterações: 	
							   
	************************************************************************/ 

	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || 		
		!isset($_POST["nrctrcrd"])) {
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];	
	$nrctrcrd = $_POST["nrctrcrd"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta) || !validaInteiro($nrctrcrd)) {
		exit();
	}


	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
	    echo 'hideMsgAguardo();';
	    echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	    exit();
	}


	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CCRD0008", "RETORNA_TIPO_ENVIO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exit();
	}

	$tipo_envio = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;

	if ($tipo_envio == 90 || $tipo_envio == 91) {
		exibeErro('Para recebimento da fatura e troca de pontos, atualize o endere&ccedil;o do cooperado no Sipag Net.');
	}

