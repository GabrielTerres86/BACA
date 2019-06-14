<?php 
 	
	//******************************************************************************************//
	//*** Fonte: imprime_icf.php                                            				 ***//
	//*** Autor: Fabr�cio                                                   				 ***//
	//*** Data : Mar�o/2013                �ltima Altera��o: 				   				 ***//
	//***                                                                   				 ***//
	//*** Objetivo  : Imprimir os dados obtidos na consulta do ICF. 	       				 ***//	
	//***             							                               				 ***//	 
	//*** Altera��es: 																		 ***//
	//***             			   										     				 ***//
	//***                          									         				 ***//
	//******************************************************************************************//
	
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
	
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C");
		
	$dtinireq = $_POST["dtinireq"];
	$intipreq = $_POST["intipreq"];
	$cdbanreq = $_POST["cdbanreq"];
	$cdagereq = $_POST["cdagereq"];
	$nrctareq = $_POST["nrctareq"];
	$camposPc = $_POST["camposPc"];
	$dadosPrc = $_POST["dadosPrc"];
	
	// Monta o xml de requisi��o
	$xmlImpressao  = "";
	$xmlImpressao .= "<Root>";
	$xmlImpressao .= "	<Cabecalho>";
	$xmlImpressao .= "		<Bo>b1wgen0154.p</Bo>";
	$xmlImpressao .= "		<Proc>imprime-icf</Proc>";
	$xmlImpressao .= "	</Cabecalho>";
	$xmlImpressao .= "	<Dados>";
	$xmlImpressao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlImpressao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlImpressao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlImpressao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlImpressao .= "		<dtinireq>".$dtinireq."</dtinireq>";
	$xmlImpressao .= "		<intipreq>".$intipreq."</intipreq>";
	$xmlImpressao .= "		<cdbanreq>".$cdbanreq."</cdbanreq>";
	$xmlImpressao .= "		<cdagereq>".$cdagereq."</cdagereq>";
	$xmlImpressao .= "		<nrctareq>".$nrctareq."</nrctareq>";
	$xmlImpressao .= retornaXmlFilhos( $camposPc, $dadosPrc, 'DadosICF', 'Itens');
	$xmlImpressao .= "	</Dados>";
	$xmlImpressao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlImpressao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjImpressao = getObjectXML($xmlResult);
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjImpressao->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjImpressao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjImpressao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
	
?>