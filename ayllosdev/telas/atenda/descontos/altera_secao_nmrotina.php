<?php 

	/************************************************************************
	 Fonte: altera_secao_nmrotina.php                                             
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                �ltima Altera��o: 00/00/0000 
	                                                                  
	 Objetivo : Alterar o $glbvars["nmrotina"], quando usado o m�todo
				voltaDiv()
	                                                                  	 
	 Altera��es:                                                      
	************************************************************************/
	
	session_start();
	
	require_once("../../../includes/funcoes.php");
	
	isPostMethod();	
		
	$glbvars["nmrotina"] = $_POST["nmrotina"];
	
?>