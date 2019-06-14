<?php
	/*!
	 * FONTE        : valida_pacote.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 03/03/2016
	 * OBJETIVO     : Rotina de validacao de inclusao de pacotes de tarifas da tela PACTAR
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
	
	$funcaoAposErro = 'cDspacoteInc.habilitaCampo();cTppessoaInc.habilitaCampo();cCdtarifa_lancamentoInc.habilitaCampo();cDspacoteInc.focus();';
			
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || !isset($_POST["cdpacote"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
		$cdpacote = !isset($_POST["cdpacote"]) ? 0 : $_POST["cdpacote"];
		$tppessoa = !isset($_POST["tppessoa"]) ? 0 : $_POST["tppessoa"];
		$cdtarifa = !isset($_POST["cdtarifa"]) ? 0 : $_POST["cdtarifa"];
		$dspacote = !isset($_POST["dspacote"]) ? "" : $_POST["dspacote"];
		$dstarifa = !isset($_POST["dstarifa"]) ? "" : $_POST["dstarifa"];
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdpacote>".$cdpacote."</cdpacote>";
	$xml .= "   <tppessoa>".$tppessoa."</tppessoa>";
	$xml .= "   <cdtarifa>".$cdtarifa."</cdtarifa>";
	$xml .= "   <dspacote>".$dspacote."</dspacote>";
	$xml .= "   <dstarifa>".$dstarifa."</dstarifa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, "PACTAR", "VALIDA_PACOTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		echo 'buscaTarifasIncluir();';
	}	
?>