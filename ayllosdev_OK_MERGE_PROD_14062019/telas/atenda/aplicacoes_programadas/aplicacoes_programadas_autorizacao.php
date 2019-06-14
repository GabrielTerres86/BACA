<?php 

	//*************************************************************************//
	//*** Fonte: aplicacoes_programadas_autorizacao_.php                    ***//
	//*** Autor: David                                                      ***//
	//*** Data : Março/2010                   Última Alteraçãoo: 27/07/2018 ***//
	//***                                                                   ***//
	//*** Objetivo  : Emitir Autorização de Débito para Poupança Programada ***//
	//***                                                                   ***//	  
	//*** Alterações: 12/07/2012 - Alterado parametro de $pdf->Output,      ***//  
	//***   					   Condicao para  Navegador Chrome (Jorge). ***// 
	//***                                                                   ***//
    //***             27/07/2018 - Derivação para Aplicação Programada      ***//
	//***                          (Proj. 411.2 - CIS Corporate)            ***// 
	//***                                                                   ***//
	//*************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrdrowid"]) || !isset($_POST["cdtiparq"])) {
		?><script language="javascript">alert('Parâmetros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$cdtiparq = $_POST["cdtiparq"];
	$nrctrrpp = $_POST["nrdrowid"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inválida.');</script><?php
		exit();
	}
	
	// Verifica se indicador de proposta é um inteiro válido
	if (!validaInteiro($cdtiparq)) {
		?><script language="javascript">alert('Indicador de proposta inválido.');</script><?php
		exit();
	}	

	if (!validaInteiro($nrctrrpp)) {
		?><script language="javascript">alert('Indicador de contrato inválido.');</script><?php
		exit();
	}	

	// Monta o xml de requisição
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


	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAutoriza->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjAutoriza->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
		exit();		
	}			
	
	$nmarqpdf = $xmlObjAutoriza->roottag->tags[0]->tags[0]->tags[0]->cdata;

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
?>
