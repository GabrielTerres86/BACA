<?php

	/*****************************************************************************************
	  Fonte: solicita_demonstrativo.php                                               
	  Autor: Adriano                                                  
	  Data : Junho/2013                       				Última Alteração: 10/03/2015
	                                                                   
	  Objetivo  : Solicita demonstrativo
	                                                                 
	  Alterações: 10/03/2015 - Realizado a chamada da rotina direto no oracle
							   devido a conversão para PLSQSL
							   (Adriano).
	                                                                  
	*****************************************************************************************/


	session_start();
			
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
		
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);	
			
	}		
	
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;	
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;	
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;	
	$cdagesic = (isset($_POST["cdagesic"])) ? $_POST["cdagesic"] : 0;
	$dtvalida = (isset($_POST["dtvalida"])) ? $_POST["dtvalida"] : 0;	
	$dsiduser = session_id();		

	validaDados();
		
	$xmlSolicitaDemonstrativo  = "";
	$xmlSolicitaDemonstrativo .= "<Root>";
	$xmlSolicitaDemonstrativo .= " <Dados>";
	$xmlSolicitaDemonstrativo .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaDemonstrativo .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaDemonstrativo .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlSolicitaDemonstrativo .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlSolicitaDemonstrativo .= "   <nrrecben>".$nrrecben."</nrrecben>";
	$xmlSolicitaDemonstrativo .= "   <cdagesic>".$cdagesic."</cdagesic>";
	$xmlSolicitaDemonstrativo .= "   <dtvalida>".$dtvalida."</dtvalida>";	
	$xmlSolicitaDemonstrativo .= "   <dsiduser>".$dsiduser."</dsiduser>";	
	$xmlSolicitaDemonstrativo .= " </Dados>";
	$xmlSolicitaDemonstrativo .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaDemonstrativo, "INSS", "DEMONSINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicitaDemonstrativo = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaDemonstrativo->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjSolicitaDemonstrativo->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjSolicitaDemonstrativo->roottag->tags[0]->attributes['NMDCAMPO'];
				
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input','#frmDemonstrativo').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmDemonstrativo');";  }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
		
	}   
	
	$nmarqpdf  = $xmlObjSolicitaDemonstrativo->roottag->tags[0]->tags[1]->cdata;	
		
	echo 'Gera_Impressao("'.$nmarqpdf.'","$(\"#dtvalida\",\"#frmDemonstrativo\").focus();$(\"input[type=\'text\']\",\"#frmDemonstrativo\").val(\"\");");';
	
			
	function validaDados(){
		
		//Nrdconta
		if ( $GLOBALS["nrdconta"] == 0){ 
			exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'dtvalida\',\'frmDemonstrativo\');',false);
		}
		
		//Cdagesic
		if ( $GLOBALS["cdagesic"] == 0){ 
			exibirErro('error','Ag&ecirc;ncia inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'dtvalida\',\'frmDemonstrativo\');',false);
		}
		
		//Nrcpfcgc
		if ( $GLOBALS["nrcpfcgc"] == 0){ 
			exibirErro('error','CPF inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'dtvalida\',\'frmDemonstrativo\');',false);
		}
		
		//Dtvalida
		if ( $GLOBALS["dtvalida"] == 0){ 
			exibirErro('error','M&ecirc;s da compet&ecirc;ncia deve ser informado.','Alerta - Aimaro','focaCampoErro(\'dtvalida\',\'frmDemonstrativo\');',false);
		}	
		
		//Nrrecben
		if ( $GLOBALS["nrrecben"] == 0){ 
			exibirErro('error','NB deve ser informado.','Alerta - Aimaro','focaCampoErro(\'dtvalida\',\'frmDemonstrativo\');',false);
		}	
			
	}
	
?>



				


				

