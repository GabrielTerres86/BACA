<?php
	/*!
	 * FONTE        : inclui_fase.php
	 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
	 * DATA CRIAÇÃO : 18/07/2018
	 * OBJETIVO     : Rotina para incluir fase
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
	
	$cdfase            = (isset($_POST['cdfase']))            ? $_POST['cdfase'] : 0;
	$nmfase            = (isset($_POST['nmfase']))            ? $_POST['nmfase'] : ''; 
	$idfase_controlada = (isset($_POST['idfase_controlada'])) ? $_POST['idfase_controlada'] : 0; 
	$cdfase_anterior   = (isset($_POST['cdfase_anterior']))   ? $_POST['cdfase_anterior'] : 0; 
	$qttempo_alerta    = (isset($_POST['qttempo_alerta']))    ? $_POST['qttempo_alerta'] : 0;
	$qtmensagem_alerta = (isset($_POST['qtmensagem_alerta'])) ? $_POST['qtmensagem_alerta'] : 0; 
	$idconversao       = (isset($_POST['idconversao']))       ? $_POST['idconversao'] : 0; 
	$idreprocessa_mensagem = (isset($_POST['idreprocessa_mensagem']))? $_POST['idreprocessa_mensagem'] : 0;	

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"I")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= " <cdfase>"           .$cdfase.           "</cdfase>";
	$xml .= " <nmfase>"           .$nmfase.           "</nmfase>";
	$xml .= " <idfase_controlada>".$idfase_controlada."</idfase_controlada>";
	$xml .= " <cdfase_anterior>"  .$cdfase_anterior.  "</cdfase_anterior>";
	$xml .= " <qttempo_alerta>"   .$qttempo_alerta.   "</qttempo_alerta>";
	$xml .= " <qtmensagem_alerta>".$qtmensagem_alerta."</qtmensagem_alerta>";
	$xml .= " <idconversao>"      .$idconversao.      "</idconversao>";
	$xml .= " <idreprocessa_mensagem>"      .$idreprocessa_mensagem.      "</idreprocessa_mensagem>";
	$xml .= " <idativo>"          .$idativo.          "</idativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_SPBFSE", "INSERE_TBSPB_FASE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	
	exibirErro('inform','Fase cadastrada com sucesso.' ,'Alerta - Ayllos','estadoInicial();',false);
?>