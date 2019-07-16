<?
/*!
 * FONTE        : download_arquivo.php
 * CRIAÇÃO      : Christian Grauppe (ENVOLTI)
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Efetua o download do arquivo 
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */ 
?>
<? 
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

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST['opcao'])) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST['nmarquivo'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}

	// Recebe as variaveis
	$nmarquivo 	= $_POST['nmarquivo'];

	// Chama função para realizar o download do arquivo
	visualizaCSV($nmarquivo);
?>