<?php 

	//************************************************************************//
	//*** Fonte: contas_incluir_confirmar.php      	                       ***//
	//*** Autor: Lucas                                                     ***//
	//*** Data : Maio/2012                   Última Alteração: 	       ***//
	//***                                                                  ***//
	//*** Objetivo  : Realizar a inclusao de contas de trsansf.	       ***//
	//***                                                                  ***//	 
	//***                                                                  ***//	 
	//*** Alterações: 24/04/2015 - Inclusão do campo ISPB SD271603         ***// 
        //***                          FDR041 (Vanessa)                        ***//											   ***//	 
	//***                                                                  ***//
	//***                                                                  ***//
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
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) ||
		!isset($_POST["nrctatrf"]) || !isset($_POST["intipdif"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}
		
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$nrctatrf = $_POST["nrctatrf"];
	$intipdif = $_POST["intipdif"];	
	$cddbanco = $_POST["cddbanco"];
	$cdageban = $_POST["cdageban"];
	$nmtitula = $_POST["nmtitula"];
	$inpessoa = $_POST["inpessoa"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$intipcta = $_POST["intipcta"];
     $cdispbif = $_POST["cdispbif"];
	
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetPendentes  = "";
	$xmlGetPendentes .= "<Root>";
	$xmlGetPendentes .= "	<Cabecalho>";
	$xmlGetPendentes .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlGetPendentes .= "		<Proc>inclui-conta-transferencia</Proc>";
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
	$xmlGetPendentes .= "		<cddbanco>".$cddbanco."</cddbanco>";
	$xmlGetPendentes .= "		<cdageban>".$cdageban."</cdageban>";
	$xmlGetPendentes .= "		<nrctatrf>".$nrctatrf."</nrctatrf>";
	$xmlGetPendentes .= "		<nmtitula>".$nmtitula."</nmtitula>";
	$xmlGetPendentes .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlGetPendentes .= "		<inpessoa>".$inpessoa."</inpessoa>";
	$xmlGetPendentes .= "		<intipcta>".$intipcta."</intipcta>";
	$xmlGetPendentes .= "		<intipdif>".$intipdif."</intipdif>";
    $xmlGetPendentes .= "		<cdispbif>".$cdispbif."</cdispbif>";
	$xmlGetPendentes .= "		<insitcta>2</insitcta>";
	$xmlGetPendentes .= "	</Dados>";
	$xmlGetPendentes .= "</Root>"; 

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPendentes);

	// Cria objeto para classe de tratamento de XML
	$xmlObjPendentes = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPendentes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPendentes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$msgaviso = $xmlObjPendentes->roottag->tags[0]->attributes["MSGAVISO"];
	
	echo 'hideMsgAguardo();';
	
	if (trim($msgaviso) <> "") {
		echo 'showError("inform","'.$msgaviso.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));InclusaoContas()");';
	} else {
		// Esconde mensagem de aguardo
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
		echo 'InclusaoContas();';
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>