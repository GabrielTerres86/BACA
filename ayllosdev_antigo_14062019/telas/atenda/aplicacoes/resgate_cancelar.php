<?php 

	//************************************************************************************//
	//*** Fonte: resgate_cancelar.php                                      			   ***//
	//*** Autor: David                                            		   			   ***//
	//*** Data : Outubro/2009             Ultima Alteracao: 01/12/2010     			   ***//
	//***                                                                   		   ***//
	//*** Objetivo  : Script para cancelar resgate de aplicacao             		   ***//
	//***                                                                  			   ***//	 
	//*** Altera&ccedil;&otilde;es: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p ***//
	//***                                        para a BO b1wgen0081.p (Adriano)      ***//
	//************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"]) || !isset($_POST["nrdocmto"]) || !isset($_POST["dtresgat"]) || !isset($_POST["tpaplica"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];
	$nrdocmto = $_POST["nrdocmto"];
	$dtresgat = $_POST["dtresgat"];
	$tpaplica = $_POST["tpaplica"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n&uacute;mero da aplica&ccedil;&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nraplica)) {
		exibeErro("N&uacute;mero da aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
	// Verifica se o n&uacute;mero de documento do resgate &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdocmto)) {
		exibeErro("Documento do resgate inv&aacute;lido.");
	}		
	
	// Verifica se a data do resgate &eacute; v&aacute;lida
	if (!validaData($dtresgat)) {
		exibeErro("Data de resgate inv&aacute;lida.");
	}	

	if($tpaplica != "N"){
	
		// Monta o xml de requisi&ccedil;&atilde;o
		$xmlCancelResg  = "";
		$xmlCancelResg .= "<Root>";
		$xmlCancelResg .= "	<Cabecalho>";
		$xmlCancelResg .= "		<Bo>b1wgen0081.p</Bo>";
		$xmlCancelResg .= "		<Proc>cancelar-resgates-aplicacao</Proc>";
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
		$xmlCancelResg .= "		<nraplica>".$nraplica."</nraplica>";
		$xmlCancelResg .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";
		$xmlCancelResg .= "		<dtresgat>".$dtresgat."</dtresgat>";
		$xmlCancelResg .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
		$xmlCancelResg .= "	</Dados>";
		$xmlCancelResg .= "</Root>";	
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlCancelResg);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjCancelResg = getObjectXML($xmlResult);
	
	}else{
		$xmlCancelResg  = "";
		$xmlCancelResg .= "<Root>";
		$xmlCancelResg .= "	<Dados>";
		$xmlCancelResg .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlCancelResg .= "		<idseqttl>1</idseqttl>";
		$xmlCancelResg .= "		<nraplica>".$nraplica."</nraplica>";
		$xmlCancelResg .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";
		$xmlCancelResg .= "		<dtresgat>".$dtresgat."</dtresgat>";
		$xmlCancelResg .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
		$xmlCancelResg .= "	</Dados>";
		$xmlCancelResg .= "</Root>";
		
		$xmlResult = mensageria($xmlCancelResg, "ATENDA", "CANRESGT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjCancelResg = getObjectXML($xmlResult);
		
	}
	
	if(strtoupper($xmlObjCancelResg->roottag->tags[0]->name == 'ERRO')){	
		
		$msgErro = $xmlObjCancelResg->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjCancelResg->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibeErro($msgErro,$frm);			
		exit();
	}
		
	echo 'flgoprgt = true;';
		
	// Esconde mensagem de aguardo	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Carregar novamente os resgates programados
	echo 'obtemResgates(true);';
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>