<?php

	//************************************************************************//
	//*** Fonte: busca_intervalo_dias.php                                  ***//
	//*** Autor: Douglas Quisinski                                         ***//
	//*** Data : Setembro/2014                Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Calcula a quantidade de dias de diferença entre      ***//
	//***             duas datas                                           ***//
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["dtiniitr"]) || !isset($_POST["dtfinitr"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtiniitr = $_POST["dtiniitr"];	
	$dtfinitr = $_POST["dtfinitr"];	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	

	// Verifica se a data de inicio é válida
	if (!validaData($dtiniitr)) {
		exibeErro("Data de in&iacute;cio inv&aacute;lida.");
	}
	
	// Verifica se a data de fim é válida
	if (!validaData($dtfinitr)) {
		exibeErro("Data de fim inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetSomaData  = "";
	$xmlGetSomaData .= "<Root>";
	$xmlGetSomaData .= "	<Cabecalho>";
	$xmlGetSomaData .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetSomaData .= "		<Proc>busca-intervalo-dias</Proc>";
	$xmlGetSomaData .= "	</Cabecalho>";
	$xmlGetSomaData .= "	<Dados>";
	$xmlGetSomaData .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetSomaData .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetSomaData .= "		<idseqttl>1</idseqttl>";
	$xmlGetSomaData .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetSomaData .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
	$xmlGetSomaData .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetSomaData .= "		<dtiniitr>".$dtiniitr."</dtiniitr>";
	$xmlGetSomaData .= "		<dtfinitr>".$dtfinitr."</dtfinitr>";
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
	                                                       
	$dtvendia = $xmlObjData->roottag->tags[0]->attributes["DTVENDIA"];
	echo "hideMsgAguardo();";
	echo "setDiasVencimento('".$dtvendia."');";
	echo "blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));";

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
?>