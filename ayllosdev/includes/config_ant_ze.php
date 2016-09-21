<?php 

	//************************************************************************//
	//*** Fonte: config.php                                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   Última Alteração: 25/06/2013 ***//
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
	//************************************************************************//
	
	// Nome do servidor com banco de dados PROGRESS
	$DataServer = "pkgprod";
	
	//URL do serviço WebSpeed do Ayllos Web
	$url_webspeed_ayllosweb = "https://iayllos.cecred.coop.br/cgi-bin/cgiip.exe/WService=ws_ayllos/";
	
	// Título do sistema
	$TituloSistema = ":: Sistema Ayllos ::";
	
	// Título para página de login
	$TituloLogin = "SISTEMA AYLLOS";
	
	// Url do site
	$UrlSite = "https://ayllos.cecred.coop.br/";
	
	// Url para imagens
	$UrlImagens = "https://ayllos.cecred.coop.br/imagens/";
	
	// Url para Login 
	$UrlLogin = "http://intranet.cecred.coop.br/login_sistemas.php";
	
	// Servidor do GED (Selbetti)
	$GEDServidor = "ged.cecred.coop.br";	
	
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

?>
