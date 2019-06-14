<?php
	/*!
	 * FONTE        : busca_rating_singular.php
	 * CRIAÇÃO      : Andrei - RKAM
	 * DATA CRIAÇÃO : Maio/2016
	 * OBJETIVO     : Rotina para buscar o rating da singular
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
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
  $nrctrrat = isset($_POST["nrctrrat"]) ? $_POST["nrctrrat"] : 0;
  $tpctrrat = isset($_POST["tpctrrat"]) ? $_POST["tpctrrat"] : 0;
  $nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
  $insitrat = isset($_POST["insitrat"]) ? $_POST["insitrat"] : 0;
  $dsdopera = isset($_POST["dsdopera"]) ? $_POST["dsdopera"] : "";
  $indrisco = isset($_POST["indrisco"]) ? $_POST["indrisco"] : 0;
  $nrnotrat = isset($_POST["nrnotrat"]) ? $_POST["nrnotrat"] : 0;
  
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";	
  $xml .= "   <nrregist>".$nrregist."</nrregist>";	
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";	
  $xml .= "   <nrctrrat>".$nrctrrat."</nrctrrat>";	
  $xml .= "   <tpctrrat>".$tpctrrat."</tpctrrat>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATURAT", "BUSCARATINGSINGULAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
    
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesRatings\').focus();',false);		
		
	} 
	
	$registros = $xmlObj->roottag->tags;
	$qtregist  = $xmlObj->roottag->attributes["QTREGIST"];
	
  if ($qtregist == 0) { 		
		
		exibirErro('error','Nenhum registro de rating foi encontrado.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesRatings\').focus();',false);		
		
	} else {      
		
		include('tab_registros_singular.php'); 	
		
	}	
			
	
	function validaDados(){
			
		IF($GLOBALS["nrdconta"] == '' ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesRatings\').focus();',false);
		}
				
	}	
		
?>
