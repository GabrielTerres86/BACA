<?php 

	//************************************************************************//
	//*** Fonte: termo_adesao.php                                          ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2008                   Ultima Alteracao: 12/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Emitir Termo de Adesao de Uso do InternetBank        ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 12/07/2012 - Alterado parametro de $pdf->Output,     ***//  
	//***   					   Condicao para  Navegador Chrome (Jorge).***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
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
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosAdesao  = "";
	$xmlDadosAdesao .= "<Root>";
	$xmlDadosAdesao .= "	<Cabecalho>";
	$xmlDadosAdesao .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlDadosAdesao .= "		<Proc>obtem-dados-adesao</Proc>";
	$xmlDadosAdesao .= "	</Cabecalho>";
	$xmlDadosAdesao .= "	<Dados>";
	$xmlDadosAdesao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosAdesao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosAdesao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosAdesao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosAdesao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosAdesao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosAdesao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosAdesao .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlDadosAdesao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDadosAdesao .= "	</Dados>";
	$xmlDadosAdesao .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosAdesao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosAdesao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosAdesao->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosAdesao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
		exit();
	} 
	
	$xmlTagsAdesao = $xmlObjDadosAdesao->roottag->tags[0]->tags[0]->tags;
	
	for ($i = 0; $i < count($xmlTagsAdesao); $i++) {
		$dadosAdesao[$xmlTagsAdesao[$i]->name] = $xmlTagsAdesao[$i]->cdata;
	}
	
	// Classe para gera&ccedil;&atilde;o do termo em PDF
	require_once("termo_adesao_pdf.php");

	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");
	
	// Inicia gera&ccedil;&atilde;o do termo
	$pdf->geraTermo($dadosAdesao);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera sa&iacute;da do PDF para o Browser
	$pdf->Output("termo_adesao.pdf",$tipo);	

?>