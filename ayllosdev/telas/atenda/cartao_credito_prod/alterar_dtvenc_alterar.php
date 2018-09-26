<?php 

	/************************************************************************
	  Fonte: alterar_dtvenc_alterar.php
	  Autor: Guilherme
	  Data : Abril/2008                 Última Alteração: 11/04/2013

	  Objetivo  :  Efetuar alteração da data de vencimento de 
	               Cartões de Crédito

	  Alterações: 05/11/2010 - Adaptação Cartão PJ (David).		

			      08/09/2011 - Incluido a chamada para a procedure alerta_fraude
							   (Adriano).
							   
				  19/06/2012 - Adicionado confirmacao para impressao (Jorge)
	  
				  11/04/2013 - Retirado a chamada da procedure alerta_fraude
							   (Adriano).
	  
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
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}

	
	
	// Verifica se os parâmetros necessários foram informados
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
	

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}
	
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrcpfrep)) {
		exibeErro("CPF do representante inv&aacute;lido.");
	}
	
	// Verifica se o dia do vencimento é um inteiro válido
	if (!validaInteiro($dddebito)) {
		exibeErro("Dia do vencimento inv&aacute;lido.");
	}	
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("N&uacute;mero de CPF/CNPJ inv&aacute;lido.");
	}
	
	
	// Monta o xml de requisição
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDtVenc->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDtVenc->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

		
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	$gerarimpr = "gerarImpressao(2,".($inpessoa == 1 ? 8 : 15).",0,".$nrctrcrd.",0);";

	echo "callafterCartaoCredito = \"".$acessaaba."\";";
	
	// Efetua a impressão do termo de alteração de data
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","'.$gerarimpr.'","'.$acessaaba.'","sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha
	
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
?>