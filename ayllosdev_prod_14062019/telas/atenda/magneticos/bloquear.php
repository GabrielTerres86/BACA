<?php 

	//*************************************************************************************//
	//*** Fonte: bloquear.php															***//
	//*** Autor: David																	***//
	//*** Data : Outubro/2008                 Ultima Alteracao: 26/07/2016				***//
	//***																				***//
	//*** Objetivo  : Bloquear Cartao Magnetico											***//
	//***																				***//	 
	//*** Alteracoes: 26/07/2016 - Corrigi a forma de tratamento do retorno	de erro XML ***//
	//***						   SD 479874 (Carlos R.)								***//	 
	//***																				***//	 
	//*************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"B")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlBloqueio  = "";
	$xmlBloqueio .= "<Root>";
	$xmlBloqueio .= "	<Cabecalho>";
	$xmlBloqueio .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlBloqueio .= "		<Proc>bloquear-cartao-magnetico</Proc>";
	$xmlBloqueio .= "	</Cabecalho>";
	$xmlBloqueio .= "	<Dados>";
	$xmlBloqueio .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlBloqueio .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlBloqueio .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlBloqueio .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlBloqueio .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlBloqueio .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlBloqueio .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlBloqueio .= "		<idseqttl>1</idseqttl>";
	$xmlBloqueio .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlBloqueio .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlBloqueio .= "		<flgerlog>YES</flgerlog>";
	$xmlBloqueio .= "	</Dados>";
	$xmlBloqueio .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlBloqueio);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjBloqueio = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjBloqueio->roottag->tags[0]->name) && strtoupper($xmlObjBloqueio->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBloqueio->roottag->tags[0]->tags[0]->tags[4]->cdata);
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