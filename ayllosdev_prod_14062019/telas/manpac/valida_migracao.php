<?php
	/*!
	 * FONTE        : efetiva_migracao.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 17/03/2016
	 * OBJETIVO     : Rotina de efetivação para migracao do pacote de tarifas para a cooperativa
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
	if (!isset($_POST["cddopcao"]) || !isset($_POST["cdpctant"]) || !isset($_POST["cdpctnov"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];
		$cdpctant = !isset($_POST["cdpctant"]) ? 0 : $_POST["cdpctant"];
		$cdpctnov = !isset($_POST["cdpctnov"]) ? 0 : $_POST["cdpctnov"];
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	if($cddopcao != "D"){
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
		exit();
	}else{
		$cddopcao = "C";
	}

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdpctant>".$cdpctant."</cdpctant>";
	$xml .= "   <cdpctnov>".$cdpctnov."</cdpctnov>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, "MANPAC", "MIGRA_PACOTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		echo 'showConfirmacao("Confirma a desativa&ccedil;&atilde;o e migra&ccedil;&atilde;o do Servi&ccedil;o Cooperativo?", "Confirma&ccedil;&atilde;o - Ayllos", "migracaoPacote();aux_manpac = 6;", "cBtnConcluir.focus()", "sim.gif", "nao.gif");';		
	}	
?>
