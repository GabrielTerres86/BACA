<?php 

	/************************************************************************
	 Fonte: altera_secao_nmrotina.php                                             
	 Autor: Adriano                                                 
	 Data : Junho/2013                Última Alteração: 08/10/2018
	                                                                  
	 Objetivo : Alterar o $glbvars["nmrotina"]
	                                                                  	 
	 Alterações: 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
   
               08/10/2018 - Incluido o session_start para controla corretamente as variáveis de sessão (Jonata - Mouts / INC0024641).
                       
	************************************************************************/
	
  session_start();
  
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	
	isPostMethod();	
	
	setVarSession("nmrotina",$_POST["nmrotina"]);
	
?>