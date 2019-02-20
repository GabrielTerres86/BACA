<?php

/***********************************************************************
  Fonte: imprimir_carta_anuencia.php                                              
  Autor: Hélinton Steffens                                                  
  Data : Fevereiro/2018                       última Alteração: - 		   
	                                                                   
  Objetivo  : Gerar o PDF do termo da rotina de COBRANCA da ATENDA.              
	                                                                 
  Alterações: 07/02/2019 - Retirado controle de permissoes na impressao 
                           da carta de anuencia (P352 - Cechet)
  
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

	$nrdconta = ( isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrdocmto = ( isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0;
	$cdbancoc = ( isset($_POST['cdbandoc'])) ? $_POST['cdbandoc'] : 0;
	$dtcatanu = ( isset($_POST['dtcatanu'])) ? $_POST['dtcatanu'] : '';
	$nmrepres = (!empty($_POST['nmrepres'])) ? $_POST['nmrepres'] : '';
	
	if ($nmrepres) {
		$nmrepres = 'neste ato representado(a) pelo(s) sócio(s) ' . $nmrepres;
	}
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrdocmto>".$nrdocmto."</nrdocmto>";
	$xml .= "   <cdbancoc>".$cdbancoc."</cdbancoc>";
	$xml .= "   <dtcatanu>".$dtcatanu."</dtcatanu>";
	$xml .= "   <nmrepres>".$nmrepres."</nmrepres>";
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