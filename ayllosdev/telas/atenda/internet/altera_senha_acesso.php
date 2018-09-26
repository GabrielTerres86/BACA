<?php 

	//************************************************************************//
	//*** Fonte: altera_senha_acesso.php                                   ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2008                   &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Alterar Senha de Acesso ao InternetBank - Rotina de  ***//
	//***             Internet da tela ATENDA)                             ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) || !isset($_POST["cddsenha"]) || !isset($_POST["cdsnhnew"]) || !isset($_POST["cdsnhrep"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$cddsenha = $_POST["cddsenha"];
	$cdsnhnew = $_POST["cdsnhnew"];
	$cdsnhrep = $_POST["cdsnhrep"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}
	
	// Verifica se senha atual &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($cddsenha)) {
		exibeErro("Senha atual inv&aacute;lida.");
	}	
	
	// Verifica se nova senha &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($cdsnhnew)) {
		exibeErro("Nova senha inv&aacute;lida.");
	}	
	
	// Verifica se confirma&ccedil;&atilde;o de nova senha &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($cdsnhrep)) {
		exibeErro("Confirma&ccedil;&atilde;o de nova senha inv&aacute;lida.");
	}				
			
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetAlterar  = "";
	$xmlSetAlterar .= "<Root>";
	$xmlSetAlterar .= "	<Cabecalho>";
	$xmlSetAlterar .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlSetAlterar .= "		<Proc>alterar-senha-internet</Proc>";
	$xmlSetAlterar .= "	</Cabecalho>";
	$xmlSetAlterar .= "	<Dados>";
	$xmlSetAlterar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetAlterar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetAlterar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetAlterar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetAlterar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetAlterar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetAlterar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetAlterar .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlSetAlterar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetAlterar .= "		<cddsenha>".$cddsenha."</cddsenha>";
	$xmlSetAlterar .= "		<cdsnhnew>".$cdsnhnew."</cdsnhnew>";
	$xmlSetAlterar .= "		<cdsnhrep>".$cdsnhrep."</cdsnhrep>";
	$xmlSetAlterar .= "	</Dados>";
	$xmlSetAlterar .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetAlterar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAlterar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjAlterar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata);
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