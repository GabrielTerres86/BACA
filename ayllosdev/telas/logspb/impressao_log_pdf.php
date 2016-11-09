<?php 

	//************************************************************************//
	//*** Fonte: impressao_log_pdf.php                                     ***//
	//*** Autor: Lucas Ranghetti                                           ***//
	//*** Data : Agosto/2015                  Última Alteração: 07/11/2016 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar impressão do log em pdf                        ***//
	//***                                                                  ***//	 
	//*** Alterações: 11/11/2015 - Adicionado campo "Crise" inestcri.	   ***//
	//***						   (Jorge/Andrino)						   ***//                        
	//***                                                                  ***//
  //***             14/09/2016 -  Adicionado novo paramentro "$cdifconv".***//
    //***                          (Evandro - RKAM)						   ***//
	//***														           ***//
	//***             07/11/2016 - Ajustes para corrigir problemas encontrados ***//
    //***                          durante a homologação da área		   ***//
	//***                          (Adriano - M211)				           ***//
	//***														           ***//
	//************************************************************************//
	
	//session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
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
	
	// Monta o xml de requisição
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
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjLog->roottag->tags[0]->attributes["NMARQPDF"];
	
	//echo strtoupper($xmlObjLog->roottag->tags[0]->name);
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro($msg);
	}

	// Chama função para fazer download do arquivo
	visualizaArquivo($nmarqpdf,'pdf');
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
	
?>