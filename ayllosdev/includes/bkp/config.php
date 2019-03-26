<?php 

	//************************************************************************//
	//*** Fonte: config.php                                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   �ltima Altera��o: 20/08/2018 ***//
	//***                                                                  ***//
	//*** Objetivo  : Vari�veis globais de controle                        ***//
	//***                                                                  ***//	 
	//*** Altera��es: 22/10/2010 - Eliminar vari�veis da session que s�o   ***//
	//***                          utilizadas na valida��o para permiss�o  ***//
	//***                          de acesso (David).                      ***//
	//***                                                                  ***//	 
	//***             21/05/2012 - Adicionado Servidor GED (Guilherme).    ***//
	//***                                                                  ***//
	//***             25/06/2013 - Adicionar pkglibera (David).            ***//
	//***                                                                  ***//
	//***             03/03/2015 - Incluir tratamento para requisi��es de  ***//
	//***                          scripts de monitora��o (David).         ***//
	//***                                                                  ***// 
	//***             07/07/2016 - Correcao do erro de uso da constante    ***// 
	//***                          $_ENV depreciada.SD 479874 (Carlos R.)  ***//
	//***                                                                  ***// 
	//***             12/08/2016 - Criacao das constantes KEY e IV         ***// 
	//***                          existentes apenas no desen impactou no  ***// 
	//***						   SD 501778. (Carlos R.)				   ***//		
	//***                                                                  ***//
	//***             01/09/2016 - Correcao na forma de uso da string de   ***//
	//***                          conexao com o banco Oracle, para SP e   ***//	
	//***						   CURITIBA. SD 509174 (Carlos R.)         ***//	
	//***                                                                  ***//	
	//***																   ***//	
	//***             20/08/2018 - Criacao de variaveis para conexao ao    ***//
	//***                          servico FIPE (Marcos-Envolti)           ***//
    //***                                                                  ***//	
	//***             21/09/2018 - Atualizacao da descricao Ayllos para    ***//
	//***                          Aimaro. Projeto 413 - Mudança de Marca  ***//
	//***   					   (Elton)                                 ***//				 
    //***                                                                  ***//	
	//***             30/01/2019 - Alteracao endereco para os serviso SOA  ***//
	//***                          (Jaison - P442)                         ***//
	//************************************************************************//

	// Nome do servidor com banco de dados PROGRESS
	$DataServer = "pkgprod";
	
	//URL do servi�o WebSpeed do Aimaro Web
	if (isset($ServerMonitoracao) && trim($ServerMonitoracao) <> '') {
		$url_webspeed_ayllosweb = 'http://'.$ServerMonitoracao.'.cecred.coop.br/cgi-bin/cgiip.exe/WService=ws_ayllos/';
	} else {
		$url_webspeed_ayllosweb = "https://iayllos.cecred.coop.br/cgi-bin/cgiip.exe/WService=ws_ayllos/";
	}
	
	// T�tulo do sistema
	$TituloSistema = ":: Sistema Aimaro ::";
	
	// T�tulo para p�gina de login
	$TituloLogin = "SISTEMA AIMARO";
	
	// Url do site
	$UrlSite = "https://ayllos.cecred.coop.br/";
	
	// Url para imagens
	$UrlImagens = "https://ayllos.cecred.coop.br/imagens/";
	
	// Url para Login 
	$UrlLogin = "http://intranet.cecred.coop.br/login_sistemas.php";
	
	// Servidor do GED (Selbetti)
	$GEDServidor = "ged.cecred.coop.br";	
	
	// Identificador dos grupos de usu�rios nas m�quinas HP-UX
	$gidNumbers[0] = 103; // Cecred
	$gidNumbers[1] = 902; // Desenvolvimento
	$gidNumbers[2] = 903; // Suporte
	$gidNumbers[3] = 905; // Admin
	
    // Variaveis para SOA
    $Url_SOA = "http://servicosinternos.cecred.coop.br";
    $Auth_SOA = "Basic YXlsbG9zOlBhJCQ0bGwwcy4yMDE4";
	
	// Identificador de pacotes ambientes nas m�quinas HP-UX
	$MTCCServers["pkgprod"]   = 1;
	$MTCCServers["pkgdesen"]  = 2;
	$MTCCServers["pkgprodsb"] = 3;
	$MTCCServers["pkghomol"]  = 4;
	$MTCCServers["pkgtreina"] = 5;
	$MTCCServers["pkglibera"] = 6;
	
	if ((strpos($UrlSite."index.php",$_SERVER["SCRIPT_NAME"]) === false && isset($_POST["sidlogin"])) || 		
	    (strpos($UrlSite."principal.php",$_SERVER["SCRIPT_NAME"]) !== false && isset($_SESSION["sidlogin"]))) { 		
		$sidlogin = isset($_POST["sidlogin"]) ? $_POST["sidlogin"] : $_SESSION["sidlogin"];		
		
		// Define como deve ser feito o redirecionamento no caso da sess�o expirar, ou ocorrer erro na leitura do XML, etc ...		
		$_SESSION["glbvars"][$sidlogin]["redirect"] = isset($_POST["redirect"]) ? $_POST["redirect"] : "html";
		
		// Eliminar vari�veis utilizadas para valida��o de permiss�o de acesso se existirem
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
	if ( preg_match('/^0303/', trim(SERVERNAMEAPP)) ) { // verifica o servidor
	// String para Sao Paulo
	define("HOST", "(DESCRIPTION =(ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = dbprdayllos.cecred.coop.br)(PORT = 1521))) (CONNECT_DATA =(SERVICE_NAME = HA-AYLLOSP) ))");
        } else {
	// String para Curitiba
        define("HOST", "(DESCRIPTION =(ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = dbprdayllos.cecred.coop.br)(PORT = 1521))) (CONNECT_DATA =(SERVICE_NAME = HA-AYLLOSP) ))");       
}	
 
	define("USERE", "YXlsbG9z");
	define("PASSE", "cGFkc29sbHlhdXN1MjAxNQ==");
    define("KEY"  , "50983417512346753284723840854609576043576094576059437609");
	define("IV"   , "12345678");

?>
