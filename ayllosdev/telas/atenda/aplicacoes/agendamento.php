<?php 

	/************************************************************************
	 Fonte: agendamento.php                                             
	 Autor: Douglas
	 Data : Setembro/2014                Última Alteração:
	                                                                  
	 Objetivo  : Mostrar opcao dos tipos Agendamento das aplicações
	                                                                  	 
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

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	// Primeiro vamos validar apenas os parametros do numero da conta
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	//Carregar as informacoes da carencia
	// Monta o xml de requisição
	$xmlGetCarencia  = "";
	$xmlGetCarencia .= "<Root>";
	$xmlGetCarencia .= "	<Cabecalho>";
	$xmlGetCarencia .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetCarencia .= "		<Proc>obtem-dias-carencia</Proc>";
	$xmlGetCarencia .= "	</Cabecalho>";
	$xmlGetCarencia .= "	<Dados>";
	$xmlGetCarencia .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetCarencia .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetCarencia .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetCarencia .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetCarencia .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetCarencia .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetCarencia .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";		
	$xmlGetCarencia .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetCarencia .= "		<idseqttl>1</idseqttl>";
	$xmlGetCarencia .= "		<tpaplica>8</tpaplica>";
	$xmlGetCarencia .= "		<qtdiaapl>0</qtdiaapl>";
	$xmlGetCarencia .= "		<qtdiacar>0</qtdiacar>";
	$xmlGetCarencia .= "		<flgvalid>0</flgvalid>";
	$xmlGetCarencia .= "	</Dados>";
	$xmlGetCarencia .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResultCarencia = getDataXML($xmlGetCarencia);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCarencia = getObjectXML($xmlResultCarencia);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarencia->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarencia->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$carencias   = $xmlObjCarencia->roottag->tags[0]->tags;	
	$qtCarencias = count($carencias);
	
	// Monta o xml de requisição
	$xmlGetDiasAgen  = "";
	$xmlGetDiasAgen .= "<Root>";
	$xmlGetDiasAgen .= "	<Cabecalho>";
	$xmlGetDiasAgen .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetDiasAgen .= "		<Proc>cons-qtd-mes-age</Proc>";
	$xmlGetDiasAgen .= "	</Cabecalho>";
	$xmlGetDiasAgen .= "	<Dados>";
	$xmlGetDiasAgen .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDiasAgen .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDiasAgen .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDiasAgen .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDiasAgen .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
	$xmlGetDiasAgen .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDiasAgen .= "	</Dados>";
	$xmlGetDiasAgen .= "</Root>";


	// Executa script para envio do XML
	$xmlResultDiasAgen = getDataXML($xmlGetDiasAgen);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDiasAgen = getObjectXML($xmlResultDiasAgen);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDiasAgen->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDiasAgen->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$qtmesage = $xmlObjDiasAgen->roottag->tags[0]->attributes["QTMESAGE"];
	
	// Monta o xml de requisição
	$xmlGetNextData  = "";
	$xmlGetNextData .= "<Root>";
	$xmlGetNextData .= "	<Cabecalho>";
	$xmlGetNextData .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetNextData .= "		<Proc>busca-proxima-data-movimento</Proc>";
	$xmlGetNextData .= "	</Cabecalho>";
	$xmlGetNextData .= "	<Dados>";
	$xmlGetNextData .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetNextData .= "	</Dados>";
	$xmlGetNextData .= "</Root>";

	// Executa script para envio do XML
	$xmlResultData = getDataXML($xmlGetNextData);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjData = getObjectXML($xmlResultData);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjData->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjData->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	                                                       
	$proxima_data = $xmlObjData->roottag->tags[0]->attributes["DTMVTOPR"];
	
?>