<?php 
	/*!
	 * FONTE        : consulta_habilitar.php
	 * CRIAÇÃO      : Jean Michel       
	 * DATA CRIAÇÃO : 17/03/2016
	 * OBJETIVO     : Rotina consulta informacoes de tarifas para habilitar pacotes
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
	
	//$funcaoAposErro = 'estadoInicial();';
	$funcaoAposErro = 'cCdpacote.habilitaCampo();cCdpacote.addClass(\"inteiro\");cTodosCabecalho.limpaFormulario();cDspacote.val(\"\"); $(\"#lupaCons\").show();cBtnConcluir.html(\"Prosseguir\");cCdpacote.focus();';
	
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
	
	$xmlResult = mensageria($xml, "MANPAC", "CONSULT_INF_PCT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		
		$dscpessoa = ($xmlObj->roottag->tags[0]->tags[7]->cdata == 2 ? "Pessoa Jur&iacute;dica" : "Pessoa Fisica");
		$cddtarifa = $xmlObj->roottag->tags[0]->tags[2]->cdata;
		$vlrpacote = $xmlObj->roottag->tags[0]->tags[8]->cdata;
		$qtdregist = $xmlObj->roottag->tags[2]->cdata;
		$registros = $xmlObj->roottag->tags[1]->tags;
		include('tab_habilitar.php');
	}

?>