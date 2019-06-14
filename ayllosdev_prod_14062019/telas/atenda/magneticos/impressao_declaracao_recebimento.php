<?php 

	//************************************************************************//
	//*** Fonte: impressao_declaracao_recebimento.php                      ***//
	//*** Autor: David                                                     ***//
	//*** Data : Marco/2009                   Ultima Alteracao: 12/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Emitir Declaracao de Recebimento de Cartao Magnetico ***//
	//***                                                                  ***//	  
	//*** Alteracoes: 09/07/2009 - Utilizar procedure consiste-cartao      ***//
    //***                          (David).                                ***//
	//***			  12/07/2012 - Alterado parametro de $pdf->Output,     ***//  
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"M")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		?><script language="javascript">alert('N&uacute;mero do cart&atilde;o inv&aacute;lido.');</script><?php
		exit();
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlConsiste  = "";
	$xmlConsiste .= "<Root>";
	$xmlConsiste .= "	<Cabecalho>";
	$xmlConsiste .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlConsiste .= "		<Proc>consiste-cartao</Proc>";
	$xmlConsiste .= "	</Cabecalho>";
	$xmlConsiste .= "	<Dados>";
	$xmlConsiste .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsiste .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsiste .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsiste .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsiste .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlConsiste .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlConsiste .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlConsiste .= "		<idseqttl>1</idseqttl>";
	$xmlConsiste .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlConsiste .= "		<flgentrg>FALSE</flgentrg>";
	$xmlConsiste .= "	</Dados>";
	$xmlConsiste .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsiste);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjConsiste = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjConsiste->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjConsiste->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
		exit();		
	}			
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosDeclaracao  = "";
	$xmlDadosDeclaracao .= "<Root>";
	$xmlDadosDeclaracao .= "	<Cabecalho>";
	$xmlDadosDeclaracao .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlDadosDeclaracao .= "		<Proc>declaracao-recebimento-cartao</Proc>";
	$xmlDadosDeclaracao .= "	</Cabecalho>";
	$xmlDadosDeclaracao .= "	<Dados>";
	$xmlDadosDeclaracao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosDeclaracao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosDeclaracao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosDeclaracao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosDeclaracao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosDeclaracao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosDeclaracao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosDeclaracao .= "		<idseqttl>1</idseqttl>";
	$xmlDadosDeclaracao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDadosDeclaracao .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlDadosDeclaracao .= "	</Dados>";
	$xmlDadosDeclaracao .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosDeclaracao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosDeclaracao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosDeclaracao->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosDeclaracao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
		exit();
	} 
	
	$xmlTagsDeclaracao = $xmlObjDadosDeclaracao->roottag->tags[0]->tags[0]->tags;
	
	for ($i = 0; $i < count($xmlTagsDeclaracao); $i++) {
		$dadosDeclaracao[$xmlTagsDeclaracao[$i]->name] = $xmlTagsDeclaracao[$i]->cdata;
	}
	
	// Classe para gera&ccedil;&atilde;o da declara&ccedil;&atilde;o em PDF
	require_once("impressao_declaracao_recebimento_pdf.php");

	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");
	
	// Inicia gera&ccedil;&atilde;o do declara&ccedil;&atilde;o
	$pdf->geraDeclaracao($dadosDeclaracao);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera sa&iacute;da do PDF para o Browser
	$pdf->Output("impressao.pdf",$tipo);	

?>