<?php 

	//************************************************************************//
	//*** Fonte: agendamento_validar.php                                   ***//
	//*** Autor: Douglas Quisinski                                         ***//
	//*** Data : Outubro/2014                 Última Alteração: 21/07/2016 ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar o agendamento de aplicação e resgate         ***//	
	//***                                                                  ***//	 
	//*** Alterações: 21/07/2016 Corrigi a forma de validacao do retorno   ***//	
	//***						 XML"ERRO".SD 479874 (Carlos R.)		   ***//	
	//***                                                                  ***//
	//************************************************************************//
	
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
		
	// Solicitar a confirmação da inclusão do agendamento
	echo 'solicitarConfirmacaoInclusao();';
?>