<?php 
	
	//************************************************************************//
	//*** Fonte: grava_log.php                                             ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Julho/2012                   Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Logar consulta da imagem.                            ***//
	//***            												       ***//	
	//***                                                                  ***//	 
	//*** Alterações: 										     	       ***//
	//***                          									       ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}
	
	$cdcooper = $_POST["cdcooper"];
	$dstransa = $_POST["dstransa"];
	$nrdconta = $_POST["nrdconta"];
	$cdprogra = "IMGCHQ";
	
	
	// Monta o xml de requisição
	$xmlGravaLog  = "";
	$xmlGravaLog .= "<Root>";
	$xmlGravaLog .= "	<Cabecalho>";
	$xmlGravaLog .= "		<Bo>b1wgen0040.p</Bo>";
	$xmlGravaLog .= "		<Proc>grava-log</Proc>";
	$xmlGravaLog .= "	</Cabecalho>";
	$xmlGravaLog .= "	<Dados>";
	$xmlGravaLog .= "		<cdcooper>".$cdcooper."</cdcooper>";
	$xmlGravaLog .= "		<dttransa>".$glbvars["dtmvtolt"]."</dttransa>";
	$xmlGravaLog .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGravaLog .= "		<dstransa>".$dstransa."</dstransa>";
	$xmlGravaLog .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGravaLog .= "		<cdprogra>".$cdprogra."</cdprogra>";
	$xmlGravaLog .= "	</Dados>";
	$xmlGravaLog .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGravaLog);
		
				
	// Cria objeto para classe de tratamento de XML
	$xmlObjLog = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
		 
		 
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro");';
		exit();
	}
	
?>