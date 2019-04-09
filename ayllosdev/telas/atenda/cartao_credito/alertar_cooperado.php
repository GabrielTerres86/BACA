<?php 

	/************************************************************************  
	  Fonte: imprimir_dados.php                                             
	  Autor: Anderson Alan                                                         
	  Data : Abril/2019                   Última Alteração: 00/00/0000         
																			
	  Objetivo  : Carregar mensagem de alerta oa cooperado sobre o cartão de crédito
																			 
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
		!isset($_POST["nrctrcrd"]) ||
	    !isset($_POST['tipoAcao' ])) {
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];	
	$nrctrcrd = $_POST["nrctrcrd"];
	$tipoAcao  = $_POST['tipoAcao' ];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta) || !validaInteiro($nrctrcrd)) {
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
		echo "showError(\"error\", \"".$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata."\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
	}

	$tipo_envio = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;

	if (!empty($tipo_envio)) {

		if ($tipoAcao == 1) {
		echo "showError(\"inform\", \"Aten&ccedil;&atilde;o: Oriente o cooperado que a carta senha e o cart&atilde;o ser&atilde;o encaminhados para o endere&ccedil;o escolhido<br>e o cart&atilde;o n&atilde;o estar&aacute; habilitado para utiliza&ccedil;&atilde;o no TA at&eacute; que seja cadastrada a senha de 6 d&iacute;gitos.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";

		} else if ($tipoAcao == 2) {
			echo "showError(\"inform\", \"Aten&ccedil;&atilde;o: O cart&atilde;o ser&aacute; encaminhado para endere&ccedil;o escolhido e o cart&atilde;o n&atilde;o estar&aacute;<br>habilitado para utiliza&ccedil;&atilde;o no TA at&eacute; que seja cadastrada a senha de 6 d&iacute;gitos.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
		
		}

	}

