<?php 

	//*************************************************************************************************//
	//*** Fonte: bloqueia_senha_acesso.php															***//
	//*** Autor: David																				***//
	//*** Data : Junho/2008                   Ultima Alteracao: 26/07/2016							***//
	//***																							***//
	//*** Objetivo  : Bloquear Senha de Acesso ao InternetBank - Rotina de Internet da tela ATENDA) ***//
	//***																							***//	 
	//*** Alteracoes: 26/07/2016 - Corrigi a forma de retorno de erro do XML.SD 479874 (Carlos R.)  ***//
	//*************************************************************************************************//
	
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetBloqueio  = "";
	$xmlSetBloqueio .= "<Root>";
	$xmlSetBloqueio .= "	<Cabecalho>";
	$xmlSetBloqueio .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlSetBloqueio .= "		<Proc>bloquear-senha-internet</Proc>";
	$xmlSetBloqueio .= "	</Cabecalho>";
	$xmlSetBloqueio .= "	<Dados>";
	$xmlSetBloqueio .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetBloqueio .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetBloqueio .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetBloqueio .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetBloqueio .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetBloqueio .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetBloqueio .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetBloqueio .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlSetBloqueio .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetBloqueio .= "	</Dados>";
	$xmlSetBloqueio .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetBloqueio);
	
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
	}	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>