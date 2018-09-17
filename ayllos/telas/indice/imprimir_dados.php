<?php
	/*!
	 * FONTE        : imprimir_dados.php
	 * CRIA��O      : Jean Michel Deschamps
	 * DATA CRIA��O : 11/07/2014
	 * OBJETIVO     : Carregar dados para impress�es do INDICE
	 * --------------
	 * ALTERA��ES   : 
	 * -------------- 
	 */ 

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
	
	$nmarqpdf = $_POST['nmarquiv'];

	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
?>