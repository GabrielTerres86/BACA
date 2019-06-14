<?php 

	//************************************************************************//
	//*** Fonte: obtem_dados_avalista.php                                  ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2008                   Última Alteração: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Carregar Dados de Avalistas - rotina de Limite de    ***//
	//***             Crédito da tela ATENDA                               ***//
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($_SESSION["nmdatela"],$_SESSION["nmrotina"],"N")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idavalis"]) || !isset($_POST["nrctaava"]) || !isset($_POST["nrcpfcgc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idavalis = $_POST["idavalis"];
	$nrctaava = $_POST["nrctaava"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se indicador de avalista é um inteiro válido
	if (!validaInteiro($idavalis)) {
		exibeErro("Indicador do avalista inv&aacute;lido.");
	}
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrctaava)) {
		exibeErro("Conta/dv do avalista inv&aacute;lida.");
	}	
	
	// Verifica se número do CPF é um inteiro válido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("CPF/CNPJ do avalista inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlGetAvalista  = "";
	$xmlGetAvalista .= "<Root>";
	$xmlGetAvalista .= "	<Cabecalho>";
	$xmlGetAvalista .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlGetAvalista .= "		<Proc>obtem-dados-avalista</Proc>";
	$xmlGetAvalista .= "	</Cabecalho>";
	$xmlGetAvalista .= "	<Dados>";
	$xmlGetAvalista .= "		<cdcooper>".$_SESSION["cdcooper"]."</cdcooper>";
	$xmlGetAvalista .= "		<cdagenci>".$_SESSION["cdagenci"]."</cdagenci>";
	$xmlGetAvalista .= "		<nrdcaixa>".$_SESSION["nrdcaixa"]."</nrdcaixa>";
	$xmlGetAvalista .= "		<cdoperad>".$_SESSION["cdoperad"]."</cdoperad>";
	$xmlGetAvalista .= "		<nmdatela>".$_SESSION["nmdatela"]."</nmdatela>";
	$xmlGetAvalista .= "		<idorigem>".$_SESSION["idorigem"]."</idorigem>";	
	$xmlGetAvalista .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetAvalista .= "		<idseqttl>1</idseqttl>";
	$xmlGetAvalista .= "		<dtmvtolt>".$_SESSION["dtmvtolt"]."</dtmvtolt>";
	$xmlGetAvalista .= "		<nrctaava>".$nrctaava."</nrctaava>";
	$xmlGetAvalista .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlGetAvalista .= "	</Dados>";
	$xmlGetAvalista .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAvalista);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAvalista = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAvalista->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAvalista->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$avalista = $xmlObjAvalista->roottag->tags[0]->tags[0]->tags;
	
	// Verifica se a BO retornou algum avalista e carrega os dados na tela
	if (count($avalista) > 0) {
		// Mostrar dados do avalista
		echo '$("#nrctaav'.$idavalis.'","#frmNovoLimite").val("'.formataNumericos("zzzz.zzz-9",$avalista[0]->cdata,".-").'");';
		echo '$("#nmdaval'.$idavalis.'","#frmNovoLimite").val("'.$avalista[1]->cdata.'");';
		echo '$("#nrcpfav'.$idavalis.'","#frmNovoLimite").val("'.formataNumericos("99999999999999",$avalista[2]->cdata,"").'");';
		echo '$("#tpdocav'.$idavalis.'","#frmNovoLimite").val("'.$avalista[3]->cdata.'");';
		echo '$("#dsdocav'.$idavalis.'","#frmNovoLimite").val("'.$avalista[4]->cdata.'");';
		echo '$("#nmdcjav'.$idavalis.'","#frmNovoLimite").val("'.$avalista[5]->cdata.'");';
		echo '$("#cpfcjav'.$idavalis.'","#frmNovoLimite").val("'.formataNumericos("99999999999999",$avalista[6]->cdata,"").'");';
		echo '$("#tdccjav'.$idavalis.'","#frmNovoLimite").val("'.$avalista[7]->cdata.'");';
		echo '$("#doccjav'.$idavalis.'","#frmNovoLimite").val("'.$avalista[8]->cdata.'");';
		echo '$("#ende1av'.$idavalis.'","#frmNovoLimite").val("'.$avalista[9]->cdata.'");';
		echo '$("#ende2av'.$idavalis.'","#frmNovoLimite").val("'.$avalista[10]->cdata.'");';
		echo '$("#nrfonav'.$idavalis.'","#frmNovoLimite").val("'.$avalista[11]->cdata.'");';
		echo '$("#emailav'.$idavalis.'","#frmNovoLimite").val("'.$avalista[12]->cdata.'");';
		echo '$("#nmcidav'.$idavalis.'","#frmNovoLimite").val("'.$avalista[13]->cdata.'");';
		echo '$("#cdufava'.$idavalis.'","#frmNovoLimite").val("'.$avalista[14]->cdata.'");';
		echo '$("#nrcepav'.$idavalis.'","#frmNovoLimite").val("'.formataNumericos("zzzzz-zz9",$avalista[15]->cdata,".-").'");';
	}
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>