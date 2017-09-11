<?php
	/*!
	* FONTE        : alterar_ocupacao.php
	* CRIAÇÃO      : Kelvin - CECRED
	* DATA CRIAÇÃO : Agosto/2017
	* OBJETIVO     : Rotina para realizar a alteração da ocupacao
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
	$dsdocupa = isset($_POST["dsdocupa"]) ? $_POST["dsdocupa"] : '';
	$rsdocupa = isset($_POST["rsdocupa"]) ? $_POST["rsdocupa"] : '';
	
	validaDados($cdnatocp, $dsdocupa, $rsdocupa);
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdnatocp>".$cdnatocp."</cdnatocp>";
	$xml .= "   <dsdocupa>".$dsdocupa."</dsdocupa>";
	$xml .= "   <rsdocupa>".$rsdocupa."</rsdocupa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADOCP", "PC_INCLUIR_OCUPACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#dsdocupa\',\'#frmDetalhes\').habilitaCampo(); focaCampoErro(\'#dsdocupa\',\'frmDetalhes\');',false);
	}
	
	exibirErro('inform','Ocupa&ccedil&atilde;o inserida com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
	
	
	function validaDados($cdnatocp, $dsdocupa, $rsdocupa){
		
		//Natureza da ocupacao
		if($cdnatocp == ''){
			
            exibirErro('error','C&oacute;digo da natureza da ocupa&ccedil&atilde;o inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'cdnatocp\',\'frmDetalhes\');',false);
       
		}
		
		//Descricao da ocupacao
		if($dsdocupa == ''){
			
            exibirErro('error','Descri&ccedil&atilde;o da ocupa&ccedil&atilde;o inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dsdocupa\',\'frmDetalhes\');',false);
       
		}
		
		//Descricao resumida da ocupacao
		if($rsdocupa == ''){
			
            exibirErro('error','Descri&ccedil&atilde;o resumida da ocupa&ccedil&atilde;o inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'rsdocupa\',\'frmDetalhes\');',false);
       
		}
		
	}
?>