<?php

	/******************************************************************************************
	  Fonte: solicita_troca_op_conta_corrente_entre_coop.php                                               
	  Autor: Adriano                                                  
	  Data : Maio/2013                       					Última Alteração: 25/11/2015
	                                                                   
	  Objetivo  : Solicita alteracao de OP/Conta Corrente para o beneficio 
			      em questão de uma cooperativa para outra.
	                                                                 
	  Alterações: 24/09/2014 - Ajuste na mensagem exibida ao tentar trocar o OP para mesma
							   cooperativa (Adriano).
							   
				  10/03/2015 - Realizado a chamada da rotina direto no oracle
                             devido a conversão para PLSQSL (Adriano).
                             
                25/11/2015 - Adicionada verificacao para gerar contrato
                             somente quando o beneficiario não tiver senha
                             de internet cadastrada. Projeto 255 (Lombardi).
	                                                                  
	******************************************************************************************/

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
		
	$c = array('.', '-');
	
	$dtcompvi = (isset($_POST["dtcompvi"])) ? $_POST["dtcompvi"] : ''; 
	$cdagepac = (isset($_POST["cdagepac"])) ? $_POST["cdagepac"] : 0;     
	$cdagesic = (isset($_POST["cdagesic"])) ? $_POST["cdagesic"] : 0;     
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;     
	$dscsitua = (isset($_POST["dscsitua"])) ? $_POST["dscsitua"] : '';    
	$idbenefi = (isset($_POST["idbenefi"])) ? $_POST["idbenefi"] : 0;     
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;     
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : 0;     
	$nmbairro = (isset($_POST["nmbairro"])) ? $_POST["nmbairro"] : '';    
	$nrcepend = (isset($_POST["nrcepend"])) ? $_POST["nrcepend"] : 0;     
	$dsendere = (isset($_POST["dsendere"])) ? $_POST["dsendere"] : '';    
	$nrendere = (isset($_POST["nrendere"])) ? $_POST["nrendere"] : '';    
	$nmcidade = (isset($_POST["nmcidade"])) ? $_POST["nmcidade"] : '';    
	$cdufende = (isset($_POST["cdufende"])) ? $_POST["cdufende"] : '';    
	$nmbenefi = (isset($_POST["nmbenefi"])) ? $_POST["nmbenefi"] : '';     
	$nrdddtfc = (isset($_POST["nrdddtfc"])) ? $_POST["nrdddtfc"] : 0;     
	$nrtelefo = (isset($_POST["nrtelefo"])) ? $_POST["nrtelefo"] : 0;     
	$cdsexotl = (isset($_POST["cdsexotl"])) ? $_POST["cdsexotl"] : 0;     
	$nomdamae = (isset($_POST["nomdamae"])) ? $_POST["nomdamae"] : '';   
	$cdcopant = (isset($_POST["cdcopant"])) ? $_POST["cdcopant"] : 0;   
	$cdorgins = (isset($_POST["cdorgins"])) ? $_POST["cdorgins"] : 0;     
	$orgpgant = (isset($_POST["orgpgant"])) ? $_POST["orgpgant"] : 0;     
	$nrdconta = (isset($_POST["nrdconta"])) ? str_ireplace($c, '',$_POST["nrdconta"]) : 0;     
	$nrctaant = (isset($_POST["nrctaant"])) ? str_ireplace($c, '',$_POST["nrctaant"]) : 0;     
	$nrcpfant = (isset($_POST["nrcpfant"])) ? $_POST["nrcpfant"] : 0;     
	$cdcooper = $glbvars["cdcooper"];
	$temsenha = (isset($_POST["temsenha"])) ? $_POST["temsenha"] : false;     
	
	$dsiduser = session_id();	
		
	validaDados();
	
		
	$xmlSolicitaAlteracao  = "";
	$xmlSolicitaAlteracao .= "<Root>";
	$xmlSolicitaAlteracao .= " <Dados>";
	$xmlSolicitaAlteracao .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaAlteracao .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaAlteracao .= "   <cdcopant>".$cdcopant."</cdcopant>";
	$xmlSolicitaAlteracao .= "   <cdorgins>".$cdorgins."</cdorgins>";
	$xmlSolicitaAlteracao .= "   <orgpgant>".$orgpgant."</orgpgant>";
	$xmlSolicitaAlteracao .= "   <nrrecben>".$nrrecben."</nrrecben>";
	$xmlSolicitaAlteracao .= "   <tpnrbene>NB</tpnrbene>";
	$xmlSolicitaAlteracao .= "   <tpdpagto>CONTA CORRENTE</tpdpagto>";
	$xmlSolicitaAlteracao .= "   <dscsitua>".$dscsitua."</dscsitua>";
	$xmlSolicitaAlteracao .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlSolicitaAlteracao .= "   <nrctaant>".$nrctaant."</nrctaant>";
	$xmlSolicitaAlteracao .= "   <cdagepac>".$cdagepac."</cdagepac>";
	$xmlSolicitaAlteracao .= "   <idbenefi>".$idbenefi."</idbenefi>";
	$xmlSolicitaAlteracao .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlSolicitaAlteracao .= "   <nrcpfant>".$nrcpfant."</nrcpfant>";
	$xmlSolicitaAlteracao .= "   <idseqttl>".$idseqttl."</idseqttl>";
	$xmlSolicitaAlteracao .= "   <nmbairro>".$nmbairro."</nmbairro>";
	$xmlSolicitaAlteracao .= "   <nrcepend>".$nrcepend."</nrcepend>";
	$xmlSolicitaAlteracao .= "   <dsendere>".$dsendere."</dsendere>";
	$xmlSolicitaAlteracao .= "   <nrendere>".$nrendere."</nrendere>";
	$xmlSolicitaAlteracao .= "   <nmcidade>".$nmcidade."</nmcidade>";
	$xmlSolicitaAlteracao .= "   <cdufende>".$cdufende."</cdufende>";
	$xmlSolicitaAlteracao .= "   <cdagesic>".$cdagesic."</cdagesic>";	
	$xmlSolicitaAlteracao .= "   <nmbenefi>".$nmbenefi."</nmbenefi>";	
	$xmlSolicitaAlteracao .= "   <dtcompvi>".$dtcompvi."</dtcompvi>";	
	$xmlSolicitaAlteracao .= "   <nrdddtfc>".$nrdddtfc."</nrdddtfc>";	
	$xmlSolicitaAlteracao .= "   <nrtelefo>".$nrtelefo."</nrtelefo>";	
	$xmlSolicitaAlteracao .= "   <cdsexotl>".$cdsexotl."</cdsexotl>";	
	$xmlSolicitaAlteracao .= "   <nomdamae>".$nomdamae."</nomdamae>";	
	$xmlSolicitaAlteracao .= "   <flgerlog>1</flgerlog>";	
	$xmlSolicitaAlteracao .= "   <dsiduser>".$dsiduser."</dsiduser>";	
	$xmlSolicitaAlteracao .= "   <temsenha>".$temsenha."</temsenha>";	
	$xmlSolicitaAlteracao .= " </Dados>";
	$xmlSolicitaAlteracao .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaAlteracao, "INSS", "ALTOPCCCOPSINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicitaAlteracao = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaAlteracao->roottag->tags[0]->name) == "ERRO") {
	
		//Esta sendo utilizado a função utf8_encode devido ao SICREDI nos retornar mensagens com acentuação.
		$msgErro  = utf8_encode($xmlObjSolicitaAlteracao->roottag->tags[0]->tags[0]->tags[4]->cdata);
		$nmdcampo = $xmlObjSolicitaAlteracao->roottag->tags[0]->attributes['NMDCAMPO'];
			
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input','#frmTrocaDomicilio').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmTrocaDomicilio');";  }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
					
	}   

	$nmarqpdf = $xmlObjSolicitaAlteracao->roottag->tags[0]->tags[1]->cdata;
	
	$strGeraImpressao = $temsenha != 'true' ? 'Gera_Impressao(\"'.$nmarqpdf.'\",\"fechaRotina($(\'#divRotina\'));solicitaConsultaBeneficiario(\'C\');\");' : 'fechaRotina($(\"#divRotina\"));solicitaConsultaBeneficiario(\"C\");';
	
  exibirErro('inform','Alteracao efetuada com sucesso.','Alerta - Aimaro',$strGeraImpressao,false);
	
	function validaDados(){
				
		//Conta x Conta antiga
		if ( $GLOBALS["nrdconta"] == $GLOBALS["nrctaant"]){ 
			exibirErro('error','Benef&iacute;cio j&aacute; existe na conta informada.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//Coperativa antiga x cooperativa nova
		if ( $GLOBALS["cdcopant"] == $GLOBALS["cdcooper"]){ 
			exibirErro('error','Para altera&ccedil;&atilde;o entre mesma cooperativa, utilize a rotina Troca Conta da op&ccedil;&atilde;o (C)onsulta.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}		
				
		//Conta
		if ( $GLOBALS["nrdconta"] == 0){ 
			exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}		
		
		//NB
		if ( $GLOBALS["nrrecben"] == 0){ 
			exibirErro('error','NB n&atilde;o foi informado.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}	
		
		//Filiação
		if ( $GLOBALS["nomdamae"] == ''){ 
			exibirErro('error','Filia&ccedil;&atilde;o inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//Unidade de atendimento
		if ( $GLOBALS["cdagepac"] == 0){ 
			exibirErro('error','Unidade de atendimento inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//Situação
		if ( $GLOBALS["dscsitua"] == ''){ 
			exibirErro('error','Situa&ccedil;&atilde;o inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//Agência SICREDI
		if ( $GLOBALS["cdagesic"] == 0){ 
			exibirErro('error','Ag&ecirc;ncia SICREDI inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//CPF
		if ( $GLOBALS["nrcpfcgc"] == 0){ 
			exibirErro('error','CPF inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//ID beneficiário
		if ( $GLOBALS["idbenefi"] == 0){ 
			exibirErro('error','C&oacute;digo do benefici&aacute;rio inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//UF
		if ( $GLOBALS["cdufende"] == ''){ 
			exibirErro('error','UF inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
			
		//Conta antiga
		if ( $GLOBALS["nrctaant"] == 0){ 
			exibirErro('error','Conta antiga inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//CPF antigo
		if ( $GLOBALS["nrcpfant"] == 0){ 
			exibirErro('error','CPF antigo inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
	}
	
			 
?>