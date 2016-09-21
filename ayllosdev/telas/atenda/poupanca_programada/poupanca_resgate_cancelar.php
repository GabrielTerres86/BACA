<?php 

	//************************************************************************//
	//*** Fonte: resgate_cancelar.php                                      ***//
	//*** Autor: David                                                     ***//
	//*** Data : Mar�o/2010                   �ltima Altera��o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Script para cancelar resgate de poupan�a programada  ***//
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["nrdocmto"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	$nrdocmto = $_POST["nrdocmto"];	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupan�a � um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}		
	
	// Verifica se o n�mero de documento do resgate � um inteiro v�lido
	if (!validaInteiro($nrdocmto)) {
		exibeErro("Documento do resgate inv&aacute;lido.");
	}			

	// Monta o xml de requisi��o
	$xmlCancelResg  = "";
	$xmlCancelResg .= "<Root>";
	$xmlCancelResg .= "	<Cabecalho>";
	$xmlCancelResg .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlCancelResg .= "		<Proc>cancelar-resgate</Proc>";
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
	$xmlCancelResg .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlCancelResg .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";		
	$xmlCancelResg .= "	</Dados>";
	$xmlCancelResg .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCancelResg);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCancelResg = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCancelResg->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCancelResg->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	echo 'flgoprgt = true;';
		
	// Esconde mensagem de aguardo	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Carregar novamente os resgates programados
	echo 'obtemResgates("yes");';
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>