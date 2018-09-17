<?php 

	//************************************************************************//
	//*** Fonte: impressao_log_spb.php                                     ***//
	//*** Autor: David                                                     ***//
	//*** Data : Novembro/2009                Última Alteração: 07/11/2016 ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar impressão do log de transações SPB             ***//
	//***                                                                  ***//	 
	//*** Alterações: 01/09/2011 - Retirar condição de validação p/ campo  ***//
	//***                          cdsitlog (David).                       ***//
	//***																   ***//
	//***             29/05/2012 - Chamado a funcao visualizaPDF para      ***//
	//***						   mostrar o arquivo. (Fabricio)           ***//
	//***																   ***//
	//***             06/07/2012 - Adicionado confirmacao para impressao   ***//
	//***						   Retirado var post imprimir (Jorge)      ***//
  //***                                                                  ***//
  //***             14/09/2016 -  Adicionado novo paramentro "$cdifconv".***//
  //***               (Evandro - RKAM)                                   ***//
    //***														           ***//
	//***             07/11/2016 - Ajustes para corrigir problemas encontrados ***//
    //***                          durante a homologação da área		   ***//
	//***                          (Adriano - M211)				           ***//
	//***														           ***//
	//************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"L")) <> "") {
		exibeErro($msgError);		
	}
	
	$nmarqpdf = $_POST["nmarqpdf"];

	// Se campos necessários para carregar dados não foram informados
	if (!isset($_POST["flgidlog"]) || !isset($_POST["dtmvtlog"]) || !isset($_POST["numedlog"])) {
		exibeErro('Parâmetros incorretos.');
	}		

	$flgidlog = $_POST["flgidlog"];
	$dtmvtlog = $_POST["dtmvtlog"];
	$numedlog = $_POST["numedlog"];
	$cdsitlog = $_POST["cdsitlog"];
  
	// Verifica se flag de identificação do log é válida
	if ($flgidlog != "1" && $flgidlog != "2" && $flgidlog != "3") {
		exibeErro('Log inválido.');
	
	}

	// Verifica se data do log é válida
	if (!validaData($dtmvtlog)) {
		exibeErro('Data de log inválida.');
	
	}

	// Verifica se tipo do log é um inteiro válido
	if (!validaInteiro($numedlog)) {
		exibeErro('Tipo de log inválido.');
	
	}

	$dsiduser = session_id();	
	
	// Monta o xml de requisição
	$xmlGetLog  = "";
	$xmlGetLog .= "<Root>";
	$xmlGetLog .= "  <Cabecalho>";
	$xmlGetLog .= "    <Bo>b1wgen0050.p</Bo>";
	$xmlGetLog .= "    <Proc>obtem-log-spb</Proc>";
	$xmlGetLog .= "  </Cabecalho>";
	$xmlGetLog .= "  <Dados>";
	$xmlGetLog .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetLog .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetLog .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetLog .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetLog .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetLog .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetLog .= "    <flgidlog>".$flgidlog."</flgidlog>";
	$xmlGetLog .= "    <dtmvtlog>".$dtmvtlog."</dtmvtlog>";
	$xmlGetLog .= "    <numedlog>".$numedlog."</numedlog>";
	$xmlGetLog .= "    <cdsitlog>".$cdsitlog."</cdsitlog>";
	$xmlGetLog .= "    <dsiduser>".$dsiduser."</dsiduser>";
	$xmlGetLog .= "  </Dados>";
	$xmlGetLog .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetLog);		
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLog = getObjectXML($xmlResult);

	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjLog->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro($msg);
	}

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
	
?>