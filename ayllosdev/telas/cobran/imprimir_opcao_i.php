<?
/*!
 * FONTE        : imprimir_opcao_i.php
 * CRIA��O      : Rog�rius Milit�o (DB1)
 * DATA CRIA��O : 28/02/2012
 * OBJETIVO     : Faz as impress�es da tela COBRAN	
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */
?>

<? 
	
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST['cddopcao'])) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $_POST['nmarqpdf'];
	
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
?>