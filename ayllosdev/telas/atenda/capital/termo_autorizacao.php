<?php 

	//************************************************************************//
	//*** Fonte: termo_autorizacao.php                                     ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 Ultima Alteracao: 12/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Emitir termo de autorizacao do Plano de Capital      ***//
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
	$xmlDadosAutoriz  = "";
	$xmlDadosAutoriz .= "<Root>";
	$xmlDadosAutoriz .= "	<Cabecalho>";
	$xmlDadosAutoriz .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlDadosAutoriz .= "		<Proc>autorizar-novo-plano</Proc>";
	$xmlDadosAutoriz .= "	</Cabecalho>";
	$xmlDadosAutoriz .= "	<Dados>";
	$xmlDadosAutoriz .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosAutoriz .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosAutoriz .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosAutoriz .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosAutoriz .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosAutoriz .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosAutoriz .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosAutoriz .= "		<idseqttl>1</idseqttl>";
	$xmlDadosAutoriz .= "	</Dados>";
	$xmlDadosAutoriz .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosAutoriz);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosAutoriz = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosAutoriz->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosAutoriz->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	$xmlTags = $xmlObjDadosAutoriz->roottag->tags[0]->tags[0]->tags;
	
	for ($i = 0; $i < count($xmlTags); $i++) {
		if ($xmlTags[$i]->name == "DSPREPLA") {
			$dados_termo[$xmlTags[$i]->tags[0]->name] = $xmlTags[$i]->tags[0]->cdata;
			$dados_termo[$xmlTags[$i]->tags[1]->name] = $xmlTags[$i]->tags[1]->cdata;
		} elseif ($xmlTags[$i]->name == "NMRESCOP") {
			$dados_termo[$xmlTags[$i]->tags[0]->name] = $xmlTags[$i]->tags[0]->cdata;
			$dados_termo[$xmlTags[$i]->tags[1]->name] = $xmlTags[$i]->tags[1]->cdata;		
		} else {		
			$dados_termo[$xmlTags[$i]->name] = $xmlTags[$i]->cdata;
		}
	}
	
	$dados_termo["NRDCONTA"] = formataContaDV($nrdconta);
	$dados_termo["DTMVTOLT"] = $glbvars["dtmvtolt"];
	
	// Classe para gera&ccedil;&atilde;o do termo em PDF
	require_once("termo_autorizacao_pdf.php");

	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");
	
	// Inicia gera&ccedil;&atilde;o do termo
	$pdf->geraTermo($dados_termo);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera sa&iacute;da do PDF para o Browser
	$pdf->Output("termo_autorizacao.pdf",$tipo);	

?>