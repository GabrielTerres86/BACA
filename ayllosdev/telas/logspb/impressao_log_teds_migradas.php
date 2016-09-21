<?php 

	//************************************************************************//
	//*** Fonte: impressao_log_teds_migradas.php                           ***//
	//*** Autor: Fabricio                                                  ***//
	//*** Data : Dezembro/2013                �ltima Altera��o:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Gerar impress�o do log de Teds migradas              ***//
	//***             (Migracao Acredi >> Viacredi)                        ***//
	//***                                                                  ***//	 
	//*** Altera��es: 18/11/2014 - Tratamento para a Incorpora��o Concredi ***//
	//***                          e Credimilsul SD 223543 (Vanessa).      ***//                                                    
	//***                                                                  ***//
	//***             02/12/2014 - Corre��o para pegar o diret�rio correto ***//
	//***                         para a Acredi - Creditextil (Vanessa)    ***//
	//***                                                                  ***//
	//***             21/09/2015 - Adicionar a cooperativa 16, para ler o  ***//
	//***                          arquivo para a cooperativa que foi      ***//
	//***                          selecionada na tela                     ***//
	//***                          (Douglas - Chamado 288683)              ***//
	//************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	
	// Se campos necess�rios para carregar dados n�o foram informados
	if (!isset($_POST["datmigra"]) && !isset($_POST["cdcopmig"])) {
		exibeErro('Par�metros incorretos.');
	}		

	$datmigra = $_POST["datmigra"];
	$cdcopmig = $_POST["cdcopmig"];
	$dscopmig = $_POST["dscopmig"];
	
	if($cdcopmig == 2){
		$dscopmig = "creditextil";
	}
	
	$glbvars["dscopmig"] = strtolower(trim($dscopmig));

	// Verifica se data do log � v�lida
	if (!validaData($datmigra)) {
		exibeErro('Data de log inv�lida.');
	
	}
	
	if($glbvars["cdcooper"] == 1 || $glbvars["cdcooper"] == 3 || $glbvars["cdcooper"] == 13 || $glbvars["cdcooper"] == 16){
		$cdCooper = $cdcopmig;
	}else{
		$cdCooper = $glbvars["cdcooper"];
	}	

	$dsiduser = session_id();	
	
	// Monta o xml de requisi��o
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

	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjLog->roottag->tags[0]->attributes["NMARQPDF"];
	
	//echo strtoupper($xmlObjLog->roottag->tags[0]->name);
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro($msg);
	}

	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

		
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) {
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
	
?>