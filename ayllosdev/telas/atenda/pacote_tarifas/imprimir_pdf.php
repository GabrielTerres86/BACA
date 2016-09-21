<?php
	/*!
	 * FONTE        : imprimir_pdf.php
	 * CRIA��O      : Lucas Afonso Lombardi Moreira
	 * DATA CRIA��O : Abril/2016
	 * OBJETIVO     : Carregar dados para impress�o do PDF
	 * --------------
	 * ALTERA��ES   : 
	 * -------------- 
	 */ 

	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$nmarqpdf = $_POST['nmarquiv'];

	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
?>