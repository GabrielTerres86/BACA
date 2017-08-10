<?php
	/*!
	* FONTE        : excluir_cnae.php
	* CRIAÇÃO      : Adriano - CECRED
	* DATA CRIAÇÃO : Julho/2017
	* OBJETIVO     : Rotina para realizar a exclusão de cnae
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
	
	$cdcnae = isset($_POST["cdcnae"]) ? $_POST["cdcnae"] : "";

	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcnae>".$cdcnae."</cdcnae>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADCNA", "EXCLUIR_CNAE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdcnae";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);
	}
	
	exibirErro('inform','CNAE exclu&iacute;do com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
			
	function validaDados(){
		
		//Código do CNAE
		if($GLOBALS["cdcnae"] == ''){
			
            exibirErro('error','C&oacute;digo do CNAE inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmFiltro\').removeClass(\'campoErro\');focaCampoErro(\'cdcnae\',\'frmFiltro\');',false);
       
		}
		
	}
?>