<?php 

	//*************************************************************************//
	//*** Fonte: aplicacoes_programadas_autorizacao_.php                    ***//
	//*** Autor: David                                                      ***//
	//*** Data : Mar�o/2010                   �ltima Altera��oo: 27/07/2018 ***//
	//***                                                                   ***//
	//*** Objetivo  : Emitir Autoriza��o de D�bito para Poupan�a Programada ***//
	//***                                                                   ***//	  
	//*** Altera��es: 12/07/2012 - Alterado parametro de $pdf->Output,      ***//  
	//***   					   Condicao para  Navegador Chrome (Jorge). ***// 
	//***                                                                   ***//
    //***             27/07/2018 - Deriva��o para Aplica��o Programada      ***//
	//***                          (Proj. 411.2 - CIS Corporate)            ***// 
	//***                                                                   ***//
	//*************************************************************************//
	
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrdrowid"]) || !isset($_POST["cdtiparq"])) {
		?><script language="javascript">alert('Par�metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$cdtiparq = $_POST["cdtiparq"];
	$nrctrrpp = $_POST["nrdrowid"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv�lida.');</script><?php
		exit();
	}
	
	// Verifica se indicador de proposta � um inteiro v�lido
	if (!validaInteiro($cdtiparq)) {
		?><script language="javascript">alert('Indicador de proposta inv�lido.');</script><?php
		exit();
	}	

	if (!validaInteiro($nrctrrpp)) {
		?><script language="javascript">alert('Indicador de contrato inv�lido.');</script><?php
		exit();
	}	

	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <idseqttl>1</idseqttl>";
	$xml .= "   <nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "   <flgerlog>0</flgerlog>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	$xmlResult = mensageria($xml, "APLI0008", "IMPRIME_TERMO_ADESAO_APL_PROG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjAutoriza = getObjectXML($xmlResult);


	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjAutoriza->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjAutoriza->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
		exit();		
	}			

	$nmarqpdf = $xmlObjAutoriza->roottag->tags[0]->tags[0]->tags[0]->cdata;
	
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
?>