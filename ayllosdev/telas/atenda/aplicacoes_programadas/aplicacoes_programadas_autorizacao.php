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
	$nrdrowid = $_POST["nrdrowid"];
	$cdtiparq = $_POST["cdtiparq"];

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
	
	// Monta o xml de requisi��o
	$xmlAutoriza  = "";
	$xmlAutoriza .= "<Root>";
	$xmlAutoriza .= "  <Cabecalho>";
	$xmlAutoriza .= "    <Bo>b1wgen0006.p</Bo>";
	$xmlAutoriza .= "    <Proc>obtem-dados-autorizacao</Proc>";
	$xmlAutoriza .= "  </Cabecalho>";
	$xmlAutoriza .= "  <Dados>";
	$xmlAutoriza .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAutoriza .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlAutoriza .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAutoriza .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAutoriza .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAutoriza .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlAutoriza .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlAutoriza .= "    <idseqttl>1</idseqttl>";
	$xmlAutoriza .= "    <nrdrowid>".$nrdrowid."</nrdrowid>";	
	$xmlAutoriza .= "    <cdtiparq>".$cdtiparq."</cdtiparq>";
	$xmlAutoriza .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlAutoriza .= "  </Dados>";
	$xmlAutoriza .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAutoriza);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAutoriza = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjAutoriza->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjAutoriza->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
		exit();		
	}			
	
	$xmlTagsAutorizacao = $xmlObjAutoriza->roottag->tags[0]->tags[0]->tags;
	
	for ($i = 0; $i < count($xmlTagsAutorizacao); $i++) {
		$dadosAutorizacao[$xmlTagsAutorizacao[$i]->name] = $xmlTagsAutorizacao[$i]->cdata;		
	}
	
	// Classe para gera��o da declara��o em PDF
	require_once("aplicacoes_programadas_autorizacao_pdf.php");

	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");
	
	// Inicia gera��o da autoriza��o
	$pdf->geraAutorizacao($dadosAutorizacao);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera sa�da do PDF para o Browser
	$pdf->Output("impressao.pdf",$tipo);	
	
?>