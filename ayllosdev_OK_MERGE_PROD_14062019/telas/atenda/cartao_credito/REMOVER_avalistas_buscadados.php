<?php 

	/************************************************************************
	      Fonte: avalistas_buscadados.php
	      Autor: Guilherme                                                     
	      Data : Junho/2008                   &Uacute;ltima Altera&ccedil;&atilde;o:   /  /     
	                                                                       
	      Objetivo  : Carregar Dados de Avalistas - rotina de Cart&atilde;o de
					Cr&eacute;dito da tela ATENDA                               
	                                                                       	 
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["idavalis"]) || 
		!isset($_POST["nrctaava"]) || 
		!isset($_POST["form"])     ||
		!isset($_POST["nrcpfcgc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idavalis = $_POST["idavalis"];
	$nrctaava = $_POST["nrctaava"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$form = $_POST["form"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se indicador de avalista &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idavalis)) {
		exibeErro("Indicador do avalista inv&aacute;lido.");
	}
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrctaava)) {
		exibeErro("Conta/dv do avalista inv&aacute;lida.");
	}	
	
	// Verifica se n&uacute;mero do CPF &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("CPF/CNPJ do avalista inv&aacute;lido.");
	}	
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetAvalista  = "";
	$xmlGetAvalista .= "<Root>";
	$xmlGetAvalista .= "	<Cabecalho>";
	$xmlGetAvalista .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetAvalista .= "		<Proc>carrega_avalista</Proc>";
	$xmlGetAvalista .= "	</Cabecalho>";
	$xmlGetAvalista .= "	<Dados>";
	$xmlGetAvalista .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetAvalista .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetAvalista .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetAvalista .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetAvalista .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetAvalista .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetAvalista .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetAvalista .= "		<idseqttl>1</idseqttl>";
	$xmlGetAvalista .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetAvalista .= "		<nrctaava>".$nrctaava."</nrctaava>";
	$xmlGetAvalista .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlGetAvalista .= "	</Dados>";
	$xmlGetAvalista .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAvalista);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAvalista = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjAvalista->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAvalista->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$avalista = $xmlObjAvalista->roottag->tags[0]->tags[0]->tags;
	
	// Verifica se a BO retornou algum avalista e carrega os dados na tela
	if (count($avalista) > 0) {
		// Mostrar dados do avalista
		echo '$("#nrctaav'.$idavalis.'","#'.$form.'").val("'.formataNumericos("zzzz.zzz-9",$avalista[0]->cdata,".-").'");';
		echo '$("#nmdaval'.$idavalis.'","#'.$form.'").val("'.$avalista[1]->cdata.'");';
		echo '$("#nrcpfav'.$idavalis.'","#'.$form.'").val("'.formataNumericos("99999999999999",$avalista[2]->cdata,"").'");';
		echo '$("#tpdocav'.$idavalis.'","#'.$form.'").val("'.$avalista[3]->cdata.'");';
		echo '$("#dsdocav'.$idavalis.'","#'.$form.'").val("'.$avalista[4]->cdata.'");';
		echo '$("#nmdcjav'.$idavalis.'","#'.$form.'").val("'.$avalista[5]->cdata.'");';
		echo '$("#cpfcjav'.$idavalis.'","#'.$form.'").val("'.formataNumericos("99999999999999",$avalista[6]->cdata,"").'");';
		echo '$("#tdccjav'.$idavalis.'","#'.$form.'").val("'.$avalista[7]->cdata.'");';
		echo '$("#doccjav'.$idavalis.'","#'.$form.'").val("'.$avalista[8]->cdata.'");';
		echo '$("#ende1av'.$idavalis.'","#'.$form.'").val("'.$avalista[9]->cdata.'");';
		echo '$("#ende2av'.$idavalis.'","#'.$form.'").val("'.$avalista[10]->cdata.'");';
		echo '$("#nrfonav'.$idavalis.'","#'.$form.'").val("'.$avalista[11]->cdata.'");';
		echo '$("#emailav'.$idavalis.'","#'.$form.'").val("'.$avalista[12]->cdata.'");';
		echo '$("#nmcidav'.$idavalis.'","#'.$form.'").val("'.$avalista[13]->cdata.'");';
		echo '$("#cdufava'.$idavalis.'","#'.$form.'").val("'.$avalista[14]->cdata.'");';
		echo '$("#nrcepav'.$idavalis.'","#'.$form.'").val("'.formataNumericos("zzzzz-zz9",$avalista[15]->cdata,".-").'");';
	}
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>