<?php

	//************************************************************************//
	//*** Fonte: soma_data_vencto.php                                      ***//
	//*** Autor: Douglas Quisinski                                         ***//
	//*** Data : Setembro/2014                Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Calcula a data de vencimento da aplicação de acordo  ***//
	//***             com a carência que foi selecionada                   ***//
	//***                                                                  ***//	 
	//*** Alterações: 													   ***//
	//************************************************************************//

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

	// Validar os parametros
	if (!isset($_POST["nrdconta"]) || !isset($_POST["qtdiacar"]) || !isset($_POST["dtiniaar"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$qtdiacar = $_POST["qtdiacar"];	
	$dtiniaar = $_POST["dtiniaar"];	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	

	// Verifica se a data é válida
	if (!validaData($dtiniaar)) {
		exibeErro("Data inv&aacute;lida.");
	}
	
	// Verifica se tipo de agendamendo é válido
	if (!validaInteiro($qtdiacar)) {
		exibeErro("Quantidade de dias de car&ecirc;ncia inv&aacute;lido.");
	}	
	
	//Carregar as informacoes da carencia
	// Monta o xml de requisição
	$xmlGetSomaData  = "";
	$xmlGetSomaData .= "<Root>";
	$xmlGetSomaData .= "	<Cabecalho>";
	$xmlGetSomaData .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetSomaData .= "		<Proc>soma-data-vencto</Proc>";
	$xmlGetSomaData .= "	</Cabecalho>";
	$xmlGetSomaData .= "	<Dados>";
	$xmlGetSomaData .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetSomaData .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetSomaData .= "		<idseqttl>1</idseqttl>";
	$xmlGetSomaData .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetSomaData .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
	$xmlGetSomaData .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetSomaData .= "		<qtdiacar>".$qtdiacar."</qtdiacar>";
	$xmlGetSomaData .= "		<dtiniaar>".$dtiniaar."</dtiniaar>";
	$xmlGetSomaData .= "	</Dados>";
	$xmlGetSomaData .= "</Root>";

	// Executa script para envio do XML
	$xmlResultData = getDataXML($xmlGetSomaData);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjData = getObjectXML($xmlResultData);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjData->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjData->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

	$dtvencto = $xmlObjData->roottag->tags[0]->attributes["DTVENCTO"];
	echo "hideMsgAguardo();";
	echo "setDataVenctoAgendamento('".$dtvencto."');";
	echo "setDiasVencimento('".$qtdiacar."');";
	echo "blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));";

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
?>