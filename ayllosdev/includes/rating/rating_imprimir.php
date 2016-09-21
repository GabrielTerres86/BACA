<?php 

	//************************************************************************//
	//*** Fonte: rating_imprimir.php                                       ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2010                   �ltima Altera��o: 12/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Imprimir par�metros do rating do cooperado           ***//	
	//***                                                                  ***//
	//*** Altera��es: 07/04/2011 - Incluido dados do Risco_Cooperado       ***//	
	//***						   (Adriano).							   ***//
	//***																   ***//
	//***   		  12/07/2012 - Alterado parametro de $pdf->Output,     ***//  
	//***   					   Condicao para  Navegador Chrome (Jorge).***//	
	//************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../config.php");
	require_once("../funcoes.php");		
	require_once("../controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (!isset($glbvars["dadosImpressaoRatingEfetivo"]) && !isset($glbvars["dadosImpressaoRating"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();		
	}			
	
	// Verifica se os dados armazenados s�o de um rating efetivado
	$dsIndice = isset($glbvars["dadosImpressaoRatingEfetivo"]) ? "dadosImpressaoRatingEfetivo" : "dadosImpressaoRating";
	
	$relatorio  = $glbvars[$dsIndice]["RELATORIO"];
	$cooperado  = $glbvars[$dsIndice]["COOPERADO"];
	$rating     = $glbvars[$dsIndice]["RATING"];
	$risco      = $glbvars[$dsIndice]["RISCO"];
	$assinatura = $glbvars[$dsIndice]["ASSINATURA"];
	$efetivacao = $glbvars[$dsIndice]["EFETIVACAO"];	
    $risco_cooperado = $glbvars[$dsIndice]["RISCO_COOPERADO"];
	
		
	// Classe para gera��o do rating em PDF
	require_once("rating_imprimir_pdf.php");
	
	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");
	
	
	// Inicia gera��o do impresso
	$pdf->geraRating($relatorio,$cooperado,$rating,$risco,$assinatura,$efetivacao, $risco_cooperado);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera sa�da do PDF para o Browser
	$pdf->Output("rating.pdf",$tipo);	
	
	
	
?>