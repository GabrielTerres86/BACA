<?php 

	//************************************************************************//
	//*** Fonte: cancelar_limite_atual.php                                 ***//
	//*** Autor: David                                                     ***//
	//*** Data : Março/2008                   Última Alteração: 15/06/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Cancelar Limite de Crédito Atual - rotina de Limite  ***//
	//***             de Crédito da tela ATENDA                            ***//
	//***                                                                  ***//	 
	//*** Alterações: 16/09/2010 - Ajuste para enviar impressoes via email ***//
	//***                          para o PAC Sede (David).                ***//
	//***																   ***//
	//***			  15/06/2012 - Adicionado confirmacao para impressao   ***//
	//***						   do termo de cancelamento. (Jorge)       ***//
    //***             17/06/2016 - M181 - Alterar o CDAGENCI para          ***//
    //***                         passar o CDPACTRA (Rafael Maciel - RKAM) ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	// PRJ 470
	$vllimite = isset($_POST["vllimite"]) ? $_POST["vllimite"] : 0;
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("Contrato inv&aacute;lido.");
	}
	
	// Monta o xml de requisição
	$xmlCancelarLimite  = "";
	$xmlCancelarLimite .= "<Root>";
	$xmlCancelarLimite .= "	<Cabecalho>";
	$xmlCancelarLimite .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlCancelarLimite .= "		<Proc>cancelar-limite-atual</Proc>";
	$xmlCancelarLimite .= "	</Cabecalho>";
	$xmlCancelarLimite .= "	<Dados>";
	$xmlCancelarLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCancelarLimite .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlCancelarLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCancelarLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCancelarLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCancelarLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlCancelarLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlCancelarLimite .= "		<idseqttl>1</idseqttl>";
	$xmlCancelarLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlCancelarLimite .= "	</Dados>";
	$xmlCancelarLimite .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCancelarLimite);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura indíce da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o índice da opção "@" foi encontrado 
	// if (!($idPrincipal === false)) {
	// 	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',\''.$glbvars["opcoesTela"][$idPrincipal].'\');';
	// }	else {
	// 	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	// }
	//bruno - prj 438 - sprint 7 - tela principal
	$acessaaba = 'acessaTela(\'@\');';
	
	echo "callafterLimiteCred = \"".$acessaaba."\";";
	
	// Mostra confirmacao de impressao do termo de rescis?o do contrato
	// echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","carregarImpresso(4,\'no\',\'no\',\''.$nrctrlim.'\');","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));'.$acessaaba.'","sim.gif","nao.gif");';	
	// PRJ 470
	//echo 'chamarMostraTelaAutorizacaoContrato("carregarImpresso(4,\'no\',\'no\',\''.$nrctrlim.'\');");';
	//bruno - prj 470 - tela autorizacao
	echo 'chamarImpressaoLimiteCredito(true);';
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>