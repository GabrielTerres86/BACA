<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Andrei - RKAM                                                     
	 Data : Maio/2016                Última Alteração: 11/04/2017
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da GRAVAM.                                  
	                                                                  
	 Alterações: 11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
	
	**********************************************************************/
  
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
  
?>