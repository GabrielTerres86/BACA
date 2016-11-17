<?php 
	
	//************************************************************************//
	//*** Fonte: controla_secao.php                                        ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   �ltima Altera��o: 01/08/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Controle de sess�o do sistema                        ***//
	//***                                                                  ***//	 
	//*** Altera��es: 01/08/2011 - Ajuste na verifica��o se session foi    ***//	
	//***                          iniciada (David).                       ***//
	//************************************************************************//	
	
	if ((!isset($glbvars["cdcooper"])) || ((strtotime("now") - $glbvars["hraction"]) > $glbvars["stimeout"])) {
		redirecionaErro($glbvars["redirect"],$UrlLogin,"_parent","Sua sess&atilde;o expirou. Efetue o login para acessar o sistema.");
		
		if ((count($_SESSION["glbvars"]) == 0) || (count($_SESSION["glbvars"]) == 1 && isset($_SESSION["glbvars"][$glbvars["sidlogin"]]))) {
			session_destroy();	
		} elseif (isset($_SESSION["glbvars"][$glbvars["sidlogin"]])) {
			unset($_SESSION["glbvars"][$glbvars["sidlogin"]]);
		}
		
		exit();	
	}	
	
	setVarSession("hraction",strtotime("now"));	
	
?>