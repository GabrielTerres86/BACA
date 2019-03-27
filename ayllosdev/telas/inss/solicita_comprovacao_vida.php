<?php

	/**************************************************************************************
	  Fonte: solicita_comprovacao_vida.php                                               
	  Autor: Adriano                                                  
	  Data : Junho/2013                      		 	Última Alteração: 22/03/2019
	                                                                   
	  Objetivo  : Solicita comprovação de vida
	                                                                 
	  Alterações: 10/03/2015 - Realizado a chamada da rotina direto no oracle
                             devido a conversão para PLSQSL (Adriano).
                 
                25/11/2015 - Adicionada verificacao para gerar contrato
                             somente quando o beneficiario não tiver senha
                             de internet cadastrada. Projeto 255 (Lombardi).
							 
				22/03/2019 - Ajuste para desbloquear a tela corretamente
                              (Adriano - SCTASK0052896).
	                                                                  
	**************************************************************************************/


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
	$nmextttl = (isset($_POST["nmextttl"])) ? $_POST["nmextttl"] : '';
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : 0;
	$cdorgins = (isset($_POST["cdorgins"])) ? $_POST["cdorgins"] : 0;
	$cdagepac = (isset($_POST["cdagepac"])) ? $_POST["cdagepac"] : 0;
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;
	$tpnrbene = (isset($_POST["tpnrbene"])) ? $_POST["tpnrbene"] : '';
	$idbenefi = (isset($_POST["idbenefi"])) ? $_POST["idbenefi"] : 0;
	$cdagesic = (isset($_POST["cdagesic"])) ? $_POST["cdagesic"] : 0;
	$respreno = (isset($_POST["respreno"])) ? $_POST["respreno"] : '';	
	$nmprocur = (isset($_POST["nmprocur"])) ? $_POST["nmprocur"] : '';	
	$nrdocpro = (isset($_POST["nrdocpro"])) ? $_POST["nrdocpro"] : '';	
	$dtvalprc = (isset($_POST["dtvalprc"])) ? $_POST["dtvalprc"] : '';	
	$temsenha = (isset($_POST["temsenha"])) ? $_POST["temsenha"] : false;
	
	/*Se a chamda deste fonte veio através do processo de validação de senha ou não,  deverá ter o retorno conforme abaixo para desbloquear corretamente
	o fundo. Caso contrário, a tela permanece bloqueada impedindo que o operador possa navegar nela.*/
	$metodoErro = $temsenha != 'true' ? 'blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));' : 'unblockBackground();';
	
	$dsiduser = session_id();	
	
	validaDados();
	
	$xmlSolicitaComprovacaoVida  = "";
	$xmlSolicitaComprovacaoVida .= "<Root>";
	$xmlSolicitaComprovacaoVida .= "   <Dados>";
	$xmlSolicitaComprovacaoVida .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaComprovacaoVida .= "   	 <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaComprovacaoVida .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xmlSolicitaComprovacaoVida .= "     <nmextttl>".$nmextttl."</nmextttl>";
	$xmlSolicitaComprovacaoVida .= "     <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlSolicitaComprovacaoVida .= "     <idseqttl>".$idseqttl."</idseqttl>";
	$xmlSolicitaComprovacaoVida .= "     <cdorgins>".$cdorgins."</cdorgins>";
	$xmlSolicitaComprovacaoVida .= "     <nrrecben>".$nrrecben."</nrrecben>";
	$xmlSolicitaComprovacaoVida .= "     <tpnrbene>".$tpnrbene."</tpnrbene>";
	$xmlSolicitaComprovacaoVida .= "     <cdagepac>".$cdagepac."</cdagepac>";
	$xmlSolicitaComprovacaoVida .= "     <idbenefi>".$idbenefi."</idbenefi>";
	$xmlSolicitaComprovacaoVida .= "     <cdagesic>".$cdagesic."</cdagesic>";	
	$xmlSolicitaComprovacaoVida .= "     <respreno>".$respreno."</respreno>";	
	$xmlSolicitaComprovacaoVida .= "     <nmprocur>".$nmprocur."</nmprocur>";	
	$xmlSolicitaComprovacaoVida .= "     <nrdocpro>".$nrdocpro."</nrdocpro>";	
	$xmlSolicitaComprovacaoVida .= "     <dtvalprc>".$dtvalprc."</dtvalprc>";	
	$xmlSolicitaComprovacaoVida .= "     <dsiduser>".$dsiduser."</dsiduser>";	
	$xmlSolicitaComprovacaoVida .= "     <flgerlog>1</flgerlog>";	
	$xmlSolicitaComprovacaoVida .= "     <temsenha>".$temsenha."</temsenha>";	
	$xmlSolicitaComprovacaoVida .= "   </Dados>";
	$xmlSolicitaComprovacaoVida .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaComprovacaoVida, "INSS", "CMPVIDAINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicitaComprovacaoVida = getObjectXML($xmlResult);
	 
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaComprovacaoVida->roottag->tags[0]->name) == "ERRO") {
	
		//Esta sendo utilizado a função utf8_encode devido ao SICREDI nos retornar mensagens com acentuação.
		$msgErro = utf8_encode($xmlObjSolicitaComprovacaoVida->roottag->tags[0]->tags[0]->tags[4]->cdata);
		if($temsenha == 'true'){
			exibirErro('error',$msgErro,'Alerta - Aimaro',$metodoErro,false);	
		}else{		
			exibirErro('error',$msgErro,'Alerta - Aimaro',$metodoErro,false);		
		}			
	}   	
	
	include('altera_secao_nmrotina.php');	
	
	$nmarqpdf = $xmlObjSolicitaComprovacaoVida->roottag->tags[0]->tags[1]->cdata;
	$msgretor = $xmlObjSolicitaComprovacaoVida->roottag->tags[0]->tags[2]->cdata;
	
	$strGeraImpressao = $temsenha != 'true' ? 'Gera_Impressao(\''.$nmarqpdf.'\',\'fechaRotina($(\"#divRotina\"));solicitaConsultaBeneficiario(\"C\");\');' : 'fechaRotina($(\"#divRotina\"));solicitaConsultaBeneficiario(\"C\");';
  
  
	if($msgretor != ''){
		exibirErro('inform',$msgretor,'Alerta - Aimaro',$strGeraImpressao,false);		
	
	}else{		
		echo $strGeraImpressao;
			
	}
					
	function validaDados(){
		
		//Conta
		if ( $GLOBALS["nrdconta"] == 0){ 
			exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);
		}
		
		//CPF
		if ( $GLOBALS["nrcpfcgc"] == 0){ 
			exibirErro('error','CPF inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);
		}
		
		//Nome do beneficiário
		if ( $GLOBALS["nmextttl"] == ""){ 
			exibirErro('error','Nome inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
		}
		
		//Orgão pagador
		if ( $GLOBALS["cdorgins"] == 0){ 
			exibirErro('error','&Oacute;rg&atilde;o pagador inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
		}
		
		//NB
		if ( $GLOBALS["nrrecben"] == 0){ 
			exibirErro('error','NB inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
		}
		
		//Tipo do NB
		if ( $GLOBALS["tpnrbene"] == ""){ 
			exibirErro('error','Tipo do NB inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
		}
		
		//Unidade de atendimento
		if ( $GLOBALS["cdagepac"] == ""){ 
			exibirErro('error','Unidade de atendimento inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
		}
		
		//ID do beneficiário
		if ( $GLOBALS["idbenefi"] == 0){ 
			exibirErro('error','ID do benefici&aacute;rio inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
		}
		
		//Agência SICREDI
		if ( $GLOBALS["cdagesic"] == 0){ 
			exibirErro('error','Ag&ecirc;ncia SCIREDI inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
		}
		
		//Responsavel pela renovacao
		if ( $GLOBALS["respreno"] != 'PROCURADOR' && $GLOBALS["respreno"] != 'BENEFICIARIO'){ 
			exibirErro('error','Respons&aacute;vel pela renova&ccedil;&atilde;o inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
		}
		
		if ( $GLOBALS["respreno"] == 'PROCURADOR'){ 
			
			//Nome do procurador
			if ( $GLOBALS["nmprocur"] == ''){ 
				exibirErro('error','Nome do procurador inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
			}
			
			//CPF do procurador
			if ( $GLOBALS["nrdocpro"] == ''){ 
				exibirErro('error','C.P.F. do procurador inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
			}
				
			if ($GLOBALS["dtvalprc"] == '' ){
				exibirErro('error','Validade do procurador inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divComprovaVida\').focus();'.$GLOBALS["metodoErro"],false);			
			}
							
		}
	
	}
	
?>



				


				

