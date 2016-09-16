<?php 

	//****************************************************************************//
	//*** Fonte: contas_pendentes_confirmar.php 	                           ***//
	//*** Autor: Lucas                                                         ***//
	//*** Data : Abril/2012                   Última Alteração: 18/12/2014     ***//
	//***                                                                      ***//
	//*** Objetivo  : Confirmar as contas pendentes selecionadas		       ***//
	//***                                                                      ***//	 
	//*** Alterações: 18/12/2014 - Incluindo paginacao na funcao               ***//
    //***                          obtemCntsPendentes. Melhorias Cadastro      ***//
    //***                          de Favorecidos TED.(André Santos - SUPERO)  ***//
	//***                                                                      ***//	 
	//***                                                                      ***//	 
	//****************************************************************************//
	
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);
		}
	
		// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}
	
	$camposDc 	= (isset($_POST['camposDc']))  ? $_POST['camposDc']  : '' ; // ContasPendentes
	$dadosDc 	= (isset($_POST['dadosDc']))   ? $_POST['dadosDc']   : '' ; // ContasPendentes
	

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetPendentes  = "";
	$xmlGetPendentes .= "<Root>";
	$xmlGetPendentes .= "	<Cabecalho>";
	$xmlGetPendentes .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlGetPendentes .= "		<Proc>confirma-contas-pendentes</Proc>";
	$xmlGetPendentes .= "	</Cabecalho>";
	$xmlGetPendentes .= "	<Dados>";
	$xmlGetPendentes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetPendentes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetPendentes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetPendentes .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetPendentes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlGetPendentes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetPendentes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetPendentes .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlGetPendentes .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetPendentes .= 		retornaXmlFilhos( $camposDc, $dadosDc, 'CntsPend', 'Itens');
	$xmlGetPendentes .= "	</Dados>";
	$xmlGetPendentes .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPendentes);
	$xmlObjPendentes = getObjectXML($xmlResult);
	
	$msgaviso = $xmlObjPendentes->roottag->tags[0]->attributes["MSGAVISO"];
	
	echo 'hideMsgAguardo();';
	
	if (trim($msgaviso) <> "") {
		echo 'showError("inform","'.$msgaviso.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));obtemCntsPendentes(\'1\',\'10\')");';
	} else {
		// Esconde mensagem de aguardo
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
		echo 'obtemCntsPendentes(\'1\',\'10\');';
	}

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPendentes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPendentes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	

?>
