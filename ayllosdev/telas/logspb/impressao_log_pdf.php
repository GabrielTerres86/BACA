<?php 

	//************************************************************************//
	//*** Fonte: impressao_log_pdf.php                                     ***//
	//*** Autor: Lucas Ranghetti                                           ***//
	//*** Data : Agosto/2015                  �ltima Altera��o: 11/11/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar impress�o do log em pdf                        ***//
	//***                                                                  ***//	 
	//*** Altera��es: 11/11/2015 - Adicionado campo "Crise" inestcri.	   ***//
	//***						   (Jorge/Andrino)						   ***//                                                     ***//
	//***                                                                  ***//
	//************************************************************************//
	
	//session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');	
	
	isPostMethod();	
	
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"L")) <> "") {
			exibeErro($msgError);		
	}
	
	$cddopcao = $_POST["cddopcao"];
	$flgidlog = $_POST["flgidlog"];
	$dtmvtlog = $_POST["dtmvtlog"];
	$numedlog = $_POST["numedlog"];
	$cdsitlog = $_POST["cdsitlog"];	
	$nrdconta = $_POST["nrdconta"];
	$dsorigem = $_POST["dsorigem"];
	$inestcri = $_POST["inestcri"];
	$vlrdated = $_POST["vlrdated"];

	$dsiduser = session_id();
	
	// Monta o xml de requisi��o
	$xmlGetLog  = "";
	$xmlGetLog .= "<Root>";
	$xmlGetLog .= "  <Cabecalho>";
	$xmlGetLog .= "    <Bo>b1wgen0050.p</Bo>";
	$xmlGetLog .= "    <Proc>impressao-log-pdf</Proc>";
	$xmlGetLog .= "  </Cabecalho>";
	$xmlGetLog .= "  <Dados>";
	$xmlGetLog .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetLog .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetLog .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetLog .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetLog .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetLog .= "    <dsorigem>".$dsorigem."</dsorigem>";
	$xmlGetLog .= "    <flgidlog>".$flgidlog."</flgidlog>";
	$xmlGetLog .= "    <dtmvtlog>".$dtmvtlog."</dtmvtlog>";
	$xmlGetLog .= "    <numedlog>".$numedlog."</numedlog>";
	$xmlGetLog .= "    <cdsitlog>".$cdsitlog."</cdsitlog>";
	$xmlGetLog .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetLog .= "    <vlrdated>".$vlrdated."</vlrdated>";
	$xmlGetLog .= "    <dsiduser>".$dsiduser."</dsiduser>";
	$xmlGetLog .= "    <inestcri>".$inestcri."</inestcri>";
	$xmlGetLog .= "  </Dados>";
	$xmlGetLog .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetLog);		
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLog = getObjectXML($xmlResult);
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjLog->roottag->tags[0]->attributes["NMARQPDF"];
	
	//echo strtoupper($xmlObjLog->roottag->tags[0]->name);
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro($msg);
	}

	// Chama fun��o para fazer download do arquivo
	visualizaArquivo($nmarqpdf,'pdf');
		
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) {
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
	
?>