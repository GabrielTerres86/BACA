<?php 

	//************************************************************************//
	//*** Fonte: config.php                                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   Última Alteração: 03/03/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Variáveis globais de controle                        ***//
	//***                                                                  ***//	 
	//*** Alterações: 22/10/2010 - Eliminar variáveis da session que são   ***//
	//***                          utilizadas na validação para permissão  ***//
	//***                          de acesso (David).                      ***//
	//***                                                                  ***//	 
	//***             21/05/2012 - Adicionado Servidor GED (Guilherme).    ***//
	//***                                                                  ***//
	//***             25/06/2013 - Adicionar pkglibera (David).            ***//
	//***                                                                  ***//
	//***             03/03/2015 - Incluir tratamento para requisições de  ***//
	//***                          scripts de monitoração (David).         ***//
	//***                                                                  ***// 
	//***             07/07/2016 - Correcao do erro de uso da constante    ***// 
	//**                           $_ENV depreciada.SD 479874 (Carlos R.)  ***//
	//************************************************************************//

	// Nome do servidor com banco de dados PROGRESS
	$DataServer = "pkgdesen2";
	
	//URL do serviço WebSpeed do Ayllos Web
	if (isset($ServerMonitoracao) && trim($ServerMonitoracao) <> '') {
		$url_webspeed_ayllosweb = 'http://'.$ServerMonitoracao.'.cecred.coop.br/cgi-bin/cgiip.exe/WService=ws_ayllos/';
	} else {		
		$url_webspeed_ayllosweb = "http://caixadev2.cecred.coop.br/cgi-bin/cgiip.exe/WService=ws_ayllos/";
	}	
	
	// Título do sistema
	$TituloSistema = ":: Sistema Ayllos - DESENVOLVIMENTO ::";
	
	// Título para página de login
	$TituloLogin = "SISTEMA AYLLOS<br>DESENVOLVIMENTO";
	
	// Url do site
	$UrlSite = "http://ayllosdev2.cecred.coop.br/";
	
	// Url para imagens
	$UrlImagens = "http://ayllosdev2.cecred.coop.br/imagens/";
	
	// Url para Login 
	$UrlLogin = "http://intranetdev2.cecred.coop.br/login_sistemas.php";
	
	// Servidor do GED (Selbetti)
	$GEDServidor = "0303hmlged01";
	
	// Identificador dos grupos de usuários nas máquinas HP-UX
	$gidNumbers[0] = 103; // Cecred
	$gidNumbers[1] = 902; // Desenvolvimento
	$gidNumbers[2] = 903; // Suporte
	$gidNumbers[3] = 905; // Admin
	
	// Identificador de pacotes ambientes nas máquinas HP-UX
	$MTCCServers["pkgprod"]   = 1;
	$MTCCServers["pkgdesen"]  = 2;
	$MTCCServers["pkgprodsb"] = 3;
	$MTCCServers["pkghomol"]  = 4;
	$MTCCServers["pkgtreina"] = 5;
	$MTCCServers["pkglibera"] = 6;
	
	if ((strpos($UrlSite."index.php",$_SERVER["SCRIPT_NAME"]) === false && isset($_POST["sidlogin"])) || 		
	    (strpos($UrlSite."principal.php",$_SERVER["SCRIPT_NAME"]) !== false && isset($_SESSION["sidlogin"]))) { 		
		$sidlogin = isset($_POST["sidlogin"]) ? $_POST["sidlogin"] : $_SESSION["sidlogin"];		
		
		// Define como deve ser feito o redirecionamento no caso da sessão expirar, ou ocorrer erro na leitura do XML, etc ...		
		$_SESSION["glbvars"][$sidlogin]["redirect"] = isset($_POST["redirect"]) ? $_POST["redirect"] : "html";
		
		// Eliminar variáveis utilizadas para validação de permissão de acesso se existirem
		if  (isset($_SESSION["glbvars"][$sidlogin]["telpermi"])) {
			unset($_SESSION["glbvars"][$sidlogin]["telpermi"]);
			unset($_SESSION["glbvars"][$sidlogin]["rotpermi"]);
			unset($_SESSION["glbvars"][$sidlogin]["opcpermi"]);
		}
		
		$glbvars = $_SESSION["glbvars"][$sidlogin];		
	} else {
		$glbvars["redirect"] = "html";
	}
	
	// Pega o nome do server
	define("SERVERNAMEAPP", gethostname());     

	// Dados de acesso ao Oracle
	define("HOST" , "(DESCRIPTION =(ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = 0302oradev01)(PORT = 1521))) (CONNECT_DATA =(SERVICE_NAME = ayllosd) )  )");
	define("USERE", "YXlsbG9z");
	define("PASSE", "cHdkY2VjcmVkMjAxMg==");
	
	define("KEY"  , "50983417512346753284723840854609576043576094576059437609");
	define("IV"   , "12345678");
	
		
?>
