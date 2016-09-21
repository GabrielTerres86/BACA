<?php 
	
	//************************************************************************//
	//*** Fonte: grava_log.php                                             ***//
	//*** Autor: Fabr�cio                                                  ***//
	//*** Data : Julho/2012                   �ltima Altera��o:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Logar consulta da imagem.                            ***//
	//***            												       ***//	
	//***                                                                  ***//	 
	//*** Altera��es: 										     	       ***//
	//***                          									       ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
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
	
	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
		 
		 
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
?>