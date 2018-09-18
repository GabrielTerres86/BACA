<?php 

	/*********************************************************************************
	 Fonte: agendamento_validar.php
	 Autor: Douglas Quisinski
	 Data : Outubro/2014                 Última Alteração: 05/04/2018
	 
	 Objetivo  : Validar o agendamento de aplicação e resgate
	 
	 Alterações: 21/07/2016 - Corrigi a forma de validacao do retorno XML"ERRO".SD 479874 (Carlos R.)
	 
	             05/04/2018 - Chamada da rotina para verificar o range permitido para 
				              contratação do produto. PRJ366 (Lombardi).
							  
	             14/05/2018 - Ajustes no codigo e valor de contratacao do produto.
				              PRJ366 (Lombardi).
							  
	********************************************************************************/
	
	include('agendamento_validar_parametros.php');
	
	// Monta o xml de requisição
	$xmlAgendamento  = "";
	$xmlAgendamento .= "<Root>";
	$xmlAgendamento .= "	<Cabecalho>";
	$xmlAgendamento .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlAgendamento .= "		<Proc>validar-novo-agendamento</Proc>";
	$xmlAgendamento .= "	</Cabecalho>";
	$xmlAgendamento .= "	<Dados>";
	$xmlAgendamento .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAgendamento .= "		<flgtipar>".$flgtipar."</flgtipar>";
	$xmlAgendamento .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAgendamento .= "		<idseqttl>1</idseqttl>";
	$xmlAgendamento .= "		<vlparaar>".$vlparaar."</vlparaar>";
	$xmlAgendamento .= "		<flgtipin>".$flgtipin."</flgtipin>";
	$xmlAgendamento .= "		<dtiniaar>".$dtiniaar."</dtiniaar>";
	$xmlAgendamento .= "		<qtmesaar>".$qtmesaar."</qtmesaar>";
	$xmlAgendamento .= "		<dtdiaaar>".$dtdiaaar."</dtdiaaar>";
	$xmlAgendamento .= "		<qtdiacar>".$qtdiacar."</qtdiacar>";
	$xmlAgendamento .= "		<dtvencto>".$dtvencto."</dtvencto>";
	$xmlAgendamento .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAgendamento .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
	$xmlAgendamento .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlAgendamento .= "	</Dados>";
	$xmlAgendamento .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAgendamento);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAgendamento = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjAgendamento->roottag->tags[0]->name) && strtoupper($xmlObjAgendamento->roottag->tags[0]->name) == "ERRO") {
		exibeErro(str_replace("#","<br>",$xmlObjAgendamento->roottag->tags[0]->tags[0]->tags[4]->cdata));
	} 
	
	$vllanmto = floatval(str_replace(',','.',str_replace('.','',$vlparaar)));
	$vllanmto = $qtmesaar * $vllanmto;
	
	if ($flgtipar == 1) 
		$cdprodut = 41; // Resgate
	else
		$cdprodut = 3; // Aplicacao
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>".$cdprodut."</cdprodut>";
	$xml .= "   <vlcontra>".$vllanmto."</vlcontra>";
	$xml .= "   <cddchave>".    0    ."</cddchave>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_VALOR_ADESAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','',false);
	}
	
	$solcoord = $xmlObject->roottag->tags[0]->cdata;
	$mensagem = $xmlObject->roottag->tags[1]->cdata;
	
	$executar = "";
	
	// Solicitar a confirmação da inclusão do agendamento
	$executar .= "solicitarConfirmacaoInclusao();";
	
	// Se ocorrer um erro, mostra crítica
	if ($mensagem != "") {
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		
		exibirErro("error",$mensagem,"Alerta - Aimaro", ($solcoord == 1 ? "senhaCoordenador(\\\"".$executar."\\\");" : ""),false);
	} else {
		echo $executar;
	}
	
?>