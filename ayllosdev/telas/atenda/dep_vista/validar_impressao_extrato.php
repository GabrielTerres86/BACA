<?php 

	/************************************************************************
	  Fonte: validar_impressao_extrato.php
	  Autor: David
	  Data : Setembro/2010                    �ltima Altera��o: 19/06/2012

	  Objetivo  : Validar impress�o do extrato da conta corrente

	  Altera��es: 19/06/2012 - Adicionado confirmacao para impressao (Jorge).
	 ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["dtiniper"]) || !isset($_POST["dtfimper"]) || !isset($_POST["inisenta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtiniper = $_POST["dtiniper"];   
	$dtfimper = $_POST["dtfimper"];
	$inisenta = $_POST["inisenta"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se data inicial � v�lida
	if (!validaData($dtiniper)) {
		exibeErro("Data inicial inv&aacute;lida.");
	}
	
	// Verifica se data final � v�lida
	if (!validaData($dtfimper)) {
		exibeErro("Data final inv&aacute;lida.");
	}
			
	// Monta o xml de requisi��o
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

	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlValidaExtrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlValidaExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$hideblock = 'hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	$gerarimpr = 'imprimirExtrato();';	
	
	$msgConfirma = $xmlValidaExtrato->roottag->tags[0]->tags[0]->tags[1]->cdata;
	
	if ($msgConfirma <> "") {
		// Efetua a impress�o do termo de entrega
		echo 'showConfirmacao("'.$msgConfirma.'","Confirma&ccedil;&atilde;o - Ayllos","'.$hideblock.$gerarimpr.'","'.$hideblock.'","sim.gif","nao.gif");';// Efetua a impress�o do termo de solicita��o de 2 via de senha
	} else {
		// Efetua a impress�o do termo de entrega
	    echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","'.$hideblock.$gerarimpr.'","'.$hideblock.'","sim.gif","nao.gif");';// Efetua a impress�o do termo de solicita��o de 2 via de senha
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>
