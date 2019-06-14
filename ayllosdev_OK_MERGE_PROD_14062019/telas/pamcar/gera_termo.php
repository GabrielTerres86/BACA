<?php 
 	
	//******************************************************************************************//
	//*** Fonte: gera_termo.php                                              				 ***//
	//*** Autor: Fabrício                                                   				 ***//
	//*** Data : Janeiro/2012                Última Alteração: 06/07/2012   				 ***//
	//***                                                                   				 ***//
	//*** Objetivo  : Gerar termo de adesao ou cancelamento, do cartao       				 ***//	
	//***             transportadora PAMCARD.                               				 ***//	 
	//*** Alterações: 03/02/2012 - Incluido o parametro dtmvtolt na chamada  				 ***//
	//***                          das procedure gera_termo_adesao, gera_termo_cancelamento. ***//
	//***						   (Adriano).						         				 ***//
	//***             													     				 ***//
	//***			  06/07/2012 - Retirado var post imprimir (Jorge).     					 ***//
	//***						        													 ***//
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
	
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H");
	
	if ($msgError <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}
		
	$flgpamca = $_POST["flgpamca"];
	$nrdconta = $_POST["nrdconta"];
	$nmarqpdf = $_POST["nmarqpdf"];
		
	// Monta o xml de requisição
	$xmlSolicitacao  = "";
	$xmlSolicitacao .= "<Root>";
	$xmlSolicitacao .= "	<Cabecalho>";
	$xmlSolicitacao .= "		<Bo>b1wgen0119.p</Bo>";
	
	if ($flgpamca == "S")
		$xmlSolicitacao .= "		<Proc>gera_termo_adesao</Proc>";
	else
		$xmlSolicitacao .= "		<Proc>gera_termo_cancelamento</Proc>";
	
	$xmlSolicitacao .= "	</Cabecalho>";
	$xmlSolicitacao .= "	<Dados>";
	$xmlSolicitacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSolicitacao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";	
	$xmlSolicitacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";	
	$xmlSolicitacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSolicitacao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitacao .= "	</Dados>";
	$xmlSolicitacao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSolicitacao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSolicitacao = getObjectXML($xmlResult);
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjSolicitacao->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitacao->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjSolicitacao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	}
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
?>