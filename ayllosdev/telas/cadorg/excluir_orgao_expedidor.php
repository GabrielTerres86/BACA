<?php
	/*!
	* FONTE        : excluir_orgao_expedidor.php
	* CRIAÇÃO      : Adriano - CECRED
	* DATA CRIAÇÃO : Junho/2017
	* OBJETIVO     : Rotina para realizar a exclusão de orgão expedidor
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
	
	$cdorgao_expedidor = isset($_POST["cdorgao_expedidor"]) ? $_POST["cdorgao_expedidor"] : "";
	
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdorgao_expedidor>".$cdorgao_expedidor."</cdorgao_expedidor>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADORG", "EXCLUIR_ORGAO_EXPEDIDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdorgao_expedidor";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);
	}
	
	exibirErro('inform','Org&atilde;o expedidor exclu&iacute;do com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
			
	function validaDados(){
		
		//Identificador do orgão expedidor
		if($GLOBALS["cdorgao_expedidor"] == ''){
			
            exibirErro('error','Org&atilde;o expedidor inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmFiltro\').removeClass(\'campoErro\');focaCampoErro(\'cdorgao_expedidor\',\'frmFiltro\');',false);
       
		}
		
		
	}
	
?>