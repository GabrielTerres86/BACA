<?php 

	/**********************************************************************
		Fonte: cancelamento_bloqueio_cancelabloqueia.php
		Autor: Guilherme
		Data : Abril/2007                   Última Alteração: 09/04/2015

		Objetivo  : Efetuar cancelamento ou o Bloqueio do Cartão de Crédito - 
	                rotina de Cartão de Crédito da tela ATENDA

		Alterações: Adaptação para cartão PJ (David).
		
		19/06/2012 - Adicionado confirmacao para impressao (Jorge)
		
		09/04/2015 - #272659 Adicionado alerta para bloqueio de cartão BB (Carlos)
		
        17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
		
	 ***********************************************************************/
	
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
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

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}

	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}	
	
	// Verifica se o indicador do tipo de cancelamento é um inteiro válido
	if (!validaInteiro($indposic)) {
		exibeErro("Indicador de Cancelamento/Bloqueio inv&aacute;lido.");
	}
	
	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrcpfrep)) {
		exibeErro("CPF do representante inv&aacute;lido.");
	}
	
	// Monta o xml de requisição
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

    $msgalert = $xmlObjCartao->roottag->tags[0]->attributes["MSGALERT"];
	if ($msgalert !== "") {
		exibeAlert($msgalert);
	}
	
	// Chama a função para efetuar a impressão do termo de cancelamento em PDF
	if ($inpessoa == "1") {		
		$gerarimpr = 'gerarImpressao(2,4,\''.$cdadmcrd.'\','.$nrctrcrd.',0);';
	} else {
		$gerarimpr = 'gerarImpressao(2,13,\''.$cdadmcrd.'\','.$nrctrcrd.',0);';
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	
	echo "callafterCartaoCredito = \"".$acessaaba."\";";
	
	// Efetua a impressão do termo de alteração de data
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","'.$gerarimpr.'","'.$acessaaba.'","sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	// Função para exibir alerta na tela através de javascript
	function exibeAlert($msgAlert) { 		
		echo 'showError("error","'.$msgAlert.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	}
?>
