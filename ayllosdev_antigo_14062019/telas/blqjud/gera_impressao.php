<?php


	/************************************************************************
	 Fonte: gera_impressao.php                                       
	 Autor: Lucas R                                                   
	 Data : Junho/2013                 Ultima Alteracao: //           
	                                                                  
	 Objetivo  : Imprimir bloqueio judicial da opcao R                     
	                                                                  
	 Alteracoes: 													   	
	
	************************************************************************/
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");	
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Recebe as variaveis
	$dtinicio = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '';
	$dtafinal = (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : '';
	$agenctel = (isset($_POST['agenctel'])) ? $_POST['agenctel'] : 0;
	
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0155.p</Bo>";
	$xml .= "		<Proc>Gera_Impressao</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; 
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<dtinicio>".$dtinicio."</dtinicio>";
	$xml .= "		<dtafinal>".$dtafinal."</dtafinal>";
	$xml .= "		<agenctel>".$agenctel."</agenctel>";
	$xml .= "	</Dados>";  
	$xml .= "</Root>";
	
		// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjImpressao = getObjectXML($xmlResult);
		
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

