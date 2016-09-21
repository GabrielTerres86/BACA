<?php 
	
	//*******************************************************************************************************************//
	//*** Fonte: limpa_cheque_temp.php                                                                                ***//
	//*** Autor: Jorge Issamu Hamaguchi                                                                               ***//
	//*** Data : Maio/2015                   �ltima Altera��o: 00/00/0000                                             ***//
	//***                                                                                                             ***//
	//*** Objetivo  : Apagar imagens de cheques em diretorio temp.                                                    ***//
	//***            												                                                  ***//	
	//***                                                                                                             ***//	 
	//*** Altera��es: 													                                              ***//
	//*******************************************************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
		
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");		
		
	$dsfrente = $_POST["dsfrente"];
	$dsdverso = $_POST["dsdverso"];
	
	unlink($dsfrente);
	unlink($dsdverso);
	
?>
