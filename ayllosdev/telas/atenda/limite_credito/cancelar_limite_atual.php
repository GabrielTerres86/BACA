<?php 

	//************************************************************************//
	//*** Fonte: cancelar_limite_atual.php                                 ***//
	//*** Autor: David                                                     ***//
	//*** Data : Mar�o/2008                   �ltima Altera��o: 15/06/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Cancelar Limite de Cr�dito Atual - rotina de Limite  ***//
	//***             de Cr�dito da tela ATENDA                            ***//
	//***                                                                  ***//	 
	//*** Altera��es: 16/09/2010 - Ajuste para enviar impressoes via email ***//
	//***                          para o PAC Sede (David).                ***//
	//***																   ***//
	//***			  15/06/2012 - Adicionado confirmacao para impressao   ***//
	//***						   do termo de cancelamento. (Jorge)       ***//
    //***             17/06/2016 - M181 - Alterar o CDAGENCI para          ***//
    //***                         passar o CDPACTRA (Rafael Maciel - RKAM) ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	// PRJ 470
	$vllimite = isset($_POST["vllimite"]) ? $_POST["vllimite"] : 0;
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("Contrato inv&aacute;lido.");
	}
	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura ind�ce da op��o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o �ndice da op��o "@" foi encontrado 
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
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>