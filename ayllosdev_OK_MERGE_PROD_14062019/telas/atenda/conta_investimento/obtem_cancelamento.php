<?php 

	//************************************************************************//
	//*** Fonte: obtem_cancelamento.php                                    ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Confirmar cancelamento da rotina de Conta            ***//
	//***             Investimento da tela ATENDA                          ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrdocmto"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrdocmto = $_POST["nrdocmto"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se n&uacute;mero do documento &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdocmto)) {
		exibeErro("N&uacute;mero do Documento inv&aacute;lido.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetCancel  = "";
	$xmlSetCancel .= "<Root>";
	$xmlSetCancel .= "	<Cabecalho>";
	$xmlSetCancel .= "		<Bo>b1wgen0020.p</Bo>";
	$xmlSetCancel .= "		<Proc>obtem-cancelamento</Proc>";
	$xmlSetCancel .= "	</Cabecalho>";
	$xmlSetCancel .= "	<Dados>";
	$xmlSetCancel .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCancel .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCancel .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCancel .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCancel .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCancel .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlSetCancel .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCancel .= "		<idseqttl>1</idseqttl>";
	$xmlSetCancel .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCancel .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";
	$xmlSetCancel .= "	</Dados>";
	$xmlSetCancel .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCancel);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCancel = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjCancel->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCancel->roottag->tags[0]->tags[0]->tags[4]->cdata);
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