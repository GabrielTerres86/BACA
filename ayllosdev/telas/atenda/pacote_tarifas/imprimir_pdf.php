<?php
	/*!
	 * FONTE        : imprimir_pdf.php
	 * CRIAÇÃO      : Lucas Afonso Lombardi Moreira
	 * DATA CRIAÇÃO : Abril/2016
	 * OBJETIVO     : Carregar dados para impressão do PDF
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */ 

	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$nmarqpdf = $_POST['nmarquiv'];

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
?>