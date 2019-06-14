<?php
	/*!
	 * FONTE        : altera_motivo.php
	 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
	 * DATA CRIAÇÃO : 24/08/2018
	 * OBJETIVO     : Rotina para alterar motivo
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
	
	$cdmotivo     = (isset($_POST['cdmotivo']))     ? $_POST['cdmotivo']     : 0;
	$dsmotivo     = (isset($_POST['dsmotivo']))     ? $_POST['dsmotivo']     : ''; 
	$tpproduto    = (isset($_POST['tpproduto']))    ? $_POST['tpproduto']    : 0; 
	$inobservacao = (isset($_POST['inobservacao'])) ? $_POST['inobservacao'] : 0; 
	$idativo      = (isset($_POST['idativo']))      ? $_POST['idativo']      : 0;

	// tratar acentuação
	$dsmotivo = utf8_decode($dsmotivo);
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"A")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= " <cdmotivo>".$cdmotivo."</cdmotivo>";
	$xml .= " <dsmotivo>".$dsmotivo."</dsmotivo>";
	$xml .= " <tpproduto>".$tpproduto."</tpproduto>";
	$xml .= " <inobservacao>".$inobservacao."</inobservacao>";
	$xml .= " <idativo>".$idativo."</idativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_TAB089", "ATUALIZA_MOTIVOS_ANULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],"</Root>");
	$xmlObj = getObjectXML($xmlResult);
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}

	exibirErro('inform','Motivo atualizado com sucesso.' ,'Alerta - Ayllos','buscaMotivos();',false);
?>