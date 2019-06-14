<?php 

	//************************************************************************//
	//*** Fonte: impressao.php                                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2008                   &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Emitir Contrato de Permiss&atilde;o de Uso do InternetBank  ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es:                                                      ***//
	//************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		?><script language="javascript">alert('Sequ&ecirc;ncia de titular inv&aacute;lida.');</script><?php
		exit();
	}
	
	$dsiduser = session_id();
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosContrato  = "";
	$xmlDadosContrato .= "<Root>";
	$xmlDadosContrato .= "	<Cabecalho>";
	$xmlDadosContrato .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlDadosContrato .= "		<Proc>gera-termo-responsabilidade</Proc>";
	$xmlDadosContrato .= "	</Cabecalho>";
	$xmlDadosContrato .= "	<Dados>";
	$xmlDadosContrato .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosContrato .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosContrato .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosContrato .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosContrato .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlDadosContrato .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosContrato .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlDadosContrato .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlDadosContrato .= "		<dsiduser>".$dsiduser."</dsiduser>";
	$xmlDadosContrato .= "	</Dados>";
	$xmlDadosContrato .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosContrato);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosContrato = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosContrato->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosContrato->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
		exit();
	} 

	$pdffile = $xmlObjDadosContrato->roottag->tags[0]->attributes["NMARQIMP"];
	
	visualizaPDF($pdffile); 

?>