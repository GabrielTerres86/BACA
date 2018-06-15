<?php
	/*!
	* FONTE        : incluir_nacionalidades.php
	* CRIAÇÃO      : Adriano - CECRED
	* DATA CRIAÇÃO : Junho/2017
	* OBJETIVO     : Rotina para realizar a inclusão das nacionalidades
	* --------------
	* ALTERAÇÕES   : 09/04/2018 - PRJ 414 - Alterado para receber e enviar os novos campos adicionados (Mateus Z - Mouts)
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
	
	$dsnacion = isset($_POST["dsnacion"]) ? $_POST["dsnacion"] : "";
	$cdpais   = isset($_POST["cdpais"])   ? $_POST["cdpais"]   : "";
	$nmpais   = isset($_POST["nmpais"])   ? $_POST["nmpais"]   : "";
	$inacordo = isset($_POST["inacordo"]) ? $_POST["inacordo"] : "";
	$dtinicio = isset($_POST["dtinicio"]) ? $_POST["dtinicio"] : "";
	$dtfinal  = isset($_POST["dtfinal"])  ? $_POST["dtfinal"]  : "";
	
	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <dsnacion>".$dsnacion."</dsnacion>";
	$xml .= "   <cdpais>".$cdpais."</cdpais>";
	$xml .= "   <nmpais>".$nmpais."</nmpais>";
	$xml .= "   <inacordo>".$inacordo."</inacordo>";
	$xml .= "   <dtinicio>".$dtinicio."</dtinicio>";
	$xml .= "   <dtfinal>".$dtfinal."</dtfinal>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADNAC", "INCLUIR_NACIONALIDADES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#dsnacion\',\'#frmFiltro\').habilitaCampo(); focaCampoErro(\'#dsnacion\',\'frmFiltro\');',false);
	}
	
	exibirErro('inform','Nacionalidade inclu&iacute;da com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
		
	function validaDados(){
		
		//Decrição da nacionalidade
		if($GLOBALS["dsnacion"] == ''){
			
            exibirErro('error','Descri&ccedil;&atilde;o da nacionalidade inv&aacute;lida.','Alerta - Ayllos','$(\'input, select\',\'#frmFiltro\').removeClass(\'campoErro\');focaCampoErro(\'dsnacion\',\'frmFiltro\');',false);
       
		}

		if($GLOBALS["cdpais"] == '' && $GLOBALS["nmpais"] != ''){
			exibirErro('error','Favor informar a c&oacute;digo do pa&iacute;s.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dsnacion\',\'frmDetalhes\');',false);
		}

		if($GLOBALS["cdpais"] != '' && $GLOBALS["nmpais"] == ''){
			exibirErro('error','Favor informar a descri&ccedil;&atilde;o do pa&iacute;s.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dsnacion\',\'frmDetalhes\');',false);
		}

		if($GLOBALS["inacordo"] != '' && $GLOBALS["cdpais"] == ''){
			exibirErro('error','Favor informar a c&oacute;digo do pa&iacute;s.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dsnacion\',\'frmDetalhes\');',false);
		}

		if($GLOBALS["inacordo"] != '' && $GLOBALS["dtinicio"] == ''){
			exibirErro('error','Favor informar a data de in&iacute;cio.','Alerta - Ayllos','$(\'input, select\',\'#frmDetalhes\').removeClass(\'campoErro\');focaCampoErro(\'dsnacion\',\'frmDetalhes\');',false);
		}
		
	}
?>