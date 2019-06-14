<?php 

	//************************************************************************//
	//*** Fonte: contas_cadastradas_alterar_confirmar.php                  ***//
	//*** Autor: Lucas                                                     ***//
	//*** Data : Maio/2012                   Última Alteração: 		       ***//
	//***                                                                  ***//
	//*** Objetivo  : Alterar a sit. de contas de transf. cadastradas	   ***//
	//***                                                                  ***//	 
	//***                                                                  ***//	 
	//*** Alterações: 													   ***//	 
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
	if (!isset($_POST["intipdif"]) || !isset($_POST["insitcta"]) ||
		!isset($_POST["nrctatrf"]) || !isset($_POST["nrdconta"]) ||
		!isset($_POST["idseqttl"]) || !isset($_POST["cddbanco"]) ||
		!isset($_POST["cdageban"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$cddbanco = $_POST["cddbanco"];
	$cdageban = $_POST["cdageban"];
	$intipdif = $_POST["intipdif"];
	$insitcta = $_POST["insitcta"];
	$nrctatrf = $_POST["nrctatrf"];	
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$ifsnmtit = $_POST["nmtitula"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$inpessoa = $_POST["inpessoa"];
	$intipcta = $_POST["intipcta"];
		
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
	$xmlGetPendentes .= "		<Proc>altera-dados-cont-cadastrada</Proc>";
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
	$xmlGetPendentes .= "		<nmtitula>".$ifsnmtit."</nmtitula>";
	$xmlGetPendentes .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlGetPendentes .= "		<inpessoa>".$inpessoa."</inpessoa>";
	$xmlGetPendentes .= "		<intipcta>".$intipcta."</intipcta>";
	$xmlGetPendentes .= "		<insitcta>".$insitcta."</insitcta>";
	$xmlGetPendentes .= "		<intipdif>".$intipdif."</intipdif>";
	$xmlGetPendentes .= "		<cddbanco>".$cddbanco."</cddbanco>";
	$xmlGetPendentes .= "		<cdageban>".$cdageban."</cdageban>";
	$xmlGetPendentes .= "		<nrctatrf>".$nrctatrf."</nrctatrf>";
	$xmlGetPendentes .= "	</Dados>";
	$xmlGetPendentes .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPendentes);
	$xmlObjPendentes = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPendentes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPendentes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	// Esconde mensagem de aguardo e retorna para a tela
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	echo 'obtemCntsCad("'.$intipdif.'", 0, 50);';
	
?>