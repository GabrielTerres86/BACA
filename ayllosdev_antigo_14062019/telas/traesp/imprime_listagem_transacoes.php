<?php 
	//******************************************************************************************//
	//*** Fonte: imprime_listagem_transacoes.php                            				 ***//
	//*** Autor: Fabrício                                                   				 ***//
	//*** Data : Abril/2012                Última Alteração: 06/07/2012 	   				 ***//
	//***                                                                   				 ***//
	//*** Objetivo  : Imprimir listagem com as transacoes em especie	       				 ***//	
	//***             							                               				 ***//	 
	//*** Alterações: 06/07/2012 - Adicionado confirmacao para impressao e retirado var post ***//
	//***                          imprimir (Jorge)					         				 ***//
	//******************************************************************************************//
	
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
	
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S");
	
	$nmarqpdf = $_POST["nmarqpdf"];
	
	// Monta o xml de requisição
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
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjListagem->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjListagem->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjListagem->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
	
?>