<?php
	/*!
	 * FONTE        : buscar_cooperativas.php
	 * CRIAÇÃO      : Lucas Afonso
	 * DATA CRIAÇÃO : 04/10/2017
	 * OBJETIVO     : Rotina para carregar as cooperativas do sistema
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
	
	// Montar o xml de Requisicao
	$xml .= "<Root><Dados></Dados></Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARGOC", "BUSCA_COOP_PARGOC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	// Limpar campos
	echo '$("#cdcooper","#frmCab").empty();';
	
	// Percorrer cada nó do xml - cada um é uma cooperativa retonada
	foreach($xmlObj->roottag->tags[0]->tags as $coop){
		echo '$("#cdcooper","#frmCab").append(\'<option value="'.getByTagName($coop->tags,'cdcooper').'">'.getByTagName($coop->tags,'nmrescop').'</option>\');';
	}
?>