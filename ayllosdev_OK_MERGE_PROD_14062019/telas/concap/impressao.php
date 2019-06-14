<?php 
/*!
 * FONTE      : impressao.php                                        
 * AUTOR      : Lucas R                                                   
 * DATA       : Novembro/2013                																  
 * OBJETIVO   : Imprimir dados da CONCAP.
 *--------------------
 * ALTERAC��ES:    
 * 001: 29/01/2014 - Ajustar conte�do da tag nmendter (David)
 *--------------------											   
 */		
 
	
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
	
	// Verifica permiss�o
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I");
	
	$cddopcao = $_POST["cddopcao"];
	$cdagenci = $_POST["cdagenci"];
	$dtmvtolt = $_POST["dtmvtolt"];
	$opcaoimp = $_POST["opcaoimp"];
			
	// Monta o xml de requisi��o
	$xmlImpressao  = "";
	$xmlImpressao .= "<Root>";
	$xmlImpressao .= "	<Cabecalho>";
	$xmlImpressao .= "		<Bo>b1wgen0180.p</Bo>";
	$xmlImpressao .= "		<Proc>imprime-captacao</Proc>";
	$xmlImpressao .= "	</Cabecalho>";
	$xmlImpressao .= "	<Dados>";
	$xmlImpressao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlImpressao .= "		<cdagenci>".$cdagenci."</cdagenci>";
	$xmlImpressao .= "		<dtmvtolt>".$dtmvtolt."</dtmvtolt>";
	$xmlImpressao .= "		<opcaoimp>".$opcaoimp."</opcaoimp>";
	$xmlImpressao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlImpressao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlImpressao .= "		<cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
	$xmlImpressao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlImpressao .= "		<nmendter>".$glbvars["sidlogin"]."</nmendter>";
	$xmlImpressao .= "	</Dados>";
	$xmlImpressao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlImpressao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjImpressao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjImpressao->roottag->tags[0]->name) == 'ERRO' ){
		$msg = $xmlObjImpressao->roottag->tags[0]->tags[0]->tags[4]->cdata;	
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	}
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjImpressao->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

?>