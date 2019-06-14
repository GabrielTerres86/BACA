<?php 

	//************************************************************************//
	//*** Fonte: atualizar_preposto.php                                    ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2008                   &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Atualizar Preposto para InternetBank - Rotina de     ***//
	//***             Internet da tela ATENDA)                             ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es:                                                      ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) || !isset($_POST["nrcpfcgc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}
	
	// Verifica se CPF do preposto &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("CPF do preposto inv&aacute;lido.");
	}		
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPreposto  = "";
	$xmlSetPreposto .= "<Root>";
	$xmlSetPreposto .= "	<Cabecalho>";
	$xmlSetPreposto .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlSetPreposto .= "		<Proc>atualizar-preposto</Proc>";
	$xmlSetPreposto .= "	</Cabecalho>";
	$xmlSetPreposto .= "	<Dados>";
	$xmlSetPreposto .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPreposto .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPreposto .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPreposto .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPreposto .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetPreposto .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetPreposto .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetPreposto .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlSetPreposto .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlSetPreposto .= "	</Dados>";
	$xmlSetPreposto .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPreposto);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPreposto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPreposto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPreposto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Confirma altera&ccedil;&atilde;o dos dados da habilita&ccedil;&atilde;o
	echo 'confirmaAlteracaoLimites();';
		
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>