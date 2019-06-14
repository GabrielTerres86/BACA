<?php 

	/************************************************************************
	 Fonte: principal_agendamento.php                                             
	 Autor: Douglas
	 Data : Setembro/2014                Última Alteração:
	                                                                  
	 Objetivo  : Mostrar opcao Principal da rotina de Agendamento das
	             aplicações
	                                                                  	 
	 Alterações: 

	************************************************************************/
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") {
		exibeErro($msgError);		
	}	

	// Verifica se número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Monta o xml de requisição
	$xmlGetAgendamento  = "";
	$xmlGetAgendamento .= "<Root>";
	$xmlGetAgendamento .= "	<Cabecalho>";
	$xmlGetAgendamento .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetAgendamento .= "		<Proc>consulta-agendamento</Proc>";
	$xmlGetAgendamento .= "	</Cabecalho>";
	$xmlGetAgendamento .= "	<Dados>";
	$xmlGetAgendamento .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetAgendamento .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetAgendamento .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetAgendamento .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetAgendamento .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetAgendamento .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetAgendamento .= "		<idseqttl>1</idseqttl>";
	$xmlGetAgendamento .= "		<nraplica>0</nraplica>";
	$xmlGetAgendamento .= "		<flgtipar>2</flgtipar>"; // 2 - Todos os agendamento
	$xmlGetAgendamento .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
	$xmlGetAgendamento .= "	</Dados>";
	$xmlGetAgendamento .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAgendamento);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAgendamentos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAgendamentos->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAgendamentos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$agendamentos   = $xmlObjAgendamentos->roottag->tags[0]->tags;	
	$qtAgendamentos = count($agendamentos);

	include('agendamento_tabela.php');
?>