<?php 

	//************************************************************************//
	//*** Fonte: alterar_recibo_saque.php                                  ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2008                 &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Atualizar Recibo de Saque do Cart&atilde;o Magn&eacute;tico        ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es:                                                      ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"]) || !isset($_POST["inrecsaq"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	$inrecsaq = $_POST["inrecsaq"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}
	
	// Verifica se o identificador do recibo de saque &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($inrecsaq)) {
		exibeErro("Identificador do Recibo de Saque inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosRecibo  = "";
	$xmlDadosRecibo .= "<Root>";
	$xmlDadosRecibo .= "	<Cabecalho>";
	$xmlDadosRecibo .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlDadosRecibo .= "		<Proc>atualizar-emissao-recibo-saque</Proc>";
	$xmlDadosRecibo .= "	</Cabecalho>";
	$xmlDadosRecibo .= "	<Dados>";
	$xmlDadosRecibo .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosRecibo .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosRecibo .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosRecibo .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosRecibo .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosRecibo .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosRecibo .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosRecibo .= "		<idseqttl>1</idseqttl>";
	$xmlDadosRecibo .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDadosRecibo .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlDadosRecibo .= "		<inrecsaq>".$inrecsaq."</inrecsaq>";
	$xmlDadosRecibo .= "		<flgerlog>YES</flgerlog>";
	$xmlDadosRecibo .= "	</Dados>";
	$xmlDadosRecibo .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosRecibo);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRecibo = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjRecibo->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRecibo->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o &iacute;ndice da op&ccedil;&atilde;o "@" foi encontrado 
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
	}	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>