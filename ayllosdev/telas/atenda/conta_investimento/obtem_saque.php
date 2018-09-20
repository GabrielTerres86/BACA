<?php 

	//************************************************************************//
	//*** Fonte: obtem_saque.php                                           ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 &Uacute;ltima Altera&ccedil;&atilde;o: 06/10/2008 ***//
	//***                                                                  ***//
	//*** Objetivo  : Confirmar saque da rotina de Conta Investimento da   ***//
	//****						tela ATENDA                 												 ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es: 06/10/2008 - Validar aplica&ccedil;&otilde;es bloqueadas (David).  ***//
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["vlresgat"]) || !isset($_POST["inconfir"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$vlresgat = $_POST["vlresgat"];
	$inconfir = $_POST["inconfir"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se valor do resgate &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vlresgat)) {
		exibeErro("Valor do Saque inv&aacute;lido.");
	}
	
	// Verifica se indicador de confirma&ccedil;&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($inconfir)) {
		exibeErro("Indicador de confirma&ccedil;&atilde;o inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetSaque  = "";
	$xmlSetSaque .= "<Root>";
	$xmlSetSaque .= "	<Cabecalho>";
	$xmlSetSaque .= "		<Bo>b1wgen0020.p</Bo>";
	$xmlSetSaque .= "		<Proc>obtem-resgate</Proc>";
	$xmlSetSaque .= "	</Cabecalho>";
	$xmlSetSaque .= "	<Dados>";
	$xmlSetSaque .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetSaque .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetSaque .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetSaque .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetSaque .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetSaque .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetSaque .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetSaque .= "		<idseqttl>1</idseqttl>";
	$xmlSetSaque .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetSaque .= "		<vlresgat>".$vlresgat."</vlresgat>";
	$xmlSetSaque .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlSetSaque .= "	</Dados>";
	$xmlSetSaque .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetSaque);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSaque = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjSaque->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSaque->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	// Mostra se Bo retornar mensagem de confirma&ccedil;&atilde;o
	if (strtoupper($xmlObjSaque->roottag->tags[0]->name) == "CONFIRMACAO") {
		$confirma = $xmlObjSaque->roottag->tags[0]->tags[0]->tags;		
		
		// Se for aviso de aplica&ccedil;&atilde;o bloqueada, mostra mensagem de confirma&ccedil;&atilde;o e pede senha do coordenador para confirmar
		if ($confirma[0]->cdata == "1") {
			echo 'hideMsgAguardo();';
			echo 'showConfirmacao("'.$confirma[1]->cdata.'","Confirma&ccedil;&atilde;o - Aimaro","pedeSenhaCoordenador(2,\'confirmaSaque(2)\',\'divRotina\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
			exit();			
		} 
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