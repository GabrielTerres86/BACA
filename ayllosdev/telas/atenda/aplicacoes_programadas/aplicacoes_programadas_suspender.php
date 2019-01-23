<?php 

	//**************************************************************************************//
	//*** Fonte: aplicacoes_programadas_suspender.php                                    ***//
	//*** Autor: David                                                                   ***//
	//*** Data : Março/2010                   Ultima Alteracao: 27/07/2018               ***//
	//***                                                                                ***//
	//*** Objetivo  : Script para suspender aplicação programada                         ***//
	//***                                                                                ***//	 
	//*** Alterações: 27/07/2018 - Derivação para Aplicação Programada                   ***//
	//***                     	   (Proj. 411.2 - CIS Corporate)                         ***// 
	//**************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["nrmesusp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$nrmesusp = $_POST["nrmesusp"];
    $cdprodut = $_POST["cdprodut"];	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupança é um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Verifica se a quantidade de meses é um inteiro válido
	if (!validaInteiro($nrmesusp)) {
		exibeErro("Quantidade de meses inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSuspender->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSuspender->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura índice da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o índice da opção "@" foi encontrado, carrega poupanças novamente
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>
