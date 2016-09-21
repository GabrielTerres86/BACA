<?php
	/*!
	 * FONTE        : valida_habilitar.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 17/03/2016
	 * OBJETIVO     : Rotina de validacao para habilitar pacote de tarifas para a cooperativa
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
	$funcaoAposErro = 'verificaAcao(\"V\");';
			
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || !isset($_POST["cdpacote"]) || !isset($_POST["dtvigenc"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
		$cdpacote = !isset($_POST["cdpacote"]) ? 0 : $_POST["cdpacote"];
		$dtvigenc = !isset($_POST["dtvigenc"]) ? 0 : $_POST["dtvigenc"];
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	if($cddopcao != "H"){
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
		exit();
	}else{
		$cddopcao = "C";
	}

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdpacote>".$cdpacote."</cdpacote>";
	$xml .= "   <dtvigenc>".$dtvigenc."</dtvigenc>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, "MANPAC", "HABILITA_PACOTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);	
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		if($xmlObj->roottag->tags[0]->attributes["NMDCAMPO"] == 'dtvigencHab'){
			$funcaoAposErro = 'cDtvigencHab.val(\"\");cDtvigencHab.focus();';
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',$funcaoAposErro,false);
		exit();
	}else{
		echo 'showConfirmacao("Confirma a habilitação do Servi&ccedil;o Cooperativo?", "Confirma&ccedil;&atilde;o - Ayllos", "efetivaHabilitar()", "", "sim.gif", "nao.gif");';	
	}	
?>
