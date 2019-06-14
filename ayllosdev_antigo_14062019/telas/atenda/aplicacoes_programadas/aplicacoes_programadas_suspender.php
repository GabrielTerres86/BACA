<?php 

	//**************************************************************************************//
	//*** Fonte: aplicacoes_programadas_suspender.php                                    ***//
	//*** Autor: David                                                                   ***//
	//*** Data : Mar�o/2010                   Ultima Alteracao: 27/07/2018               ***//
	//***                                                                                ***//
	//*** Objetivo  : Script para suspender aplica��o programada                         ***//
	//***                                                                                ***//	 
	//*** Altera��es: 27/07/2018 - Deriva��o para Aplica��o Programada                   ***//
	//***                     	   (Proj. 411.2 - CIS Corporate)                         ***// 
	//**************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["nrmesusp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$nrmesusp = $_POST["nrmesusp"];
    $cdprodut = $_POST["cdprodut"];	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupan�a � um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Verifica se a quantidade de meses � um inteiro v�lido
	if (!validaInteiro($nrmesusp)) {
		exibeErro("Quantidade de meses inv&aacute;lida.");
	}
	
	// Monta o xml de requisi��o
	$xmlSuspender  = "";
	$xmlSuspender .= "<Root>";
	$xmlSuspender .= "	<Cabecalho>";
	$xmlSuspender .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlSuspender .= "		<Proc>suspender-poupanca</Proc>";
	$xmlSuspender .= "	</Cabecalho>";
	$xmlSuspender .= "	<Dados>";
	$xmlSuspender .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSuspender .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSuspender .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSuspender .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSuspender .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSuspender .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSuspender .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSuspender .= "		<idseqttl>1</idseqttl>";
	$xmlSuspender .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";	
	$xmlSuspender .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlSuspender .= "		<nrmesusp>".$nrmesusp."</nrmesusp>";	
	$xmlSuspender .= "	</Dados>";
	$xmlSuspender .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSuspender);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSuspender = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjSuspender->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSuspender->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura �ndice da op��o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o �ndice da op��o "@" foi encontrado, carrega poupan�as novamente
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>
