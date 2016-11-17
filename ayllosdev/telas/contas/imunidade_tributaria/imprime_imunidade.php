<?php 
 	
	//******************************************************************************************//
	//*** Fonte: imprime_imunidade.php                                            			 ***//
	//*** Autor: Lucas R.                                                   				 ***//
	//*** Data : Julho/2013                �ltima Altera��o: 				   				 ***//
	//***                                                                   				 ***//
	//*** Objetivo  : Imprimir os anexos 1, 2 e 3 da imunidade tributaria.     				 ***//	
	//***             							                               				 ***//	 
	//*** Altera��es: 20/09/2013 - Corrigindo os campos cddentid e cdsitcad                  ***//
    //***             para exibir os dados que vem da base e mostrar corretamente            ***//
    //***             na tela (Andr� Santos/ SUPERO)										 ***//								 ***//
	//***             			   										     				 ***//
	//***                          									         				 ***//
	//******************************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$cddentid = $_POST["cddentid"];
	
	// Monta o xml de requisi��o
	$xmlImpressao  = "";
	$xmlImpressao .= "<Root>";
	$xmlImpressao .= "	<Cabecalho>";
	$xmlImpressao .= "		<Bo>b1wgen0159.p</Bo>";
	$xmlImpressao .= "		<Proc>imprime-imunidade</Proc>";
	$xmlImpressao .= "	</Cabecalho>";
	$xmlImpressao .= "	<Dados>";
	$xmlImpressao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlImpressao .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlImpressao .= "		<cddentid>".$cddentid."</cddentid>";
	$xmlImpressao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";			
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