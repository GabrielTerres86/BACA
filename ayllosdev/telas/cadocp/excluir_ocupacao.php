<?php
	/*!
	* FONTE        : excluir_ocupacao.php
	* CRIAÇÃO      : Kelvin - CECRED
	* DATA CRIAÇÃO : Agosto/2017
	* OBJETIVO     : Rotina para realizar a exclusao da ocupacao
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
	
	$cdnatocp = isset($_POST["cdnatocp"]) ? $_POST["cdnatocp"] : 0;
	$cdocupa = isset($_POST["cdocupa"]) ? $_POST["cdocupa"] : 0;
	
	validaDados($cdnatocp, $cdocupa);
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdnatocp>".$cdnatocp."</cdnatocp>";
	$xml .= "   <cdocupa>".$cdocupa."</cdocupa>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADOCP", "PC_EXCLUIR_OCUPACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#cdnatocp\',\'#frmDetalhes\').habilitaCampo(); focaCampoErro(\'#cdnatocp\',\'frmDetalhes\');',false);
	}
	
	exibirErro('inform','Ocupa&ccedil&atilde;o alterada com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
	
	
	function validaDados($cdnatocp, $cdocupa){
		
		//Natureza da ocupacao
		if($cdnatocp == ''){
			
            exibirErro('error','C&oacute;digo da natureza da ocupa&ccedil&atilde;o inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'cdnatocp\',\'frmDetalhes\');',false);
       
		}
		
		//Codigo da ocupacao
		if($cdocupa == ''){
			
            exibirErro('error','C&oacute;digo da ocupa&ccedil&atilde;o inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'cdocupa\',\'frmDetalhes\');',false);
       
		}
		
	}
?>