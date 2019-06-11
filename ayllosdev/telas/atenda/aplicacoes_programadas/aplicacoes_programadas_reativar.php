<?php 

	//************************************************************************//
	//*** Fonte: aplicacoes_programadas_reativar.php                       ***//
	//*** Autor: David                                                     ***//
	//*** Data : Março/2010                   Última Alteração: 27/07/2018 ***//
	//***                                                                  ***//
	//*** Objetivo  : Script para reativar aplicação programada            ***//
	//***                                                                  ***//	 
	//*** Alterações: 27/07/2018 - Derivação para Aplicação Programada     ***//
	//****                         (Proj. 411.2 - CIS Corporate)           ***//  
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$cdprodut = $_POST["cdprodut"];	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupança é um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjReativar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjReativar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura índice da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o índice da opção "@" foi encontrado, carrega aplicações novamente
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
