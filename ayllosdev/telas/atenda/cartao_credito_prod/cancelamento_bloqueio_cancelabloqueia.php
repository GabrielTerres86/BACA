<?php 

	/**********************************************************************
		Fonte: cancelamento_bloqueio_cancelabloqueia.php
		Autor: Guilherme
		Data : Abril/2007                   �ltima Altera��o: 09/04/2015

		Objetivo  : Efetuar cancelamento ou o Bloqueio do Cart�o de Cr�dito - 
	                rotina de Cart�o de Cr�dito da tela ATENDA

		Altera��es: Adapta��o para cart�o PJ (David).
		
		19/06/2012 - Adicionado confirmacao para impressao (Jorge)
		
		09/04/2015 - #272659 Adicionado alerta para bloqueio de cart�o BB (Carlos)
		
        17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
		
	 ***********************************************************************/
	
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrcrd"]) ||
		!isset($_POST["inpessoa"]) ||
		!isset($_POST["repsolic"]) ||
		!isset($_POST["nrcpfrep"]) ||
		!isset($_POST["indposic"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$indposic = $_POST["indposic"];
	$inpessoa = $_POST["inpessoa"];
	$repsolic = $_POST["repsolic"];
	$nrcpfrep = $_POST["nrcpfrep"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}

	// Verifica se tipo de pessoa � um inteiro v�lido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}	
	
	// Verifica se o indicador do tipo de cancelamento � um inteiro v�lido
	if (!validaInteiro($indposic)) {
		exibeErro("Indicador de Cancelamento/Bloqueio inv&aacute;lido.");
	}
	
	// Verifica se CPF do representante � um inteiro v�lido
	if (!validaInteiro($nrcpfrep)) {
		exibeErro("CPF do representante inv&aacute;lido.");
	}
	
	// Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>cancela_bloqueia_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<indposic>".$indposic."</indposic>";	
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<idseqttl>1</idseqttl>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<repsolic>".$repsolic."</repsolic>";
	$xmlSetCartao .= "		<nrcpfrep>".$nrcpfrep."</nrcpfrep>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

    $msgalert = $xmlObjCartao->roottag->tags[0]->attributes["MSGALERT"];
	if ($msgalert !== "") {
		exibeAlert($msgalert);
	}
	
	// Chama a fun��o para efetuar a impress�o do termo de cancelamento em PDF
	if ($inpessoa == "1") {		
		$gerarimpr = 'gerarImpressao(2,4,\''.$cdadmcrd.'\','.$nrctrcrd.',0);';
	} else {
		$gerarimpr = 'gerarImpressao(2,13,\''.$cdadmcrd.'\','.$nrctrcrd.',0);';
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	
	echo "callafterCartaoCredito = \"".$acessaaba."\";";
	
	// Efetua a impress�o do termo de altera��o de data
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","'.$gerarimpr.'","'.$acessaaba.'","sim.gif","nao.gif");';// Efetua a impress�o do termo de solicita��o de 2 via de senha
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	// Fun��o para exibir alerta na tela atrav�s de javascript
	function exibeAlert($msgAlert) { 		
		echo 'showError("error","'.$msgAlert.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	}
?>
