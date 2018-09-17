<?php 
	/*!
	 * FONTE        : busca_tarifas_descricao.php
	 * CRIAÇÃO      : Jean Michel       
	 * DATA CRIAÇÃO : 08/03/2016
	 * OBJETIVO     : Rotina consulta descricao tarifas da tela PACTAR para opcao de inclusao "I"
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
	
	$funcaoAposErro = 'cCdtarifa_lancamentoInc.val(\"\"); cDstarifaInc.val(\"\"); cCdtarifa_lancamentoInc.focus();';
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || !isset($_POST["tppessoa"]) || !isset($_POST["cdtarifa"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
		$tppessoa = !isset($_POST["tppessoa"]) ? 0 : $_POST["tppessoa"];
		$cdtarifa = !isset($_POST["cdtarifa"]) ? 0 : $_POST["cdtarifa"];
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <tppessoa>".$tppessoa."</tppessoa>";
	$xml .= "   <cdtarifa>".$cdtarifa."</cdtarifa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "PACTAR", "CONSULTA_DESC_TARIFA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		echo "$('#dstarifaInc').val('".$xmlObj->roottag->tags[0]->tags[1]->cdata."');";
	}

?>