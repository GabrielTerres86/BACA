<?php 

	//************************************************************************//
	//*** Fonte: aplicacoes_programadas_reativar.php                       ***//
	//*** Autor: David                                                     ***//
	//*** Data : Mar�o/2010                   �ltima Altera��o: 27/07/2018 ***//
	//***                                                                  ***//
	//*** Objetivo  : Script para reativar aplica��o programada            ***//
	//***                                                                  ***//	 
	//*** Altera��es: 27/07/2018 - Deriva��o para Aplica��o Programada     ***//
	//****                         (Proj. 411.2 - CIS Corporate)           ***//  
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$cdprodut = $_POST["cdprodut"];	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupan�a � um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi��o
	$xmlReativar  = "";
	$xmlReativar .= "<Root>";
	$xmlReativar .= "	<Cabecalho>";
	$xmlReativar .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlReativar .= "		<Proc>reativar-aplicacao-programada</Proc>";
	$xmlReativar .= "	</Cabecalho>";
	$xmlReativar .= "	<Dados>";
	$xmlReativar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlReativar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlReativar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlReativar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlReativar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlReativar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlReativar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlReativar .= "		<idseqttl>1</idseqttl>";
	$xmlReativar .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";	
	$xmlReativar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlReativar .= "	</Dados>";
	$xmlReativar .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlReativar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjReativar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjReativar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjReativar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura �ndice da op��o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o �ndice da op��o "@" foi encontrado, carrega aplica��es novamente
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