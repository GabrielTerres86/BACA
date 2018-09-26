<?php 

	//************************************************************************//
	//*** Fonte: alterar_senha_letras.php                                  ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Janeiro/2012                 Ultima Alteracao: 07/11/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Alterar Senha Letras de Cartao Magnetico - Rotina de ***//
	//***             Cartao Magnetico da tela ATENDA                      ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 07/11/2012 - Adicionado param. 'tpusucar' (Lucas)    ***//
	//***                                                                  ***//	 
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpusucar"]) || !isset($_POST["nrcartao"]) || !isset($_POST["dssennov"]) || !isset($_POST["dssencon"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];	
	$dssennov = $_POST["dssennov"];
	$dssencon = $_POST["dssencon"];
	$tpusucar = $_POST["tpusucar"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($tpusucar)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetSenha  = "";
	$xmlSetSenha .= "<Root>";
	$xmlSetSenha .= "	<Cabecalho>";
	$xmlSetSenha .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlSetSenha .= "		<Proc>grava-senha-letras</Proc>";
	$xmlSetSenha .= "	</Cabecalho>";
	$xmlSetSenha .= "	<Dados>";
	$xmlSetSenha .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetSenha .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetSenha .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetSenha .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetSenha .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetSenha .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetSenha .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetSenha .= "		<idseqttl>".$tpusucar."</idseqttl>";
	$xmlSetSenha .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetSenha .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlSetSenha .= "		<dssennov>".$dssennov."</dssennov>";
	$xmlSetSenha .= "		<dssencon>".$dssencon."</dssencon>";
	$xmlSetSenha .= "	</Dados>";
	$xmlSetSenha .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetSenha);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSenha = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjSenha->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSenha->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	/****
	// Se o &iacute;ndice da op&ccedil;&atilde;o "@" foi encontrado 
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
	}	
	*/
	$dsmensag = "Operacao efetuada com sucesso!";
		
	
	// Se o índice da opção "@" foi encontrado 
	if (!($idPrincipal === false)) {
		echo 'showError("inform","'.$dsmensag.'","Notifica&ccedil;&atilde;o - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));acessaOpcaoAba(\''.count($glbvars["opcoesTela"]).'\',\''.$idPrincipal.'\',\''.$glbvars["opcoesTela"][$idPrincipal].'\');");';
	
	}	else {
		echo 'showError("inform","'.$dsmensag.'","Notifica&ccedil;&atilde;o - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));acessaOpcaoAba(\''.count($glbvars["opcoesTela"]).'\',0,\''.$glbvars["opcoesTela"][0].'\');");';
		
	}		
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>