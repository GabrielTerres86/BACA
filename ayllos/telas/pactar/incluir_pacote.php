<?php 
	/*!
	 * FONTE        : incluir_pacote.php
	 * CRIAÇÃO      : Jean Michel       
	 * DATA CRIAÇÃO : 10/03/2016
	 * OBJETIVO     : Rotina para inclusao de pacotes de tarifas
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
	
	$funcaoAposErro = 'estadoInicial();';
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || !isset($_POST["cdpacote"]) || !isset($_POST["dspacote"]) ||
		!isset($_POST["tppessoa"]) || !isset($_POST["cdtarifa"]) || !isset($_POST["strtarif"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0  : $_POST["cddopcao"];
		$cdpacote = !isset($_POST["cdpacote"]) ? 0  : $_POST["cdpacote"];
		$dspacote = !isset($_POST["dspacote"]) ? "" : $_POST["dspacote"];
		$tppessoa = !isset($_POST["tppessoa"]) ? 0  : $_POST["tppessoa"];
		$cdtarifa = !isset($_POST["cdtarifa"]) ? 0  : $_POST["cdtarifa"];
		$dstarifa = !isset($_POST["dstarifa"]) ? "" : $_POST["dstarifa"];
        $strtarif = !isset($_POST["strtarif"]) ? "" : $_POST["strtarif"];
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdpacote>".$cdpacote."</cdpacote>";
	$xml .= "   <dspacote>".$dspacote."</dspacote>";
	$xml .= "   <tppessoa>".$tppessoa."</tppessoa>";
	$xml .= "   <cdtarifa>".$cdtarifa."</cdtarifa>";
	$xml .= "   <dstarifa>".$dstarifa."</dstarifa>";
	$xml .= "   <strtarif>".$strtarif."</strtarif>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "PACTAR", "INCLUIR_PACOTE_TARIFA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		exit();		
	}

?>