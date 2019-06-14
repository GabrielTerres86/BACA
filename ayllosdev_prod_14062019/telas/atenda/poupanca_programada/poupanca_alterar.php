<?php 

	//************************************************************************//
	//*** Fonte: poupanca_alterar.php                                      ***//
	//*** Autor: David                                                     ***//
	//*** Data : Mar�o/2010                   �ltima Altera��o: 20/06/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Script para alterar poupan�a programada              ***//
	//***                                                                  ***//	 
	//*** Altera��es: 20/06/2012 - Adicionado confirmacao para impressao   ***//
	//***						   (Jorge)								   ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["vlprerpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$vlprerpp = $_POST["vlprerpp"];	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupan�a � um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Verifica se o valor da presta��o � um decimal v�lido
	if (!validaDecimal($vlprerpp)) {
		exibeErro("Valor de presta&ccedil;&atilde;o inv&aacute;lido.");
	}
	
	// Monta o xml de requisi��o
	$xmlAlterar  = "";
	$xmlAlterar .= "<Root>";
	$xmlAlterar .= "	<Cabecalho>";
	$xmlAlterar .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlAlterar .= "		<Proc>alterar-poupanca-programada</Proc>";
	$xmlAlterar .= "	</Cabecalho>";
	$xmlAlterar .= "	<Dados>";
	$xmlAlterar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAlterar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlAlterar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAlterar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAlterar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAlterar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlAlterar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAlterar .= "		<idseqttl>1</idseqttl>";
	$xmlAlterar .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";	
	$xmlAlterar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlAlterar .= "		<vlprerpp>".$vlprerpp."</vlprerpp>";	
	$xmlAlterar .= "	</Dados>";
	$xmlAlterar .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAlterar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAlterar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjAlterar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$nrdrowid = $xmlObjAlterar->roottag->tags[0]->attributes["NRDROWID"];
	
	// Procura �ndice da op��o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o �ndice da op��o "@" foi encontrado, carrega poupan�as novamente
	if (!($idPrincipal === false)) {
		$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',\''.$glbvars["opcoesTela"][$idPrincipal].'\');';
	}	else {
		$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';				
	
	echo "callafterPoupanca = \"".$acessaaba."\";";
	
	// Efetua a impress�o do termo de entrega
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","imprimirAutorizacao(\''.$nrdrowid.'\',\'1\');","'.$acessaaba.'","sim.gif","nao.gif");';	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>