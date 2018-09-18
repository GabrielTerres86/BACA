<?php 

	/************************************************************************
	  Fonte: alterar_dtvenc_alterar.php
	  Autor: Guilherme
	  Data : Abril/2008                 �ltima Altera��o: 11/04/2013

	  Objetivo  :  Efetuar altera��o da data de vencimento de 
	               Cart�es de Cr�dito

	  Altera��es: 05/11/2010 - Adapta��o Cart�o PJ (David).		

			      08/09/2011 - Incluido a chamada para a procedure alerta_fraude
							   (Adriano).
							   
				  19/06/2012 - Adicionado confirmacao para impressao (Jorge)
	  
				  11/04/2013 - Retirado a chamada da procedure alerta_fraude
							   (Adriano).
	  
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
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}

	
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["inpessoa"]) ||
		!isset($_POST["nrctrcrd"]) ||
		/*!isset($_POST["repsolic"]) ||
		!isset($_POST["nrcpfrep"]) ||*/
		!isset($_POST["dddebito"]) ||
		!isset($_POST["nrcpfcgc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$inpessoa = $_POST["inpessoa"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$repsolic = $_POST["repsolic"];
	$nrcpfrep = $_POST["nrcpfrep"];
	$dddebito = $_POST["dddebito"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se tipo de pessoa � um inteiro v�lido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}
	
	// Verifica se o n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se CPF do representante � um inteiro v�lido
	if (!validaInteiro($nrcpfrep)) {
		exibeErro("CPF do representante inv&aacute;lido.");
	}
	
	// Verifica se o dia do vencimento � um inteiro v�lido
	if (!validaInteiro($dddebito)) {
		exibeErro("Dia do vencimento inv&aacute;lido.");
	}	
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("N&uacute;mero de CPF/CNPJ inv&aacute;lido.");
	}
	
	
	// Monta o xml de requisi��o
	$xmlSetDtVenc  = "";
	$xmlSetDtVenc .= "<Root>";
	$xmlSetDtVenc .= "	<Cabecalho>";
	$xmlSetDtVenc .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetDtVenc .= "		<Proc>altera_dtvencimento_cartao</Proc>";
	$xmlSetDtVenc .= "	</Cabecalho>";
	$xmlSetDtVenc .= "	<Dados>";
	$xmlSetDtVenc .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetDtVenc .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetDtVenc .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetDtVenc .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetDtVenc .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetDtVenc .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetDtVenc .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetDtVenc .= "		<idseqttl>1</idseqttl>";
	$xmlSetDtVenc .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetDtVenc .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetDtVenc .= "		<dddebito>".$dddebito."</dddebito>";
	$xmlSetDtVenc .= "		<nrcpfrep>".$nrcpfrep."</nrcpfrep>";
	$xmlSetDtVenc .= "		<repsolic>".$repsolic."</repsolic>";
	$xmlSetDtVenc .= "	</Dados>";
	$xmlSetDtVenc .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetDtVenc);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDtVenc = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDtVenc->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDtVenc->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

		
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	$gerarimpr = "gerarImpressao(2,".($inpessoa == 1 ? 8 : 15).",0,".$nrctrcrd.",0);";

	echo "callafterCartaoCredito = \"".$acessaaba."\";";
	
	// Efetua a impress�o do termo de altera��o de data
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","'.$gerarimpr.'","'.$acessaaba.'","sim.gif","nao.gif");';// Efetua a impress�o do termo de solicita��o de 2 via de senha
	
		
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
?>