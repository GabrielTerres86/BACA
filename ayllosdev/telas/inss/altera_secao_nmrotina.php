<?php 

	/************************************************************************
	 Fonte: altera_secao_nmrotina.php                                             
	 Autor: Adriano                                                 
	 Data : Junho/2013                �ltima Altera��o: 00/00/0000 
	                                                                  
	 Objetivo : Alterar o $glbvars["nmrotina"]
	                                                                  	 
	 Altera��es:                                                      
	************************************************************************/
	
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	
	isPostMethod();	
	
	setVarSession("nmrotina",$_POST["nmrotina"]);
	
?>