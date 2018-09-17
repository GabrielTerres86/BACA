<?
/*
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Gabriel
 * DATA CRIAÇÃO : 04/10/2011 
 * OBJETIVO     : Rotina para impressao da CMEDEP
 * --------------
 * ALTERAÇÕES   : 11/07/2012 - Adicionado exclusão de arquivo caso "no" em impressao. (David - Jorge)
 * -------------- 
 */
    session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
					
	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["nmarqpdf"]) || !isset($_POST["flgimpre"])) {
		?><script language="javascript">alert('Parametros incorretos.');</script><?php
		exit();
	}	

	$nmarqpdf = $_POST["nmarqpdf"];
	$flgimpre = $_POST["flgimpre"];
		
	if ($flgimpre == "yes") {
		visualizaPDF($nmarqpdf);
	} else {
		$nmarqpdf  = "/var/www/ayllos/documentos/".$glbvars["dsdircop"]."/temp/".$nmarqpdf;
		unlink($nmarqpdf);
	}

?>