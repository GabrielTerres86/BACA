<?php 
	/*!
	 * FONTE        : busca_informacoes_pacotes.php
	 * CRIAÇÃO      : Jean Michel       
	 * DATA CRIAÇÃO : 10/03/2016
	 * OBJETIVO     : Rotina consulta informacoes gerais dos pacotes de tarifas
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
	
	$funcaoAposErro = 'cCdpacote.val(\"\"); cCdpacote.focus();';
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || !isset($_POST["cdpacote"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
		$cdpacote = !isset($_POST["cdpacote"]) ? 0 : $_POST["cdpacote"];
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdpacote>".$cdpacote."</cdpacote>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "PACTAR", "CONSULTA_INF_PACOTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);	
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',$funcaoAposErro,false);
		exit();
	}else{
		echo 'cCdpacote.val("'.$xmlObj->roottag->tags[0]->tags[0]->cdata.'");';
		echo 'cDspacote.val("'.$xmlObj->roottag->tags[0]->tags[1]->cdata.'");';
		echo 'cCdtarifa_lancamento.val("'.$xmlObj->roottag->tags[0]->tags[2]->cdata.'");';
		echo 'cDstarifa.val("'.$xmlObj->roottag->tags[0]->tags[3]->cdata.'");';
		echo 'cDtcancelamento.val("'.$xmlObj->roottag->tags[0]->tags[6]->cdata.'");';
		echo 'cTppessoa.val("'.$xmlObj->roottag->tags[0]->tags[7]->cdata.'");';
		echo 'cBtnConcluir.focus();';
	}

?>