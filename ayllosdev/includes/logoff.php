<?php 
	
	//************************************************************************//
	//*** Fonte: logoff.php                                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   �ltima Altera��o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Sair do sistema                                      ***//
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//************************************************************************//
		
	session_start();
	
	// Includes para vari�veis globais de controle, e biblioteca de fun��es
	require_once("config.php");		
	
	// Se usu�rio estiver logado no sistema
	if (count($_SESSION["glbvars"]) > 1) {
		if (isset($_SESSION["glbvars"][$glbvars["sidlogin"]])) {
			unset($_SESSION["glbvars"][$glbvars["sidlogin"]]);
		}
	} else {	
		if (isset($_SESSION["glbvars"][$glbvars["sidlogin"]])) {
			session_destroy();
		}
	}
	
	echo '<script type="text/javascript">parent.window.location.href = "'.$UrlLogin.'";</script>';

?>