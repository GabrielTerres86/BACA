<?php 

	//************************************************************************//
	//*** Fonte: lista_cheques.php                                         ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2008               Ultima Alteracao: 12/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Emitir lista de cheques n&atilde;o compensados       ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 12/07/2012 - Alterado parametro de $pdf->Output,     ***//  
	//***   					   Condicao para  Navegador Chrome (Jorge).***//
	//***   		                                                       ***//	 
	//***             29/05/2018 - Alterada permissao da tela.             ***//  
	//***   					   PRJ366(Lombardi).                       ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();		
	}	

	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nmprimtl"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	$nmprimtl = $_POST["nmprimtl"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!is_numeric($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlCabecRelatorio  = "";
	$xmlCabecRelatorio .= "<Root>";
	$xmlCabecRelatorio .= "	 <Cabecalho>";
	$xmlCabecRelatorio .= "		 <Bo>b1wgen0000.p</Bo>";
	$xmlCabecRelatorio .= "		 <Proc>cabecalho_relatorios</Proc>";
	$xmlCabecRelatorio .= "	 </Cabecalho>";
	$xmlCabecRelatorio .= "	 <Dados>";
	$xmlCabecRelatorio .= "		 <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCabecRelatorio .= "		 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCabecRelatorio .= "		 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCabecRelatorio .= "		 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCabecRelatorio .= "		 <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlCabecRelatorio .= "		 <cdrelato>221</cdrelato>";
	$xmlCabecRelatorio .= "	 </Dados>";
	$xmlCabecRelatorio .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCabecRelatorio);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCabecRelatorio = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjCabecRelatorio->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjCabecRelatorio->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosCheques  = "";
	$xmlDadosCheques .= "<Root>";
	$xmlDadosCheques .= "	 <Cabecalho>";
	$xmlDadosCheques .= "		 <Bo>b1wgen0003.p</Bo>";
	$xmlDadosCheques .= "		 <Proc>selecao_cheques_pendentes</Proc>";
	$xmlDadosCheques .= "	 </Cabecalho>";
	$xmlDadosCheques .= "	 <Dados>";
	$xmlDadosCheques .= "		 <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosCheques .= "		 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosCheques .= "		 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosCheques .= "		 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosCheques .= "		 <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosCheques .= "		 <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosCheques .= "		 <nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosCheques .= "		 <idseqttl>1</idseqttl>";
	$xmlDadosCheques .= "	 </Dados>";
	$xmlDadosCheques .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosCheques);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosCheques = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosCheques->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDadosCheques->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	$xmlTags = $xmlObjDadosCheques->roottag->tags[0]->tags;
	
	for ($i = 0; $i < count($xmlTags); $i++) {
		$xmlSubTags = $xmlTags[$i]->tags;
		
		for ($j = 0; $j < count($xmlSubTags); $j++) {
			$dados["DADOSCHQ"][$i][$xmlSubTags[$j]->name] = $xmlSubTags[$j]->cdata;
		}
	}
		
	$dados["NRDCONTA"] = formataContaDV($nrdconta);
	$dados["NMPRIMTL"] = $nmprimtl;
	$dados["DTMVTOLT"] = $glbvars["dtmvtolt"];	
	$dados["QTCHEQUE"] = $xmlObjDadosCheques->roottag->tags[0]->attributes["QTCHEQUE"];
	$dados["QTCORDEM"] = $xmlObjDadosCheques->roottag->tags[0]->attributes["QTCORDEM"];	
	$dados["CDRELATO"] = "221";
	$dados["NMRESCOP"] = $xmlObjCabecRelatorio->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$dados["NMRELATO"] = $xmlObjCabecRelatorio->roottag->tags[0]->tags[0]->tags[1]->cdata;
	$dados["NMDESTIN"] = $xmlObjCabecRelatorio->roottag->tags[0]->tags[0]->tags[2]->cdata;
	
	// Classe para gera&ccedil;&atilde;o do termo em PDF
	require_once("lista_cheques_pdf.php");

	// Instancia Objeto para gerar arquivo PDF
	$pdf = new PDF("P","cm","A4");
	
	// Inicia gera&ccedil;&atilde;o do termo
	$pdf->geraLista($dados);
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? "I" : "D";
	
	// Gera sa&iacute;da do PDF para o Browser
	$pdf->Output("cheques_nao_compensados.pdf",$tipo);		

?>