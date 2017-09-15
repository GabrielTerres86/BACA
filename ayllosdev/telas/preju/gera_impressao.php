<?php 
	/**************************************************************************
	  Fonte: gera_impressao.php
	  Autor: James Prust Junior
	  Data : Setembro/2015                   Última Alteração:

	  Objetivo  : Gera o relatorio de estorno

	  Alterações:  
	 ************************************************************************* */
	session_cache_limiter("private");
	session_start();
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], "R")) <> "") {		
		exibeErro($msgError);
	}

	$nrdconta = str_ireplace(array('-','.'),'',$_POST["nrdconta"]);
	$nrctremp = str_ireplace(array('-','.'),'',$_POST['nrctremp']);
	$dtiniest = $_POST['dtiniest'];
	$dtfinest = $_POST['dtfinest'];
	$cdagenci = $_POST['cdagenci'];

	$xml  = '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtiniest>'.$dtiniest.'</dtiniest>';
	$xml .= '		<dtfinest>'.$dtfinest.'</dtfinest>';
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "ESTORN", "ESTORN_IMPRESSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObj = simplexml_load_string($xmlResult);
	// Se ocorrer um erro, mostra crítica
	if ($xmlObj->Erro->Registro->dscritic != ''){
		exibeErro($xmlObj->Erro->Registro->dscritic);
	}
	// Obtém nome do arquivo PDF 
	$nmarqpdf = $xmlObj;
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);	
	// Função para exibir erros na tela através de javascript
    function exibeErro($msgErro) { 
	  echo '<script>alert("'.$msgErro.'");</script>';	
	  exit();
    }
?>