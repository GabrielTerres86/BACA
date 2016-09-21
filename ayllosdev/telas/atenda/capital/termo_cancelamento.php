<?php 

	//************************************************************************//
	//*** Fonte: termo_cancelamento.php                                    ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 Ultima Alteracao: 12/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Emitir termo de cancelamento do Plano de Capital     ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 12/07/2012 - Alterado parametro de $pdf->Output,     ***//  
	//***   					   Condicao para  Navegador Chrome (Jorge).***//
    /***          17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) */
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"P")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();		
	}		
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!is_numeric($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosCancel  = "";
	$xmlDadosCancel .= "<Root>";
	$xmlDadosCancel .= "	<Cabecalho>";
	$xmlDadosCancel .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlDadosCancel .= "		<Proc>cancelar-plano-atual</Proc>";
	$xmlDadosCancel .= "	</Cabecalho>";
	$xmlDadosCancel .= "	<Dados>";
	$xmlDadosCancel .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosCancel .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlDadosCancel .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosCancel .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosCancel .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosCancel .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosCancel .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosCancel .= "		<idseqttl>1</idseqttl>";
	$xmlDadosCancel .= "	</Dados>";
	$xmlDadosCancel .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosCancel);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosCancel = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosCancel->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosCancel->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	$xmlTags = $xmlObjDadosCancel->roottag->tags[0]->tags[0]->tags;
	
	for ($i = 0; $i < count($xmlTags); $i++) {
		$dados_termo[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
	}
	
	$dados_termo["NRDCONTA"] = formataContaDV($nrdconta);
	$dados_termo["DTMVTOLT"] = $glbvars["dtmvtolt"];
	
	// Classe para gera&ccedil;&atilde;o do termo em PDF
	require_once("termo_cancelamento_pdf.php");

	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");
	
	// Inicia gera&ccedil;&atilde;o do termo
	$pdf->geraTermo($dados_termo);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera sa&iacute;da do PDF para o Browser
	$pdf->Output("termo_cancelamento.pdf",$tipo);	

?>