<?php 

	/************************************************************************
	 Fonte: altera_secao_nmrotina.php                                             
	 Autor: Adriano                                                 
	 Data : Julho/2012                �ltima Altera��o: 00/00/0000 
	                                                                  
	 Objetivo : Alterar o $glbvars["nmrotina"], quando usado o m�todo
				voltaDiv()
	                                                                  	 
	 Altera��es:                                                      
	************************************************************************/
	
	session_start();
	
	require_once("../funcoes.php");
	
	isPostMethod();	
		
	$glbvars["nmrotina"] = $_POST["nmrotina"];
	
?>