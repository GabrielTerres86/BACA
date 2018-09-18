<?php 

	//************************************************************************//
	//*** Fonte: 2via_solicitacao_efetuar.php                              ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Março/2008                   Última Alteração: 08/11/2010 ***//
	//***                                                                  ***//
	//*** Objetivo  : Efetuar solicitação da segunda via do cartão         ***//
	//***                                                                  ***//	 
	//*** Alterações: 04/09/2008 - Adaptação para solicitação de 2 via de  ***//
	//***                          senha de cartão de crédito (David)      ***//
	//***                                                                  ***//
	//***             08/11/2010 - Adaptação Cartão PJ (David)             ***//
	//***																   ***//
	//***			  19/06/2012 - Adicionado confirmacao para impressao   ***//
	//***						   (Jorge)								   ***//
	//************************************************************************//		 
	
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["cdadmcrd"]) || !isset($_POST["nmtitcrd"]) ||
        !isset($_POST["cdmotivo"]) || !isset($_POST["inpessoa"]) || !isset($_POST["repsolic"]) || !isset($_POST["nrcpfrep"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$cdadmcrd = $_POST["cdadmcrd"];
	$nmtitcrd = $_POST["nmtitcrd"];
	$cdmotivo = $_POST["cdmotivo"];	
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
	
	// Verifica se o código da adm é um inteiro válido
	if (!validaInteiro($cdadmcrd)) {
		exibeErro("C&oacute;digo da administradora inv&aacute;lido.");
	}	

	// Verifica se o código do motivo é um inteiro válido
	if (!validaInteiro($cdmotivo)) {
		exibeErro("C&oacute;digo do motivo inv&aacute;lido.");
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
	$xmlSetCartao .= "		<Proc>efetua_solicitacao2via_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<idseqttl>1</idseqttl>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<cdadmcrd>".$cdadmcrd."</cdadmcrd>";
	$xmlSetCartao .= "		<cdmotivo>".$cdmotivo."</cdmotivo>";
	$xmlSetCartao .= "		<nmtitcrd>".$nmtitcrd."</nmtitcrd>";
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
	
	if ($inpessoa == "1") {
		// Efetua a impressão do termo de solicitação de segunda via
		$gerarimpr = 'gerarImpressao(2,6,\''.$cdadmcrd.'\','.$nrctrcrd.','.$cdmotivo.');';	
	} else {	
		$gerarimpr = 'gerarImpressao(2,11,\''.$cdadmcrd.'\','.$nrctrcrd.',0);';
	}	
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	
	echo "callafterCartaoCredito = \"".$acessaaba."\";";
	
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","'.$gerarimpr.'","'.$acessaaba.'","sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>