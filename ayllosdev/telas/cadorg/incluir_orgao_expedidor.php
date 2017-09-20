<?php
	/*!
	* FONTE        : incluir_nacionalidades.php
	* CRIA��O      : Adriano - CECRED
	* DATA CRIA��O : Junho/2017
	* OBJETIVO     : Rotina para realizar a inclus�o de org�o pagador
	* --------------
	* ALTERA��ES   : 
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
	$nmorgao_expedidor = isset($_POST["nmorgao_expedidor"]) ? $_POST["nmorgao_expedidor"] : "";
	
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdorgao_expedidor>".$cdorgao_expedidor."</cdorgao_expedidor>";
	$xml .= "   <nmorgao_expedidor>".$nmorgao_expedidor."</nmorgao_expedidor>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADORG", "INCLUIR_ORGAO_EXPEDIDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#cdorgao_expedidor\',\'#frmFiltro\').habilitaCampo(); focaCampoErro(\'#cdorgao_expedidor\',\'frmFiltro\');',false);
	}
	
	exibirErro('inform','Org&atilde;o expedidor inclu&iacute;do com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
	
	function validaDados(){
		
		//Descri��o do org�o expedidor
		if($GLOBALS["nmorgao_expedidor"] == ''){
			
            exibirErro('error','Descri&ccedil;&atilde;o do org&atilde;o expedidor inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmFiltro\').removeClass(\'campoErro\');focaCampoErro(\'nmorgao_expedidor\',\'frmFiltro\');',false);
       
		}
		
		//C�digo do org�o expedidor
		if($GLOBALS["cdorgao_expedidor"] == ''){
			
            exibirErro('error','C&oacute;digo do org&atilde;o expedidor inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmFiltro\').removeClass(\'campoErro\');focaCampoErro(\'cdorgao_expedidor\',\'frmFiltro\');',false);
       
		}
		
	}
?>