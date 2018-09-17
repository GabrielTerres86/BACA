<?php
	/*!
	 * FONTE        : grava_dados.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 18/02/2016
	 * OBJETIVO     : Rotina de gravacao dos dados da tela PACTAR
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
	
	$funcaoAposErro = 'cCddopcao.focus();'; //"btnVoltar();";
			
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || !isset($_POST["nrdesnhs"]) || !isset($_POST["nrdemsgs"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
		$nrdemsgs = !isset($_POST["nrdemsgs"]) ? 0 : $_POST["nrdemsgs"];
		$nrdesnhs = !isset($_POST["nrdesnhs"]) ? 0 : $_POST["nrdesnhs"];
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <nrdemsgs>".$nrdemsgs."</nrdemsgs>";
	$xml .= "   <nrdesnhs>".$nrdesnhs."</nrdesnhs>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	
	$xmlResult = mensageria($xml, "GESGAR", "GESGAR_GRAVA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	}else{
		echo 'showError("inform","Par&acirc;metros alterados com sucesso!","Alerta - Ayllos","estadoInicial();");';
	}	
?>