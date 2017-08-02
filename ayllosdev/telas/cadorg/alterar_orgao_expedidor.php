<?php
	/*!
	* FONTE        : alterar_orgao_expedidor.php
	* CRIAÇÃO      : Adriano - CECRED
	* DATA CRIAÇÃO : Junho/2017
	* OBJETIVO     : Rotina para realizar a alteração do orgão expedidor
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
	
	$idorgao_expedidor = isset($_POST["idorgao_expedidor"]) ? $_POST["idorgao_expedidor"] : 0;
	$cdorgao_expedidor = isset($_POST["cdorgao_expedidor"]) ? $_POST["cdorgao_expedidor"] : 0;
	$nmorgao_expedidor = isset($_POST["nmorgao_expedidor"]) ? $_POST["nmorgao_expedidor"] : "";
	
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <idorgao_expedidor>".$idorgao_expedidor."</idorgao_expedidor>";
	$xml .= "   <cdorgao_expedidor>".$cdorgao_expedidor."</cdorgao_expedidor>";
	$xml .= "   <nmorgao_expedidor>".$nmorgao_expedidor."</nmorgao_expedidor>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADORG", "ALTERAR_ORGAO_EXPEDIDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#cdorgao_expedidor\',\'#frmDetalhes\').habilitaCampo(); focaCampoErro(\'#cdorgao_expedidor\',\'frmDetalhes\');',false);
	}
	
	exibirErro('inform','Org&atilde;o expedidor alterado com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
		
	function validaDados(){
		
		//Identificador do orgão expedidor
		if($GLOBALS["idorgao_expedidor"] == ''){
			
            exibirErro('error','Identificador do org&atilde;o expedidor inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'cdorgao_expedidor\',\'frmDetalhes\');',false);
       
		}
		
		//Descrição do orgão expedidor
		if($GLOBALS["nmorgao_expedidor"] == ''){
			
            exibirErro('error','Descri&ccedil;&atilde;o do org&atilde;o expedidor inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'nmorgao_expedidor\',\'frmDetalhes\');',false);
       
		}
		
		//Código do orgão expedidor
		if($GLOBALS["cdorgao_expedidor"] == ''){
			
            exibirErro('error','C&oacute;digo do org&atilde;o expedidor inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'cdorgao_expedidor\',\'frmDetalhes\');',false);
       
		}
		
	}
?>