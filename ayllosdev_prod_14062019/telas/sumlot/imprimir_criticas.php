<?
/*!
 * FONTE        : imprimir_criticas.php
 * CRIA��O      : Rog�rius Milit�o (DB1)
 * DATA CRIA��O : 27/10/2011
 * OBJETIVO     : Carregar as criticas da tela SUMLOT
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

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se par�metros necess�rios foram informados
	if (!isset($_POST['nmarqpdf'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	
	
	// Recebe as variaveis
	$nmarqpdf 	= $_POST['nmarqpdf'];

	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	

?>