<?php 

	//************************************************************************//
	//*** Fonte: config.php                                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   Ultima Alteracao: 22/11/2016 ***//
	//***                                                                  ***//
	//*** Objetivo  : Variaveis globais de controle                        ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 22/10/2010 - Eliminar variaveis da session que sao   ***//
	//***                          utilizadas na validacao para permissao  ***//
	//***                          de acesso (David).                      ***//
	//***                                                                  ***//	 
	//***             21/05/2012 - Adicionado Servidor GED (Guilherme).    ***//
	//***                                                                  ***//
	//***             25/06/2013 - Adicionar pkglibera (David).            ***//
	//***                                                                  ***//
	//***             03/03/2015 - Incluir tratamento para requisicoes de  ***//
	//***                          scripts de monitoracao (David).         ***//
	//***                                                                  ***// 
	//***             07/07/2016 - Correcao do erro de uso da constante    ***// 
	//***                          $_ENV depreciada.SD 479874 (Carlos R.)  ***//	
	//***																   ***//
	//***			  14/09/2016 - Alteracao na armazenagem e leitura 	   ***//
	//***						   das configuracoes, de forma unificada   ***//
	//***						   para ambientes diferentes. SD 489051    ***//
	//***						   (Carlos Rafael Tanholi)	 			   ***//		
	//***																   ***//	
	//***			  29/09/2016 - Correcao no carregamento das variaveis  ***//
	//***						   $UrlSite e $UrlImagens que nao estavam  ***//
	//***						   sendo carregados corretamente.SD 489051 ***//
	//***						   (Carlos Rafael Tanholi)	 			   ***//	
	//***																   ***//		
	//***			  22/11/2016 - Feita nova consistencia para tratar as  ***//
	//***						   configuracoes de producao criptografadas***//
	//***						   (Carlos Rafael Tanholi) SD 489051       ***//	
	//***																   ***//	
	//************************************************************************//
	
	// carrega o arquivo .cfg de dados do sistema Ayllos
	$array_dados_ini = parse_ini_file("config.cfg", true);
	
	// Pega o nome do server
	define("SERVERNAMEAPP",gethostname());  

	// Array ( [0] => 0302dweb02 [1] => cecred [2] => coop [3] => br ) 
	list($serverCFG, $dominioCFG, $tipoCFG, $paisCFG) = explode('.', SERVERNAMEAPP);

	// torna unico o indice de configuracao para os servidores de PRODUCAO
	if ( in_array($serverCFG, array('0303appweb02', '0303appweb03', '0302appweb02', '0302appweb03')) ) {
		$serverCFG = 'PRODUCAO';
	}

	// valida a existencia do servidor e da configuracao para o mesmo no arquivo config.cfg
	if ( trim($serverCFG) == '' || array_key_exists($serverCFG, $array_dados_ini) == false ) {
		echo 'Configuração inexistente para o servidor ' . $serverCFG . ' no arquivo de configurações (config.cfg)';
		exit();
	}

	// Pega o nome do server 
	define("SERVERNAMECFG", $serverCFG);    

	// Nome do servidor com banco de dados PROGRESS
	$DataServer = ( SERVERNAMECFG == 'PRODUCAO' ) ? base64_decode($array_dados_ini[SERVERNAMECFG]['DATA_SERVER']) : $array_dados_ini[SERVERNAMECFG]['DATA_SERVER'];
	
	//URL do servico WebSpeed do Ayllos Web
	if (isset($ServerMonitoracao) && trim($ServerMonitoracao) <> '') {
		$url_webspeed_ayllosweb = 'http://'.$ServerMonitoracao.$array_dados_ini[SERVERNAMECFG]['URL_WEBSPEED_AYLLOS_WEB'];
	} else {		
		if ( SERVERNAMECFG == 'PRODUCAO' ) {
			$url_webspeed_ayllosweb = 'https://iayllos'.$array_dados_ini[SERVERNAMECFG]['URL_WEBSPEED_AYLLOS_WEB'];
	} else {		
			$url_webspeed_ayllosweb = $array_dados_ini[SERVERNAMECFG]['URL_WEBSPEED_AYLLOS_WEB'];
		}
	}	
	
	// Titulo do sistema
	$TituloSistema = $array_dados_ini[SERVERNAMECFG]['TITULO_SISTEMA'];
	
	// Titulo para pagina de login
	$TituloLogin = $array_dados_ini[SERVERNAMECFG]['TITULO_LOGIN'];
	
	// Url do site
	$UrlSite = 'http://'.$_SERVER['SERVER_NAME'].'/';
	
	// Url para imagens
	$UrlImagens = 'http://'.$_SERVER['SERVER_NAME'].'/imagens/';
	
	// Url para Login 
	$UrlLogin = $array_dados_ini[SERVERNAMECFG]['URL_LOGIN'];
	
	// Servidor do GED (Selbetti)
	$GEDServidor = ( SERVERNAMECFG == 'PRODUCAO' ) ? base64_decode($array_dados_ini[SERVERNAMECFG]['GED_SERVIDOR']) : $array_dados_ini[SERVERNAMECFG]['GED_SERVIDOR'];
	
	// Identificador dos grupos de usuarios nas maquinas HP-UX
	$gidNumbers[0] = 103; // Cecred
	$gidNumbers[1] = 902; // Desenvolvimento
	$gidNumbers[2] = 903; // Suporte
	$gidNumbers[3] = 905; // Admin
	
	// Identificador de pacotes ambientes nas maquinas HP-UX
	$MTCCServers["pkgprod"]   = 1;
	$MTCCServers["pkgdesen"]  = 2;
	$MTCCServers["pkgprodsb"] = 3;
	$MTCCServers["pkghomol"]  = 4;
	$MTCCServers["pkgtreina"] = 5;
	$MTCCServers["pkglibera"] = 6;
	
	if ((strpos($UrlSite."index.php",$_SERVER["SCRIPT_NAME"]) === false && isset($_POST["sidlogin"])) || 		
	    (strpos($UrlSite."principal.php",$_SERVER["SCRIPT_NAME"]) !== false && isset($_SESSION["sidlogin"]))) { 		
		$sidlogin = isset($_POST["sidlogin"]) ? $_POST["sidlogin"] : $_SESSION["sidlogin"];		
		
		// Define como deve ser feito o redirecionamento no caso da sessao expirar, ou ocorrer erro na leitura do XML, etc ...		
		$_SESSION["glbvars"][$sidlogin]["redirect"] = isset($_POST["redirect"]) ? $_POST["redirect"] : "html";
		
		// Eliminar variaveis utilizadas para validacao de permissao de acesso se existirem
		if  (isset($_SESSION["glbvars"][$sidlogin]["telpermi"])) {
			unset($_SESSION["glbvars"][$sidlogin]["telpermi"]);
			unset($_SESSION["glbvars"][$sidlogin]["rotpermi"]);
			unset($_SESSION["glbvars"][$sidlogin]["opcpermi"]);
		}
		
		$glbvars = $_SESSION["glbvars"][$sidlogin];		
	} else {
		$glbvars["redirect"] = "html";
	}
	
	// Dados de acesso ao Oracle
	if ( preg_match('/^0303/', trim(SERVERNAMEAPP)) ) { // verifica o servidor gravado na constante
		// URL de conexao "SAO PAULO";
		define("HOST" , $array_dados_ini[SERVERNAMECFG]['HOST_BD_SP']);		
	} else {
		// URL de conexao "CURITIBA";
		define("HOST" , $array_dados_ini[SERVERNAMECFG]['HOST_BD_CT']);		
	}
		
	define("USERE", $array_dados_ini[SERVERNAMECFG]['USERE']);
	define("PASSE", $array_dados_ini[SERVERNAMECFG]['PASSE']);
	define("KEY"  , ( SERVERNAMECFG == 'PRODUCAO' ) ? base64_decode($array_dados_ini[SERVERNAMECFG]['KEY'])   : $array_dados_ini[SERVERNAMECFG]['KEY']);
	define("IV"   , ( SERVERNAMECFG == 'PRODUCAO' ) ? base64_decode($array_dados_ini[SERVERNAMECFG]['IV'])    : $array_dados_ini[SERVERNAMECFG]['IV']);
?>
