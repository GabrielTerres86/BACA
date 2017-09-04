<?php
	/*!
	* FONTE        : alterar_cnae.php
	* CRIAÇÃO      : Adriano - CECRED
	* DATA CRIAÇÃO : Julho/2017
	* OBJETIVO     : Rotina para realizar a alteração de CNAE
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
	
	$cdcnae = isset($_POST["cdcnae"]) ? $_POST["cdcnae"] : 0;
	$dscnae = isset($_POST["dscnae"]) ? $_POST["dscnae"] : "";
	
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcnae>".$cdcnae."</cdcnae>";
	$xml .= "   <dscnae>".$dscnae."</dscnae>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADCNA", "ALTERAR_CNAE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#dscnae\',\'#frmDetalhes\').habilitaCampo(); focaCampoErro(\'#dscnae\',\'frmDetalhes\');',false);
	}
	
	exibirErro('inform','CNAE alterado com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
		
	function validaDados(){
		
		//Descrição da CNAE
		if($GLOBALS["dscnae"] == ''){
			
            exibirErro('error','Descri&ccedil;&atilde;o do CNAE inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dscnae\',\'frmDetalhes\');',false);
       
		}
		
		//Código da CNAE
		if($GLOBALS["cdcnae"] == ''){
			
            exibirErro('error','C&oacute;digo do CNAE inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dscnae\',\'frmDetalhes\');',false);
       
		}
		
	}
?>