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
	$cdprogra = isset($_POST["cdprogra"]) ? $_POST["cdprogra"] : '';
	$dtde = 	isset($_POST["dtde"]) ? $_POST["dtde"] : '';
	$dtate = 	isset($_POST["dtate"]) ? $_POST["dtate"] : '';
	$nmarqlog = isset($_POST["nmarqlog"]) ? $_POST["nmarqlog"] : '';
	$cdmensag = isset($_POST["cdmensag"]) ? $_POST["cdmensag"] : '';
	$dsmensag = isset($_POST["dsmensag"]) ? $_POST["dsmensag"] : '';
	$tpocorre = isset($_POST["tpocorre"]) ? $_POST["tpocorre"] : '';
	$cdcriti = 	isset($_POST["cdcriti"]) ? $_POST["cdcriti"] : '';
	$clausula = isset($_POST["clausula"]) ? $_POST["clausula"] : '';
	$tpexecuc = isset($_POST["tpexecuc"]) ? $_POST["tpexecuc"] : '';
	$chamaber = isset($_POST["chamaber"]) ? $_POST["chamaber"] : '';
	$nrchamad = isset($_POST["nrchamad"]) ? $_POST["nrchamad"] : '';
	
	validaDados();

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcoptel>".$cdcooper."</cdcoptel>";  
	$xml .= "   <cdprogra>".$cdprogra."</cdprogra>";
	$xml .= "   <dtde>".$dtde."</dtde>";			
	$xml .= "   <dtate>".$dtate."</dtate>";
	$xml .= "   <nmarqlog>".$nmarqlog."</nmarqlog>"; 	
	$xml .= "   <cdmensag>".$cdmensag."</cdmensag>"; 	
	$xml .= "   <dsmensag>".$dsmensag."</dsmensag>"; 	
	$xml .= "   <tpocorre>".$tpocorre."</tpocorre>"; 	
	$xml .= "   <cdcriti>".$cdcriti."</cdcriti>"; 	
	$xml .= "   <clausula>".$clausula."</clausula>";
	$xml .= "   <tpexecuc>".$tpexecuc."</tpexecuc>";
	$xml .= "   <chamaber>".$chamaber."</chamaber>";
	$xml .= "   <nrchamad>".$nrchamad."</nrchamad>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	
	$xmlResult = mensageria($xml, "CONLOG", "CONSULTA_LOG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	
	$logs = $xmlObj->roottag->tags[0]->tags;
	include('tab_logs.php');
	
	
	function validaDados(){
		IF($GLOBALS["dtde"] == '' ){ 
			exibirErro('error','Informe uma data de inínicio.','Alerta - Ayllos','formataFiltro();focaCampoErro(\'dtde\',\'divFiltro\');',false);
		}
		
		IF($GLOBALS["dtate"] == ''){ 
			exibirErro('error','Informe uma data de fim.','Alerta - Ayllos','formataFiltro();focaCampoErro(\'dtate\',\'divFiltro\');',false);
		}

		IF($GLOBALS["dsmensag"] != '' && $GLOBALS["clausula"] == ''){ 
			exibirErro('error','Informe a cláusula.','Alerta - Ayllos','formataFiltro();focaCampoErro(\'clausula\',\'divFiltro\');',false);
		}
	}	
		
?>
