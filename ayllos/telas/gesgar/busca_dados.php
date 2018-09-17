<?php
	/*!
	 * FONTE        : busca_dados.php
	 * CRIAÇÃO      : Jean Michel       
	 * DATA CRIAÇÃO : 18/02/2016
	 * OBJETIVO     : Rotina consulta dos dados da tela GESGAR
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
	if (!isset($_POST["cddopcao"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}else{
		$cddopcao = !isset($_POST["cddopcao"]) ? 0 : $_POST["cddopcao"];			
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	
	$xmlResult = mensageria($xml, "GESGAR", "GESGAR_BUSCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',$funcaoAposErro,false);
		exit();
	}else{
		echo("cNrdemsgs.val(".$xmlObj->roottag->tags[0]->tags[0]->cdata.");");
		echo("cNrdesnhs.val(".$xmlObj->roottag->tags[0]->tags[1]->cdata.");");
		
		if($cddopcao == "C"){
			echo("cNrdesnhs.desabilitaCampo();");	
			echo("cNrdemsgs.desabilitaCampo();");	
			echo("cBtnVoltar.focus();");			
		}else{
			echo("cNrdemsgs.habilitaCampo();");
			echo("cNrdesnhs.habilitaCampo();");
			echo("cNrdemsgs.focus();");
		}
		exit();		
	}

?>