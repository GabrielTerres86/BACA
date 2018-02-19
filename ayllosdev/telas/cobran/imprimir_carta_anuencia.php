<?php

/***********************************************************************
  Fonte: imprimir_carta_anuencia.php                                              
  Autor: Hélinton Steffens                                                  
  Data : Fevereiro/2018                       �ltima Altera��o: - 		   
	                                                                   
  Objetivo  : Gerar o PDF do termo da rotina de COBRANCA da ATENDA.              
	                                                                 
  Altera��es: 
  
***********************************************************************/
	session_cache_limiter("private");
	session_start();
		
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();

	// Verifica Permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0;
	$cdbancoc = (isset($_POST['cdbandoc'])) ? $_POST['cdbandoc'] : 0;


	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrdocmto>".$nrdocmto."</nrdocmto>";
	$xml .= "   <cdbancoc>".$cdbancoc."</cdbancoc>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// craprdr / crapaca 
	$xmlResult = mensageria($xml, "COBRAN", "RELAT_CARTA_ANUENCIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->cdata);		 
	}

	//Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	//$nmarqpdf = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	$nmarqpdf = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	visualizaPDF($nmarqpdf);


	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
	echo '<script>alert("'.$msgErro.'");</script>';	
	exit();
	}
 
?>