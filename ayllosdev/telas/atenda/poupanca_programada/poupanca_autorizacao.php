<?php 

	//*************************************************************************//
	//*** Fonte: impressao_declaracao_recebimento.php                       ***//
	//*** Autor: David                                                      ***//
	//*** Data : Março/2010                   Última Alteraçãoo: 12/07/2012 ***//
	//***                                                                   ***//
	//*** Objetivo  : Emitir Autorização de Débito para Poupança Programada ***//
	//***                                                                   ***//	  
	//*** Alterações: 12/07/2012 - Alterado parametro de $pdf->Output,      ***//  
	//***   					   Condicao para  Navegador Chrome (Jorge). ***// 
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
	$nrdrowid = $_POST["nrdrowid"];
	$cdtiparq = $_POST["cdtiparq"];

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
	
	// Monta o xml de requisição
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAutoriza->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjAutoriza->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
		exit();		
	}			
	
	$xmlTagsAutorizacao = $xmlObjAutoriza->roottag->tags[0]->tags[0]->tags;
	
	for ($i = 0; $i < count($xmlTagsAutorizacao); $i++) {
		$dadosAutorizacao[$xmlTagsAutorizacao[$i]->name] = $xmlTagsAutorizacao[$i]->cdata;		
	}
	
	// Classe para geração da declaração em PDF
	require_once("poupanca_autorizacao_pdf.php");

	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");
	
	// Inicia geração da autorização
	$pdf->geraAutorizacao($dadosAutorizacao);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera saída do PDF para o Browser
	$pdf->Output("impressao.pdf",$tipo);	
	
?>