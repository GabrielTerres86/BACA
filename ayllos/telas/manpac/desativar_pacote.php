<?php
	/*!
	 * FONTE        : desativar_pacote.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 18/02/2016
	 * OBJETIVO     : Rotina para desativar pacote de tarifas da tela PACTAR
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
	
	$funcaoAposErro = '';
			
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || !isset($_POST["cdpacote"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
		exit();
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
		$cdpacote = !isset($_POST["cdpacote"]) ? 0 : $_POST["cdpacote"];
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',htmlentities($msgError),'Alerta - Ayllos','',false);
	}
	
	if($cddopcao != "D"){
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
		exit();
	}

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdpacote>".$cdpacote."</cdpacote>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, "MANPAC", "DESATIVA_PACOTE_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","estadoInicial();");';		
	}	
?>