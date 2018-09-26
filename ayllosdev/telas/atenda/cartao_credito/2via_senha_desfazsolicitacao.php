<?php 

	//************************************************************************//
	//*** Fonte: 2via_senha_desfazsolicitacao.php                          ***//
	//*** Autor: David                                                     ***//
	//*** Data : Setembro/2008                &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Desfazer solicita&ccedil;&atilde;o de 2via de Senha da rotina de   ***//
	//***             Cart&otilde;es de Cr&eacute;dito da tela ATENDA                    ***//
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
	
	// Verifica permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se n&uacute;mero do contrato &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDesfazSolicitacao  = "";
	$xmlDesfazSolicitacao .= "<Root>";
	$xmlDesfazSolicitacao .= "	<Cabecalho>";
	$xmlDesfazSolicitacao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlDesfazSolicitacao .= "		<Proc>desfaz_solici2via_senha</Proc>";
	$xmlDesfazSolicitacao .= "	</Cabecalho>";
	$xmlDesfazSolicitacao .= "	<Dados>";
	$xmlDesfazSolicitacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDesfazSolicitacao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDesfazSolicitacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDesfazSolicitacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDesfazSolicitacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDesfazSolicitacao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlDesfazSolicitacao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDesfazSolicitacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlDesfazSolicitacao .= "		<idseqttl>1</idseqttl>";
	$xmlDesfazSolicitacao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDesfazSolicitacao .= "	</Dados>";
	$xmlDesfazSolicitacao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDesfazSolicitacao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDesfazSolicitacao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDesfazSolicitacao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDesfazSolicitacao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@" - Principal
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);

	// Se o &iacute;ndice da op&ccedil;&atilde;o "@" foi encontrado - Carrega o principal novamente.
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