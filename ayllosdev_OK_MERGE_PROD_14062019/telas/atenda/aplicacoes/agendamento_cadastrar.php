<?php 

	//************************************************************************//
	//*** Fonte: agendamento_cadastrar.php                                 ***//
	//*** Autor: Douglas Quisinski                                         ***//
	//*** Data : Setembro/2014                Última Alteração: 21/07/2016 ***//
	//***                                                                  ***//
	//*** Objetivo  : Cadastrar o agendamento de aplicação e resgate       ***//	
	//***                                                                  ***//	 
	//*** Alterações: 14/10/2014 - Removido o processo de validação do     ***//
	//***                          novo agendamento, para que as mensagens ***//
	//***                          de erro sejam exibidas antes de solici- ***//
	//***                          tar a confirmação. (Douglas - Projeto   ***//
	//***                          Captação Internet 2014/2)               ***//
	//***                                                                  ***//
	//***             21/07/2016 - Corrigi a forma de validacao do retorno ***//
	//***						   XML "ERRO". SD 479874 (Carlos R).	   ***//	
	//************************************************************************//
	
	include('agendamento_validar_parametros.php');
	
	// Gravar o agendamento
	// Se nao tiver erro, montar nova requisicao e gravar o agendamento
	$xmlAgendamento  = "";
	$xmlAgendamento .= "<Root>";
	$xmlAgendamento .= "	<Cabecalho>";
	$xmlAgendamento .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlAgendamento .= "		<Proc>incluir-novo-agendamento</Proc>";
	$xmlAgendamento .= "	</Cabecalho>";
	$xmlAgendamento .= "	<Dados>";
	$xmlAgendamento .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAgendamento .= "		<flgtipar>".$flgtipar."</flgtipar>";
	$xmlAgendamento .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAgendamento .= "		<idseqttl>1</idseqttl>";
	$xmlAgendamento .= "		<vlparaar>".$vlparaar."</vlparaar>";
	$xmlAgendamento .= "		<flgtipin>".$flgtipin."</flgtipin>";
	$xmlAgendamento .= "		<qtdiacar>".$qtdiacar."</qtdiacar>";
	$xmlAgendamento .= "		<qtmesaar>".$qtmesaar."</qtmesaar>";
	$xmlAgendamento .= "		<dtiniaar>".$dtiniaar."</dtiniaar>";
	$xmlAgendamento .= "		<dtdiaaar>".$dtdiaaar."</dtdiaaar>";
	$xmlAgendamento .= "		<dtvencto>".$dtvencto."</dtvencto>";
	$xmlAgendamento .= "		<qtdiaven>".$qtdiaven."</qtdiaven>";
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
		exibeErro($xmlObjAgendamento->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	// Bloqueia conteúdo que está atrás do div da rotina
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	// Voltar para opção geral de agendamento
	echo 'recarregaAgendamento();';
?>