<?php 

	//************************************************************************//
	//*** Fonte: alterar_limite_saque.php                                  ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2008                 &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Alterar Limite de Saque do Cart&atilde;o Magn&eacute;tico          ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"T")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"]) || !isset($_POST["insaqmax"]) || !isset($_POST["vlsaqmax"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	$insaqmax = $_POST["insaqmax"];
	$vlsaqmax = $_POST["vlsaqmax"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}
	
	// Verifica se o identificador da forma de saque &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($insaqmax)) {
		exibeErro("Forma de Saque inv&aacute;lida.");
	}	
	
	// Verifica se valor do limite de saque &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vlsaqmax)) {
		exibeErro("Valor do Limite de Saque inv&aacute;lido.");
	}		
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosLimite  = "";
	$xmlDadosLimite .= "<Root>";
	$xmlDadosLimite .= "	<Cabecalho>";
	$xmlDadosLimite .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlDadosLimite .= "		<Proc>alterar-limite-saque</Proc>";
	$xmlDadosLimite .= "	</Cabecalho>";
	$xmlDadosLimite .= "	<Dados>";
	$xmlDadosLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosLimite .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosLimite .= "		<idseqttl>1</idseqttl>";
	$xmlDadosLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDadosLimite .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlDadosLimite .= "		<insaqmax>".$insaqmax."</insaqmax>";
	$xmlDadosLimite .= "		<vlsaqmax>".$vlsaqmax."</vlsaqmax>";
	$xmlDadosLimite .= "		<flgerlog>YES</flgerlog>";
	$xmlDadosLimite .= "	</Dados>";
	$xmlDadosLimite .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosLimite);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
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