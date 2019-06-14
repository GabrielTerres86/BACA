<?php 
	//******************************************************************************************//
	//*** Fonte: reimprime_controle_movimentacao.php                          				 ***//
	//*** Autor: Fabrício                                                   				 ***//
	//*** Data : Abril/2012                Última Alteração: 06/07/2012		   				 ***//
	//***                                                                   				 ***//
	//*** Objetivo  : Reimprimir controle de movimentacao em especie	       				 ***//	
	//***             							                               				 ***//	 
	//*** Alterações: 06/07/2012 - Adicionado confirmacao para impressao e retirado var post ***//
	//***             			   imprimir (Jorge).					     				 ***//
	//***                          									         				 ***//
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
	
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I");
		
	$dtmvtolt = $_POST["dtmvtolt"];
	$cdagenci = $_POST["cdagenci"];
	$cdbccxlt = $_POST["cdbccxlt"];
	$nrdolote = $_POST["nrdolote"];
	$nrdocmto = $_POST["nrdocmto"];
	$nmrescop = $_POST["nmrescop"];
	$cdopecxa = $_POST["cdopecxa"];
	$nrdcaixa = $_POST["nrdcaixa"];
	$nrseqaut = $_POST["nrseqaut"];
	$nrdctabb = $_POST["nrdctabb"];
	$tpoperac = $_POST["tpoperac"];
	$imprimir = $_POST["imprimir"];
	$nmarqpdf = $_POST["nmarqpdf"];
	
	// Monta o xml de requisição
	$xmlReimpressao  = "";
	$xmlReimpressao .= "<Root>";
	$xmlReimpressao .= "	<Cabecalho>";
	$xmlReimpressao .= "		<Bo>b1wgen0135.p</Bo>";
	$xmlReimpressao .= "		<Proc>reimprime-controle-movimentacao</Proc>";
	$xmlReimpressao .= "	</Cabecalho>";
	$xmlReimpressao .= "	<Dados>";
	$xmlReimpressao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlReimpressao .= "		<nmrescop>".$nmrescop."</nmrescop>";
	$xmlReimpressao .= "		<cdagenci>".$cdagenci."</cdagenci>";	
	$xmlReimpressao .= "		<nrdcaixa>".$nrdcaixa."</nrdcaixa>";	
	$xmlReimpressao .= "		<cdopecxa>".$cdopecxa."</cdopecxa>";
	$xmlReimpressao .= "		<dttransa>".$dtmvtolt."</dttransa>";
	$xmlReimpressao .= "		<cdbccxlt>".$cdbccxlt."</cdbccxlt>";
	$xmlReimpressao .= "		<nrdolote>".$nrdolote."</nrdolote>";
	$xmlReimpressao .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";
	$xmlReimpressao .= "		<tpdocmto>".$tpdocmto."</tpdocmto>";
	$xmlReimpressao .= "		<nrseqaut>".$nrseqaut."</nrseqaut>";
	$xmlReimpressao .= "		<nrdctabb>".$nrdctabb."</nrdctabb>";
	$xmlReimpressao .= "		<tpoperac>".$tpoperac."</tpoperac>";
	$xmlReimpressao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlReimpressao .= "	</Dados>";
	$xmlReimpressao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlReimpressao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjReimpressao = getObjectXML($xmlResult);
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjReimpressao->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjReimpressao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjReimpressao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
	
?>