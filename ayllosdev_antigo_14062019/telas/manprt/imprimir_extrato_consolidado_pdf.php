<?php

/***********************************************************************
  Fonte: imprimir_consulta_ted_csv.php                                              
  Autor: H�linton Steffens                                                  
  Data : Mar�o/2018                       �ltima Altera��o: - 		   
	                                                                   
  Objetivo  : Gerar o CSV dos titulos.              
	                                                                 
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
	
	$cdcooper = $glbvars["cdcooper"];
	$dtinimvt = ((!empty($_POST['dtinimvt'])) ? $_POST['dtinimvt'] : null);
	$dtfimmvt = ((!empty($_POST['dtfimmvt'])) ? $_POST['dtfimmvt'] : null);

	// Verifica Permiss�es
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "   <dtinimvt>".$dtinimvt."</dtinimvt>";
	$xml .= "   <dtfimmvt>".$dtfimmvt."</dtfimmvt>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_MANPRT", "EXP_EXTRATO_CONSOLIDADO_PDF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra critica
	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);		 
	}

	$nmarqcsv = $xmlObjeto->roottag->cdata;
	visualizaPDF($nmarqcsv);

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
	    echo '<script>alert("'.$msgErro.'");</script>';	
	    exit();
	}
 
?>