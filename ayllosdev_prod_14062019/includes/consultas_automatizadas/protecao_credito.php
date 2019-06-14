<?php 
/*!
 * FONTE         : protecao_credito.php
 * CRIAÇÃO       : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO  : 09/09/2014
 * OBJETIVO      : Efetuar consultas ao Ibratan. 
 *				   Projeto Automatização de Consultas em Propostas de Crédito.
 *
 * ALTERACOES    : 18/03/2015 - Retirar tratamento de criticas na consulta geral (Jonata-RKAM).
 *                 
 *                 21/04/2015 - Consultas automatizadas para o limite de credito (Gabriel-RKAM).
 */
 
	session_start();
	include('../config.php');
	include('../funcoes.php');		
	include('../controla_secao.php');
	include('../../class/xmlfile.php');
	isPostMethod();	
	
	// Obter os parametros
	$nrdconta       = $_POST['nrdconta'];
	$nrdocmto       = $_POST['nrdocmto'];
	$iddoaval_busca = $_POST['iddoaval_busca'];
	$inpessoa_busca = $_POST['inpessoa_busca'];
	$nrdconta_busca = $_POST['nrdconta_busca'];
	$nrcpfcgc_busca = $_POST['nrcpfcgc_busca'];
	$operacao       = $_POST['operacao'];
	$inprodut       = $_POST['inprodut'];
	$idSocio        = $_POST['idSocio'];
	$inconcje       = $_POST['inconcje'];
	$dtcnsspc       = $_POST['dtcnsspc'];
	$cddopcao       = substr($operacao,0,1);

 
	$strnomacao = 'SSPC0001_BUSCA_CNS_BIRO';
	
	// Montar o xml para requisicao de consulta ao biro
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "    <nrdocmto>".$nrdocmto."</nrdocmto>";
	$xml .= "    <inprodut>".$inprodut."</inprodut>";
	$xml .= "    <nrdconta_busca>".$nrdconta_busca."</nrdconta_busca>";
	$xml .= "    <nrcpfcgc_busca>".$nrcpfcgc_busca."</nrcpfcgc_busca>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
  
	$xmlResult = mensageria($xml, "SSPC0001", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = simplexml_load_string($xmlResult);
   
	if ($xmlObj->Erro->Registro->dscritic != '') {
		$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
		exibirErro('inform',$msgErro,'Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))", true);
	}
	
	$nrconbir = $xmlObj->nrconbir;
	$nrseqdet = $xmlObj->nrseqdet;	
	
	$strnomacao = 'SSPC0001_VERIFICA_SITUACAO';
	
	// Montar o xml para requisicao de consulta da situacao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <nrconbir>".$nrconbir."</nrconbir>";
	$xml .= "    <nrseqdet>".$nrseqdet."</nrseqdet>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "SSPC0001", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = simplexml_load_string($xmlResult);
   
	if ($xmlObj->Erro->Registro->dscritic != '') {
		$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
		exibirErro('inform',$msgErro,'Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))", true);
	}
	
	$cdbircon     = $xmlObj->cdbircon; 
	$dsmodbir 	  = $xmlObj->dsmodbir;
		
	$strnomacao = 'SSPC0001_CONSULTA_GERAL';
	
	$xmlResult = mensageria($xml, "SSPC0001", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObj = simplexml_load_string($xmlResult);	
	
	if ($xmlObj->Erro->Registro->dscritic != '') {
		$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
		exibirErro('inform',$msgErro,'Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))", true);
	}
	
	$xml_geral = simplexml_load_string($xmlResult);
	
	if ($cdbircon == 1) {
		$dsconsul = "SPC";
	}
	else {
		$dsconsul = "Serasa";
	}	
	
	if ($iddoaval_busca == 99) {
		$cdtipcon = 5; // Conjuge
	}
	else
	if ($iddoaval_busca > 0) {
		$cdtipcon = 3; // Aval
	}
	else 
	if ($operacao == 'C_PROTECAO_SOC' || $operacao == 'A_PROTECAO_SOC') {
		$cdtipcon = 4; // Socios, crapopf/crapvop
		$nrdconta_busca = 0;
		$nrcpfcgc_busca = $xml_geral->Dados->crapcbd_socio->crapcbd_socio_inf[$idSocio - 1]->nrcpfcgc;
	} 
	else {
		$cdtipcon = 1; // Titular
	}
	
	if ($cddopcao != 'I') {
	
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0024.p</Bo>";
		$xml .= "		<Proc>obtem-valores-central-risco</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";		
		$xml .= "		<cdtipcon>".$cdtipcon."</cdtipcon>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<tpctrato>".$inprodut."</tpctrato>";
		$xml .= "		<nrctrato>".$nrdocmto."</nrctrato>";
		$xml .= "		<nrctabus>".$nrdconta_busca."</nrctabus>";
		$xml .= "		<nrcpfbus>".$nrcpfcgc_busca."</nrcpfbus>";
		
		$xml .= "	</Dados>";
		$xml .= "</Root>";

		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xml_central = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xml_central->roottag->tags[0]->name) == "ERRO") {
			exibirErro('inform',$xml_central->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))", true);
		}
		
		$central = $xml_central->roottag->tags[0]->tags[0]->tags;
		
		$dtdrisco = getByTagName($central,'dtdrisco');
		$qtopescr = getByTagName($central,'qtopescr');
		$qtifoper = getByTagName($central,'qtifoper');
		$vltotsfn = getByTagName($central,'vltotsfn');
		$vlopescr = getByTagName($central,'vlopescr');
		$vlrpreju = getByTagName($central,'vlrpreju');
	
	}

	
?>