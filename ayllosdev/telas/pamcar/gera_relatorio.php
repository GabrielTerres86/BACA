<?php 
 	
	//******************************************************************************************//
	//*** Fonte: gera_relatorio.php                                            				 ***//
	//*** Autor: David                                                      				 ***//
	//*** Data : Julho/2012                   Última Alteração: 30/10/2012   				 ***//
	//***                                                                   				 ***//
	//*** Objetivo  : Gerar relatorio de processamento                                       ***//	
	//*** Alterações: 30/10/2012 - Criados relatórios de Limite de Cheque Especial e 		 ***//
 	//***  						   Informações Cadastrais para a opção "R" (Lucas)           ***//
	//***						        													 ***//
	//***		      21/12/2012 - Incluso regra para não buscar nome arquivo via XML		 ***//
	//***						   quando 'copia_relatorio_processamento' (Daniel)           ***//   	
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
	
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R");
	
	if ($msgError <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}
		
	$nrdconta = $_POST["nrdconta"];
	$nmarqpdf = $_POST["nmarqpdf"];
	$dsiduser = session_id();	
	
	switch($nmarqpdf) {
		case 'chqespec': $procedure = 'gera-rel-cheque-especial';		break;
		case 'inforcad': $procedure = 'gera-rel-inf-cadastrais'; 		break;		
		default:   		 $procedure = 'copia_relatorio_processamento';  break;
	}
		
	// Monta o xml de requisição
	$xmlSolicitacao  = "";
	$xmlSolicitacao .= "<Root>";
	$xmlSolicitacao .= "	<Cabecalho>";
	$xmlSolicitacao .= "		<Bo>b1wgen0119.p</Bo>";	
	$xmlSolicitacao .= "		<Proc>".$procedure."</Proc>";
	$xmlSolicitacao .= "	</Cabecalho>";
	$xmlSolicitacao .= "	<Dados>";
	$xmlSolicitacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSolicitacao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";	
	$xmlSolicitacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";	
	$xmlSolicitacao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlSolicitacao .= "		<nmarquiv>".$nmarqpdf."</nmarquiv>";	
	$xmlSolicitacao .= "		<dsiduser>".$dsiduser."</dsiduser>";
	$xmlSolicitacao .= "	</Dados>";
	$xmlSolicitacao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSolicitacao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSolicitacao = getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitacao->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjSolicitacao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	}
	
	if ($procedure != 'copia_relatorio_processamento') {
		$nmarqpdf = $xmlObjSolicitacao->roottag->tags[0]->attributes["NMARQPDF"];
	}
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
?>