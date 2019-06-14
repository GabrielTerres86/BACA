<?php
	/*!
	 * FONTE        : busca_ratings.php
	 * CRIAÇÃO      : Jonathan - RKAM
	 * DATA CRIAÇÃO : 14/01/2015
	 * OBJETIVO     : Rotina para buscar os ratings 
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
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;

	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "   <nrregist>".$nrregist."</nrregist>";	
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "RATING", "BUSCARATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
		
	} 
	
	$registros = $xmlObj->roottag->tags;
	$vlrdnota  = $xmlObj->roottag->attributes["NRNOTRAT"];
	$nivrisco  = $xmlObj->roottag->attributes["INDRISCO"];
	$datatual  = $xmlObj->roottag->attributes["DTMVTOLT"];
	$qtregist  = $xmlObj->roottag->attributes["QTREGIST"];
	
	if ($qtregist == 0) { 		
		
		exibirErro('inform','Nenhum registro foi encontrado.','Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo();$(\'#nrdconta\',\'#frmFiltro\').focus();');		
		
	} else {      
		
		include('tab_registros.php'); 	
		
	}	
		
	
	
	function validaDados(){
			
		IF($GLOBALS["nrdconta"] == '' ){ 
			exibirErro('error','Conta in&acute;lida.','Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\'nrdconta\',\'frmFiltro\');',false);
		}
				
	}	
		
?>
