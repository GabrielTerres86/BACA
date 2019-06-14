<?php 

	//************************************************************************//
	//*** Fonte: impressao_log_teds_migradas.php                           ***//
	//*** Autor: Fabricio                                                  ***//
	//*** Data : Dezembro/2013                Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar impressão do log de Teds migradas              ***//
	//***             (Migracao Acredi >> Viacredi)                        ***//
	//***                                                                  ***//	 
	//*** Alterações: 18/11/2014 - Tratamento para a Incorporação Concredi ***//
	//***                          e Credimilsul SD 223543 (Vanessa).      ***//                                                    
	//***                                                                  ***//
	//***             02/12/2014 - Correção para pegar o diretório correto ***//
	//***                         para a Acredi - Creditextil (Vanessa)    ***//
	//***                                                                  ***//
	//***             21/09/2015 - Adicionar a cooperativa 16, para ler o  ***//
	//***                          arquivo para a cooperativa que foi      ***//
	//***                          selecionada na tela                     ***//
	//***                          (Douglas - Chamado 288683)              ***//
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

	
	// Se campos necessários para carregar dados não foram informados
	if (!isset($_POST["datmigra"]) && !isset($_POST["cdcopmig"])) {
		exibeErro('Parâmetros incorretos.');
	}		

	$datmigra = $_POST["datmigra"];
	$cdcopmig = $_POST["cdcopmig"];
	$dscopmig = $_POST["dscopmig"];
	
	if($cdcopmig == 2){
		$dscopmig = "creditextil";
	}
	
	$glbvars["dscopmig"] = strtolower(trim($dscopmig));

	// Verifica se data do log é válida
	if (!validaData($datmigra)) {
		exibeErro('Data de log inválida.');
	
	}
	
	if($glbvars["cdcooper"] == 1 || $glbvars["cdcooper"] == 3 || $glbvars["cdcooper"] == 13 || $glbvars["cdcooper"] == 16){
		$cdCooper = $cdcopmig;
	}else{
		$cdCooper = $glbvars["cdcooper"];
	}	

	$dsiduser = session_id();	
	
	// Monta o xml de requisição
	$xmlGetLog  = "";
	$xmlGetLog .= "<Root>";
	$xmlGetLog .= "  <Cabecalho>";
	$xmlGetLog .= "    <Bo>b1wgen0050.p</Bo>";
	$xmlGetLog .= "    <Proc>obtem-log-teds-migradas</Proc>";
	$xmlGetLog .= "  </Cabecalho>";
	$xmlGetLog .= "  <Dados>";
	$xmlGetLog .= "    <cdcooper>".$cdCooper."</cdcooper>";
	$xmlGetLog .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetLog .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetLog .= "    <datmigra>".$datmigra."</datmigra>";
	$xmlGetLog .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
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

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
	
?>