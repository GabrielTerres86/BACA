<?php
	/*!
	* FONTE        : incluir_cnae.php
	* CRIAÇÃO      : Adriano - CECRED
	* DATA CRIAÇÃO : Julho/2017
	* OBJETIVO     : Rotina para realizar a inclusão de CNAE
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
	
	$dscnae = isset($_POST["dscnae"]) ? $_POST["dscnae"] : "";
	
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <dscnae>".$dscnae."</dscnae>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADCNA", "INCLUIR_CNAE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#dscnae\',\'#frmFiltro\').habilitaCampo(); focaCampoErro(\'#dscnae\',\'frmFiltro\');',false);
	}
	
	exibirErro('inform','CNAE inclu&iacute;do com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
		
	function validaDados(){
		
		//Decrição do CNAE
		if($GLOBALS["dscnae"] == ''){
			
            exibirErro('error','Descri&ccedil;atilde;o do CNAE inv&aacute;lido.','Alerta - Ayllos','$(\'input, select\',\'#frmFiltro\').removeClass(\'campoErro\');focaCampoErro(\'dscnae\',\'frmFiltro\');',false);
       
		}
		
	}
?>