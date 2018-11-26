<?php
	/*!
	 * FONTE        : busca_logs.php
	 * CRIAÇÃO      : Thaise - Envolti
	 * DATA CRIAÇÃO : Outubro/2018
	 * OBJETIVO     : Rotina para buscar os logs.
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdcooper = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : 0;
	$dtde = 	isset($_POST["dtde"]) ? $_POST["dtde"] : '';
	$dtate = 	isset($_POST["dtate"]) ? $_POST["dtate"] : '';
	$dsmensag = isset($_POST["dsmensag"]) ? $_POST["dsmensag"] : '';
	$clausula = isset($_POST["clausula"]) ? $_POST["clausula"] : '';
	
	validaDados();

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcoptel>".$cdcooper."</cdcoptel>";  
	$xml .= "   <dtde>".$dtde."</dtde>";			
	$xml .= "   <dtate>".$dtate."</dtate>";	
	$xml .= "   <dsmensag>".$dsmensag."</dsmensag>"; 		
	$xml .= "   <clausula>".$clausula."</clausula>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	
	$xmlResult = mensageria($xml, "CONLOG", "CONSULTA_ERRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		

		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	

		if(empty ($nmdcampo)){ 
			$nmdcampo = "dtde";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
    
		exibirErro('error',$msgErro,'Alerta - Ayllos','formataFiltro(); focaCampoErro(\''.$nmdcampo.'\',\'divFiltro\');',false);		
		
	} 
	
	$erros = $xmlObj->roottag->tags[0]->tags;
	include('tab_erros.php');
	
	
	function validaDados(){
		IF($GLOBALS["dtde"] == '' ){ 
			exibirErro('error','Informe uma data de inínicio.','Alerta - Ayllos','formataFiltroImpressao();focaCampoErro(\'dtde\',\'divFiltro\');',false);
		}
		
		IF($GLOBALS["dtate"] == ''){ 
			exibirErro('error','Informe uma data de fim.','Alerta - Ayllos','formataFiltroImpressao();focaCampoErro(\'dtate\',\'divFiltro\');',false);
		}

		IF($GLOBALS["dsmensag"] != '' && $GLOBALS["clausula"] == ''){ 
			exibirErro('error','Informe a cláusula.','Alerta - Ayllos','formataFiltroImpressao();focaCampoErro(\'clausula\',\'divFiltro\');',false);
		}
	}	
		
?>
