<?php

/***********************************************************************
  Fonte: imprimir_carta_anuencia.php                                              
  Autor: Hélinton Steffens                                                  
  Data : Fevereiro/2018                       última Alteração: - 		   
	                                                                   
  Objetivo  : Gerar o PDF do termo da rotina de COBRANCA da ATENDA.              
	                                                                 
  Alterações: 
  
***********************************************************************/
	session_cache_limiter("private");
	session_start();
		
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Verifica Permissões
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0;
	$cdbancoc = (isset($_POST['cdbandoc'])) ? $_POST['cdbandoc'] : 0;
	$dtcatanu = (isset($_POST['dtcatanu'])) ? $_POST['dtcatanu'] : '';
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrdocmto>".$nrdocmto."</nrdocmto>";
	$xml .= "   <cdbancoc>".$cdbancoc."</cdbancoc>";
	$xml .= "   <dtcatanu>".$dtcatanu."</dtcatanu>";
	$xml .= "   <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// craprdr / crapaca 
	$xmlResult = mensageria($xml, "COBRAN", "RELAT_CARTA_ANUENCIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra critica
	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->cdata);		 
	}

	//Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	//$nmarqpdf = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	$nmarqpdf = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	visualizaPDF($nmarqpdf);


	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
	echo '<script>alert("'.$msgErro.'");</script>';	
	exit();
	}
 
?>