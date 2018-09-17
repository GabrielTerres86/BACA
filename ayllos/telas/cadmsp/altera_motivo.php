<?php
	/*!
	 * FONTE        : altera_motivo.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 25/09/2017
	 * OBJETIVO     : Rotina para incluir motivo de saque parcial
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
	
	$cdmotivo = (isset($_POST['cdmotivo'])) ? $_POST['cdmotivo'] : 0;
	$dsmotivo = (isset($_POST['dsmotivo'])) ? $_POST['dsmotivo'] : ''; 
	$flgpessf = (isset($_POST['flgpessf'])) ? $_POST['flgpessf'] : 0; 
	$flgpessj = (isset($_POST['flgpessj'])) ? $_POST['flgpessj'] : 0; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"C")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= " <cdmotivo>".$cdmotivo."</cdmotivo>";
	$xml .= " <dsmotivo>".$dsmotivo."</dsmotivo>";
	$xml .= " <flgpessf>".$flgpessf."</flgpessf>";
	$xml .= " <flgpessj>".$flgpessj."</flgpessj>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CADMSP", "ALTERA_MOTIVO_SP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
		exit();
	}
	// Buscar código de inclusão
	$cdmotivo = $xmlObj->roottag->tags[0]->tags[0]->cdata;	
	exibirErro('inform','Motivo atualizado com sucesso.' ,'Alerta - Ayllos','buscaMotivos();',false);
?>