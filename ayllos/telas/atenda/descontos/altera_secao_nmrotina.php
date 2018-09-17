<?php 

	/************************************************************************
	 Fonte: altera_secao_nmrotina.php                                             
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                кltima Alteraчуo: 00/00/0000 
	                                                                  
	 Objetivo : Alterar o $glbvars["nmrotina"], quando usado o mщtodo
				voltaDiv()
	                                                                  	 
	 Alteraчѕes:                                                      
	************************************************************************/
	
	session_start();
	
	require_once("../../../includes/funcoes.php");
	
	isPostMethod();	
		
	$glbvars["nmrotina"] = $_POST["nmrotina"];
	
?>