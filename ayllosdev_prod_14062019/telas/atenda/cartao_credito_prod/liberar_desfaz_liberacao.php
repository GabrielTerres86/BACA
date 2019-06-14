<?php 

	/************************************************************************
	 Fonte: liberar_desfaz_liberacao.php
	 Autor: Guilherme
	 Data : Abril/2008                 &Uacute;ltima Altera&ccedil;&atilde;o:   /  /

	 Objetivo  : Desfaz a libera&ccedil;&atilde;o de cart&atilde;o da rotina de Cart&otilde;es de Cr&eacute;dito da tela 
			ATENDA

	      Altera&ccedil;&otilde;es:
	  ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	// Verifica permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"L")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["nrdconta"]) ||
    !isset($_POST["nrctrcrd"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se n&uacute;mero do contrato &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetLiberacao  = "";
	$xmlSetLiberacao .= "<Root>";
	$xmlSetLiberacao .= "	<Cabecalho>";
	$xmlSetLiberacao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetLiberacao .= "		<Proc>desfaz_liberacao_cartao</Proc>";
	$xmlSetLiberacao .= "	</Cabecalho>";
	$xmlSetLiberacao .= "	<Dados>";
	$xmlSetLiberacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetLiberacao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetLiberacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetLiberacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetLiberacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetLiberacao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetLiberacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetLiberacao .= "		<idseqttl>1</idseqttl>";
	$xmlSetLiberacao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetLiberacao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetLiberacao .= "	</Dados>";
	$xmlSetLiberacao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetLiberacao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLiberacao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjLiberacao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLiberacao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@" - Principal
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o &iacute;ndice da op&ccedil;&atilde;o "@" foi encontrado - Carrega o principal novamente.
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