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
	//****                                                                 ***//  
	//****            07/06/2019 - Alterado para chamar o Oracle           ***//
	//****                         (Anderson)                              ***//  
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
	
    $xmlReativar  = "";
	$xmlReativar .= "<Root>";
	$xmlReativar .= "	<Dados>";
	$xmlReativar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlReativar .= "		<idseqttl>1</idseqttl>";
	$xmlReativar .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";	
	$xmlReativar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlReativar .= "        <flgerlog>1</flgerlog>"; 
	$xmlReativar .= "	</Dados>";
	$xmlReativar .= "</Root>";	
  
    $xmlResult = mensageria($xmlReativar, "APLI0008", "REATIVA_APL_PROG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjReativar = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObjReativar->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjReativar->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
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
