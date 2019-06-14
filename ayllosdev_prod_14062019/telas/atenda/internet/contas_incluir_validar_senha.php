<?php 
	//************************************************************************//
	//*** Fonte: contas_incluir_validar_senha.php      	               ***//
	//*** Autor: Lucas                                                     ***//
	//*** Data : Maio/2012                   Última Alteração:             ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar senha na inclusao de contas de tranferencia  ***//
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
	$cddsenha = $_POST["cdsnhnew"];
	$cdsnhrep = $_POST["cdsnhrep"];
	$cddbanco = $_POST["cddbanco"];
	$cdageban = $_POST["cdageban"];
	$nmtitula = $_POST["nmtitula"];
	$dscpfcgc = $_POST["dscpfcgc"];
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
	$xmlGetPendentes .= "		<Proc>verifica-senha-internet</Proc>";
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
	$xmlGetPendentes .= "		<cddsenha>".$cddsenha."</cddsenha>";
	$xmlGetPendentes .= "		<cdsnhrep>".$cdsnhrep."</cdsnhrep>";
	$xmlGetPendentes .= "	</Dados>";
	$xmlGetPendentes .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPendentes);

	// Cria objeto para classe de tratamento de XML
	$xmlObjPendentes = getObjectXML($xmlResult);
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","focaCampoErro(\'cdsnhnew\',\'frmSnhIncluirConta\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPendentes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPendentes->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
	} 
	
	echo 'hideMsgAguardo();';
?>

	$("#divConteudoOpcao").html('');	
	strHTML = '';	
	strHTML += '<form id="InclDados" name="InclDados" style="display: none;">';
	strHTML += '	<input type="hidden" name="nrdconta" id="nrdconta" value = "<? echo $nrdconta ?>" />';
	strHTML += '	<input type="hidden" name="idseqttl" id="idseqttl" value = "<? echo $idseqttl ?>" />';
	strHTML += '	<input type="hidden" name="dscpfcgc" id="dscpfcgc" value = "<? echo $dscpfcgc ?>" />';
	strHTML += '	<input type="hidden" name="nmtitula" id="nmtitula" value = "<? echo $nmtitula ?>" />';
	strHTML += '	<input type="hidden" name="cddbanco" id="cddbanco" value = "<? echo $cddbanco ?>" />';
	strHTML += '	<input type="hidden" name="cdageban" id="cdageban" value = "<? echo $cdageban ?>" />';
	strHTML += '	<input type="hidden" name="intipdif" id="intipdif" value = "<? echo $intipdif ?>" />';
	strHTML += '	<input type="hidden" name="nrctatrf" id="nrctatrf" value = "<? echo $nrctatrf ?>" />';
	strHTML += '	<input type="hidden" name="inpessoa" id="inpessoa" value = "<? echo $inpessoa ?>" />';
	strHTML += '	<input type="hidden" name="nrcpfcgc" id="nrcpfcgc" value = "<? echo $nrcpfcgc ?>" />';
	strHTML += '	<input type="hidden" name="intipcta" id="intipcta" value = "<? echo $intipcta ?>" />';
	strHTML += '	<input type="hidden" name="cdispbif" id="cdispbif" value = "<? echo $cdispbif ?>" />';
	strHTML += '</form>';
	$("#divConteudoOpcao").html(strHTML);

<?

	//Decide que função chamar dependendo do tipo de IF.
	if ($intipdif == "1"){
	
		echo 'mostraDadosFormIncl("frmInclCoop");';
		
	} else {
	
		echo 'mostraDadosFormIncl("frmInclOtr");';
		
	}
	
?>