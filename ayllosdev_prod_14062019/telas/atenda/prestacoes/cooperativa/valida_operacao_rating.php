<?php 
/*!
 * FONTE         : valida_operacao_rating.php
 * CRIAÇÃO       : Bruno Luiz Katzjarowski - Mout's
 * DATA CRIAÇÃO  : 18/10/2018
 * OBJETIVO      : Validar e retornar comando correto para as operacaoes I_PROTECAO_TIT e A_PROTECAO_TIT
				   para evitar de entrar na tela de garantia de operacoes (Rating) - Sprint 6
 *
 * ALTERACOES    : 
 */
	
	/*
	//Remover para gerar erro na request
	ini_set('display_errors',1);
	ini_set('display_startup_erros',1);
	error_reporting(E_ALL);
	*/
	$strComando = "";
	
	
	$iddoaval_busca = $_POST['iddoaval_busca'];
	$inpessoa_busca = $_POST['inpessoa_busca'];
	$nrdconta_busca = $_POST['nrdconta_busca'];
	$nrcpfcgc_busca = $_POST['nrcpfcgc_busca'];
	$cddopcao       = substr($operacao,0,1);
	$idSocio        = $_POST['idSocio'];
	$inprodut       = $_POST['inprodut'];
	$nrdocmto       = $_POST['nrdocmto'];
	
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
	
	if(!is_null($xmlObj->Erro->Registro)){
		if ($xmlObj->Erro->Registro->dscritic != '') {
			$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
			exibirErro('inform',$msgErro,'Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))", true);
		}
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
	
	if(!is_null($xmlObj->Erro->Registro)){
		if ($xmlObj->Erro->Registro->dscritic != '') {
			$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
			exibirErro('inform',$msgErro,'Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))", true);
		}
	}
	
	$cdbircon     = $xmlObj->cdbircon; 
	$dsmodbir 	  = $xmlObj->dsmodbir;
	
	
	
	switch($operacao){
		case 'A_PROTECAO_TIT':
			if ($cdbircon == 2 && $inpessoa_busca == 2 ) {
				$strComando = "controlaSocios('".$operacao."', ".$glbvars["cdcooper"].", ".($idSocio + 1).", ".
							  "".count($xml_geral->Dados->crapcbd_socio->crapcbd_socio_inf).");";
			}else if ($inconcje == 1) {
				$strComando = "validaItensRating('A_PROTECAO_TIT_CONJ', true);  return false;";
			}else{
				if ($inprodut == 1 ) {
					$strComando = "atualizaArray('A_BUSCA_OBS' , '".$glbvars["cdcooper"]."');";
				}else{
					$strComando = "controlaOperacao('A_COMITE_APROV');";
				}
			}
		break;
		case 'A_PROTECAO_AVAL':
			$strComando = "controlaOperacao('".($nomeAcaoCall == 'A_AVALISTA' && $iddoaval_busca == 2 ? 'F_AVALISTA' : 'A_DADOS_AVAL')."');";
		break;
		case 'A_PROTECAO_CONJ':
			if ($inprodut == 1 ) {
				$strComando = "atualizaArray('A_BUSCA_OBS' , '".$glbvars["cdcooper"]."');";
			}else{
				$strComando = "controlaOperacao('A_AVAIS');";
			}
		break;
		case 'C_PROTECAO_TIT':
			if ($cdbircon == 2 && $inpessoa_busca == 2 ){
				$strComando = "controlaSocios('".$operacao."', ".$glbvars["cdcooper"].", ".($idSocio + 1).", ".
								  "".count($xml_geral->Dados->crapcbd_socio->crapcbd_socio_inf).");";
			}else if ($inconcje == 1){
				$strComando = "controlaOperacao('C_PROTECAO_CONJ');";
			}else {
				$strComando = "controlaOperacao('C_COMITE_APROV');";
			}
		break;
		case 'C_PROTECAO_AVAL':
			$strComando = "controlaOperacao('C_DADOS_AVAL');";
		break;
		case 'C_PROTECAO_CONJ':
			$strComando = "controlaOperacao('C_COMITE_APROV');";
		break;
		case 'I_PROTECAO_TIT':
			$strComando = "validaItensRating('I_PROTECAO_TIT' , true);";
		break;
	}
  
	echo $strComando."$('#executouOperacaoRating').val('');";
 ?>