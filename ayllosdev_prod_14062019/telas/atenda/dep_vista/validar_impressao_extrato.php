<?php 

	/************************************************************************
	  Fonte: validar_impressao_extrato.php
	  Autor: David
	  Data : Setembro/2010                    Última Alteração: 19/06/2012

	  Objetivo  : Validar impressão do extrato da conta corrente

	  Alterações: 19/06/2012 - Adicionado confirmacao para impressao (Jorge).
	 ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["dtiniper"]) || !isset($_POST["dtfimper"]) || !isset($_POST["inisenta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtiniper = $_POST["dtiniper"];   
	$dtfimper = $_POST["dtfimper"];
	$inisenta = $_POST["inisenta"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se data inicial é válida
	if (!validaData($dtiniper)) {
		exibeErro("Data inicial inv&aacute;lida.");
	}
	
	// Verifica se data final é válida
	if (!validaData($dtfimper)) {
		exibeErro("Data final inv&aacute;lida.");
	}
			
	// Monta o xml de requisição
	$xmlValidaExtrato  = "";
	$xmlValidaExtrato .= "<Root>";
	$xmlValidaExtrato .= "	<Cabecalho>";
	$xmlValidaExtrato .= "		<Bo>b1wgen0001.p</Bo>";
	$xmlValidaExtrato .= "		<Proc>valida-impressao-extrato</Proc>";
	$xmlValidaExtrato .= "	</Cabecalho>";
	$xmlValidaExtrato .= "	<Dados>";
	$xmlValidaExtrato .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlValidaExtrato .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlValidaExtrato .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlValidaExtrato .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlValidaExtrato .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlValidaExtrato .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlValidaExtrato .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlValidaExtrato .= "		<idseqttl>1</idseqttl>";
	$xmlValidaExtrato .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";		
	$xmlValidaExtrato .= "		<dtiniper>".$dtiniper."</dtiniper>";	
	$xmlValidaExtrato .= "		<dtfimper>".$dtfimper."</dtfimper>";
	$xmlValidaExtrato .= "		<inisenta>".$inisenta."</inisenta>";
	$xmlValidaExtrato .= "	</Dados>";
	$xmlValidaExtrato .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlValidaExtrato);

	// Cria objeto para classe de tratamento de XML
	$xmlValidaExtrato = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (isset($xmlValidaExtrato->roottag->tags[0]->name) && strtoupper($xmlValidaExtrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlValidaExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$hideblock = 'hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	$gerarimpr = 'imprimirExtrato();';	
	
	$msgConfirma = ( isset($xmlValidaExtrato->roottag->tags[0]->tags[0]->tags[1]->cdata) ) ? $xmlValidaExtrato->roottag->tags[0]->tags[0]->tags[1]->cdata : '';
	
	if ($msgConfirma <> '') {
		// Efetua a impressão do termo de entrega
		echo 'showConfirmacao("'.$msgConfirma.'","Confirma&ccedil;&atilde;o - Aimaro","'.$hideblock.$gerarimpr.'","'.$hideblock.'","sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha
	} else {
		// Efetua a impressão do termo de entrega
	    echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","'.$hideblock.$gerarimpr.'","'.$hideblock.'","sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>
