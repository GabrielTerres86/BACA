<?php
	/*!
	 * FONTE        : gerar_relatorio_670.php
	 * CRIAÇÃO      : Andrei - RKAM
	 * DATA CRIAÇÃO : Maio/2016
	 * OBJETIVO     : Rotina para gerar relatorio 670 - RELATORIO DE PROCESSAMENTO GRAVAMES
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		

  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	$nrseqlot = isset($_POST["nrseqlot"]) ? $_POST["nrseqlot"] : 0;
  $tparquiv = isset($_POST["tparquiv"]) ? $_POST["tparquiv"] : '';
  $cdcooper = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : 0;
  $dtrefere = isset($_POST["dtrefere"]) ? $_POST["dtrefere"] : 0;
	$dtrefate = isset($_POST["dtrefate"]) ? $_POST["dtrefate"] : 0;
	$cdagenci = isset($_POST["cdagenci"]) ? $_POST["cdagenci"] : 0;
	$nrctrpro = isset($_POST["nrctrpro"]) ? $_POST["nrctrpro"] : 0;
	$flcritic = isset($_POST["flcritic"]) ? $_POST["flcritic"] : '';
	$dschassi = isset($_POST["dschassi"]) ? $_POST["dschassi"] : '';
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
	$tipsaida = isset($_POST["tipsaida"]) ? $_POST["tipsaida"] : 'PDF';
	$nriniseq = !isset($_POST["nriniseq"]) ? 1 : $_POST["nriniseq"];
	$nrregist = !isset($_POST["nrregist"]) ? 50 : $_POST["nrregist"];
  
  
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
  $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";  
  $xml .= "   <tparquiv>".$tparquiv."</tparquiv>";
	$xml .= "   <cdcoptel>".$cdcooper."</cdcoptel>";			
  $xml .= "   <nrseqlot>".$nrseqlot."</nrseqlot>";
  $xml .= "   <dtrefere>".$dtrefere."</dtrefere>"; 	
  $xml .= "   <dtrefate>".$dtrefate."</dtrefate>"; 	
  $xml .= "   <cdagenci>".$cdagenci."</cdagenci>"; 	
  $xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; 	
  $xml .= "   <nrctrpro>".$nrctrpro."</nrctrpro>";
  $xml .= "   <flcritic>".$flcritic."</flcritic>";
  $xml .= "   <tipsaida>".$tipsaida."</tipsaida>";
  $xml .= "   <dschassi>".$dschassi."</dschassi>";
  $xml .= "   <nrregist>".$nrregist."</nrregist>";
  $xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "GRVM0001", "REL670", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
    
		exibirErro('error',$msgErro,'Alerta - Aimaro','formataFiltroImpressao(); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
		
	} 
	
	if($tipsaida == 'PDF'){
	$nmarquiv  =  $xmlObj->roottag->attributes["NMARQUIV"];

	echo 'Gera_Impressao("'.$nmarquiv.'","controlaVoltar(6);");';			
		
	} else {
		
		$registrosSemRet = $xmlObj->roottag->tags[0]->tags;
		$qtdregist = $xmlObj->roottag->tags[1]->tags[0]->cdata;
		include('tab_relatorio_670.php');
	}
	
	
	function validaDados(){
		IF($GLOBALS["tparquiv"] == '' ){ 
			exibirErro('error','Tipo de arquivo in&acute;lido.','Alerta - Aimaro','formataFiltroImpressao();focaCampoErro(\'tparquiv\',\'frmFiltro\');',false);
		}
    
		IF($GLOBALS["nrdconta"] == 0 && $GLOBALS["dschassi"] == '' && $GLOBALS["dtrefere"] == '' && $GLOBALS["nrseqlot"] == 0){ 
			exibirErro('error','Informe pelo menos uma opção: Lote, Conta, Chassi ou Data.','Alerta - Aimaro','formataFiltroImpressao();focaCampoErro(\'nrseqlot\',\'frmFiltro\');',false);
		}
	}	
		
?>
