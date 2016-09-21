<?php 
	//******************************************************************************************//
	//*** Fonte: imprime_listagem_transacoes.php                            				 ***//
	//*** Autor: Fabr�cio                                                   				 ***//
	//*** Data : Abril/2012                �ltima Altera��o: 06/07/2012 	   				 ***//
	//***                                                                   				 ***//
	//*** Objetivo  : Imprimir listagem com as transacoes em especie	       				 ***//	
	//***             							                               				 ***//	 
	//*** Altera��es: 06/07/2012 - Adicionado confirmacao para impressao e retirado var post ***//
	//***                          imprimir (Jorge)					         				 ***//
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
	
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S");
	
	$nmarqpdf = $_POST["nmarqpdf"];
	
	// Monta o xml de requisi��o
	$xmlListagem  = "";
	$xmlListagem .= "<Root>";
	$xmlListagem .= "	<Cabecalho>";
	$xmlListagem .= "		<Bo>b1wgen0135.p</Bo>";
	$xmlListagem .= "		<Proc>imprime-listagem-transacoes</Proc>";
	$xmlListagem .= "	</Cabecalho>";
	$xmlListagem .= "	<Dados>";
	$xmlListagem .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlListagem .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";	
	$xmlListagem .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";	
	$xmlListagem .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlListagem .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlListagem .= "	</Dados>";
	$xmlListagem .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlListagem);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjListagem = getObjectXML($xmlResult);
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjListagem->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjListagem->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjListagem->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
	
?>