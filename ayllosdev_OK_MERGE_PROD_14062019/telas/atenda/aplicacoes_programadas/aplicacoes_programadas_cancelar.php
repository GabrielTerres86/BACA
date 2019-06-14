<?php 

	//************************************************************************************************************//
	//*** Fonte: aplicacoes_programadas_cancelar.php                                                           ***//
	//*** Autor: David                                                                                         ***//
	//*** Data : Março/2010                   Ultima Alteracao: 27/07/2018                                     ***//
	//***                                                                                                      ***//
	//*** Objetivo  : Script para cancelar aplicacao programada                                                ***//
	//***                                                                                                      ***//	 
	//*** Alterações:                                                                                          ***//
	//***			  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)     ***//
	//***             27/07/2018 - Derivação para Aplicação Programada                                         ***//
    //***                          (Proj. 411.2 - CIS Corporate)             								   ***//
	//************************************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
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
	$xmlCancelar  = "";
	$xmlCancelar .= "<Root>";
	$xmlCancelar .= "	<Cabecalho>";
	$xmlCancelar .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlCancelar .= "		<Proc>cancelar-poupanca</Proc>";
	$xmlCancelar .= "	</Cabecalho>";
	$xmlCancelar .= "	<Dados>";
	$xmlCancelar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCancelar .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlCancelar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCancelar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCancelar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCancelar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlCancelar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlCancelar .= "		<idseqttl>1</idseqttl>";
	$xmlCancelar .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";	
	$xmlCancelar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlCancelar .= "	</Dados>";
	$xmlCancelar .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCancelar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCancelar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCancelar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCancelar->roottag->tags[0]->tags[0]->tags[4]->cdata);
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
