<?php 
	
	//*****************************************************************************************************//
	//*** Fonte: logoff.php																				***//
	//*** Autor: David																					***//
	//*** Data : Julho/2007                   �ltima Altera��o: 21/07/2016								***//
	//***																								***//
	//*** Objetivo  : Sair do sistema																	***//
	//***																								***//	 
	//*** Altera��es: 21/07/2016 - Validacao da existencia do indice sidlogin. SD 479874. (Carlos R.)   ***//
	//*****************************************************************************************************//
		
	session_start();
	
	// Includes para vari�veis globais de controle, e biblioteca de fun��es
	require_once("config.php");		
	
	// Se usu�rio estiver logado no sistema
	if (count($_SESSION["glbvars"]) > 1) {
		if (isset($glbvars["sidlogin"]) && isset($_SESSION["glbvars"][$glbvars["sidlogin"]])) {
			unset($_SESSION["glbvars"][$glbvars["sidlogin"]]);
		}
	} else {	
		if (isset($glbvars["sidlogin"]) && isset($_SESSION["glbvars"][$glbvars["sidlogin"]])) {
			session_destroy();
		}
	}
	
	echo '<script type="text/javascript">parent.window.location.href = "'.$UrlLogin.'";</script>';

?>