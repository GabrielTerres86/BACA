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
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrseqlot = isset($_POST["nrseqlot"]) ? $_POST["nrseqlot"] : 0;
  $tparquiv = isset($_POST["tparquiv"]) ? $_POST["tparquiv"] : '';
  $cdcooper = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : 0;
  $dtrefere = isset($_POST["dtrefere"]) ? $_POST["dtrefere"] : 0;
  
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
  $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";  
  $xml .= "   <tparquiv>".$tparquiv."</tparquiv>";
	$xml .= "   <cdcoptel>".$cdcooper."</cdcoptel>";			
  $xml .= "   <nrseqlot>".$nrseqlot."</nrseqlot>";
  $xml .= "   <dtrefere>".$dtrefere."</dtrefere>"; 	
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
    
		exibirErro('error',$msgErro,'Alerta - Ayllos','formataFiltroImpressao(); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
		
	} 
	
	$nmarquiv  =  $xmlObj->roottag->attributes["NMARQUIV"];

	echo 'Gera_Impressao("'.$nmarquiv.'","estadoInicial();");';			
		
	
	
	function validaDados(){
			
		IF($GLOBALS["tparquiv"] == '' ){ 
			exibirErro('error','Tipo de arquivo in&acute;lido.','Alerta - Ayllos','formataFiltroImpressao();focaCampoErro(\'tparquiv\',\'frmFiltro\');',false);
		}
    
    IF($GLOBALS["dtrefere"] == 0 ){ 
			exibirErro('error','Informe uma data de refer&ecirc;ncia.','Alerta - Ayllos','formataFiltroImpressao();focaCampoErro(\'dtrefere\',\'frmFiltro\');',false);
		}
				
	}	
		
?>
