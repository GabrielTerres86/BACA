<?
/*!
 * FONTE        : Imprimir_opcaoT.php
 * CRIA��O      : LUCAS R. (CECRED)
 * DATA CRIA��O : 18/04/2013
 * OBJETIVO     : Faz as impress�o da opc�o T da tela BCAIXA.
 * --------------
 * ALTERA��ES   : 24/09/2013 - Carlos   (CECRED) : Inclus�o da data na procedure imprime_caixa_cofre.
 * -------------- 
 *				  24/01/2017 - Retirar valida��o de permiss�o pois n�o estava utilizando (Lucas Ranghetti #572241).
 *                
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

	// Recebe as variaveis
	$dsiduser 	= session_id();	
	$tpcaicof   = $_POST['tpcaicof'];	
	$cdagenci   = $_POST['cdagenci'];
	$dtrefere   = $_POST['dtmvtolt'];

	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0120.p</Bo>';
	$xml .= '		<Proc>imprime_caixa_cofre</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
	$xml .= '		<dtrefere>'.$dtrefere.'</dtrefere>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';	
	$xml .= '		<cdprogra>BCAIXA</cdprogra>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<tpcaicof>'.$tpcaicof.'</tpcaicof>';
	$xml .= '	</Dados>';  	
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
	?><?php
		// Se ocorrer um erro, mostra cr�tica 
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];	
	
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

?> 