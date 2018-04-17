<?php 
 	
	//******************************************************************************************//
	//*** Fonte: imprime_bloqueio.php                                            				 ***//
	//*** Autor: Lucas R.                                                   				 ***//
	//*** Data : Junho/2013                Última Alteração: 				   				 ***//
	//***                                                                   				 ***//
	//*** Objetivo  : Imprimir os dados obtidos na consulta do Bloqueio.       				 ***//	
	//***             							                               				 ***//	 
	//*** Alterações: 																		 ***//
	//***             			   										     				 ***//
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
	
	$nroficon = $_POST["nroficon"];
	$nrctacon = $_POST["nrctacon"];
	$operacao = $_POST["operacao"];
	$cddopcao = $_POST["cddopcao"];
		
	// Monta o xml de requisição
	$xmlImpressao  = "";
	$xmlImpressao .= "<Root>";
	$xmlImpressao .= "	<Cabecalho>";
	$xmlImpressao .= "		<Bo>b1wgen0155.p</Bo>";
	$xmlImpressao .= "		<Proc>imprime_bloqueio_jud</Proc>";
	$xmlImpressao .= "	</Cabecalho>";
	$xmlImpressao .= "	<Dados>";
	$xmlImpressao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlImpressao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlImpressao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlImpressao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlImpressao .= "		<nroficon>".$nroficon."</nroficon>";
	$xmlImpressao .= "		<nrctacon>".$nrctacon."</nrctacon>";
	$xmlImpressao .= "		<operacao>".$operacao."</operacao>";
	$xmlImpressao .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xmlImpressao .= "	</Dados>";
	$xmlImpressao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlImpressao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjImpressao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjImpressao->roottag->tags[0]->name) == 'ERRO' ){
		$msg = $xmlObjImpressao->roottag->tags[0]->tags[0]->tags[4]->cdata;	
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	}
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjImpressao->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

?>