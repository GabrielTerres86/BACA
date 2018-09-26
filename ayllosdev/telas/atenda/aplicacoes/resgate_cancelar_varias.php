<?php 

	//************************************************************************//
	//*** Fonte: resgate_cancelar_varias.php                               ***//
	//*** Autor: Jorge                                                     ***//
	//*** Data : Agosto/2011                 Ultima Alteracao: 00/00/0000  ***//
	//***                                                                  ***//
	//*** Objetivo  : Script para cancelar varios resgates de aplicacao    ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 													   ***//
	//***                                        						   ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variaveis globais de controle, e biblioteca de funcoes	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parametros necessarios nao foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["camposPc"]) || !isset($_POST["dadosPrc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$camposPc = $_POST["camposPc"];
	$dadosPrc = $_POST["dadosPrc"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	if((count($camposPc) == 0) || (count($dadosPrc) == 0)){
		exibeErro("Resgate(s) n&atilde;o encontrado(s).");
	}	
	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlCancelResg  = "";
	$xmlCancelResg .= "<Root>";
	$xmlCancelResg .= "	<Cabecalho>";
	$xmlCancelResg .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlCancelResg .= "		<Proc>cancelar-varias-resgates-aplicacao</Proc>";
	$xmlCancelResg .= "	</Cabecalho>";
	$xmlCancelResg .= "	<Dados>";
	$xmlCancelResg .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCancelResg .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCancelResg .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCancelResg .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCancelResg .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCancelResg .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlCancelResg .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlCancelResg .= "		<idseqttl>1</idseqttl>";
	$xmlCancelResg .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlCancelResg .= retornaXmlFilhos( $camposPc, $dadosPrc, 'Resgates', 'Itens');
	$xmlCancelResg .= "	</Dados>";
	$xmlCancelResg .= "</Root>";
	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCancelResg);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCancelResg = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjCancelResg->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCancelResg->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	echo 'flgoprgt = true;';
		
	// Esconde mensagem de aguardo	
	echo 'hideMsgAguardo();';
	echo 'showError("inform","Resgate(s) cancelado(s) com sucesso!","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	
	// Carregar novamente os resgates programados
	echo 'obtemResgatesVarias(true);';
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>