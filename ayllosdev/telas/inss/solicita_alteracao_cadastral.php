<?php

	/***************************************************************************************
	  Fonte: solicita_alteracao_cadastral.php                                               
	  Autor: Adriano                                                  
	  Data : Maio/2013                      			 Última Alteração: 10/03/2015
	                                                                   
	  Objetivo  : Solicita alteracao do cadastro para o beneficio em questão.
	                                                                 
	  Alterações: 10/03/2015 - Realizado a chamada da rotina direto no oracle
							   devido a conversão para PLSQSL
							   (Adriano).
 										   			  
	                                                                  
	***************************************************************************************/


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
	$cdorgins = (isset($_POST["cdorgins"])) ? $_POST["cdorgins"] : 0;
	$cdagepac = (isset($_POST["cdagepac"])) ? $_POST["cdagepac"] : 0;
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;
	$tpnrbene = (isset($_POST["tpnrbene"])) ? $_POST["tpnrbene"] : '';
	$dscsitua = (isset($_POST["dscsitua"])) ? $_POST["dscsitua"] : '';
	$idbenefi = (isset($_POST["idbenefi"])) ? $_POST["idbenefi"] : 0;
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : 0;
	$nmbairro = (isset($_POST["nmbairro"])) ? $_POST["nmbairro"] : '';
	$nrcepend = (isset($_POST["nrcepend"])) ? $_POST["nrcepend"] : 0;
	$dsendere = (isset($_POST["dsendere"])) ? $_POST["dsendere"] : '';
	$nrendere = (isset($_POST["nrendere"])) ? $_POST["nrendere"] : 0;
	$nmcidade = (isset($_POST["nmcidade"])) ? $_POST["nmcidade"] : '';
	$cdufende = (isset($_POST["cdufende"])) ? $_POST["cdufende"] : '';
	$cdagesic = (isset($_POST["cdagesic"])) ? $_POST["cdagesic"] : 0;
	$nmbenefi = (isset($_POST["nmbenefi"])) ? $_POST["nmbenefi"] : '';
	$nrdddtfc = (isset($_POST["nrdddtfc"])) ? $_POST["nrdddtfc"] : 0;
	$nrtelefo = (isset($_POST["nrtelefo"])) ? $_POST["nrtelefo"] : 0;
	$dtcompvi = (isset($_POST["dtcompvi"])) ? $_POST["dtcompvi"] : '';
	$tpdosexo = (isset($_POST["tpdosexo"])) ? $_POST["tpdosexo"] : '';     
	$nomdamae = (isset($_POST["nomdamae"])) ? $_POST["nomdamae"] : '';   
	$dsiduser = session_id();
		
	validaDados();
	
	$xmlSolicitaAlteracao  = "";
	$xmlSolicitaAlteracao .= "<Root>";
	$xmlSolicitaAlteracao .= " <Dados>";
	$xmlSolicitaAlteracao .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaAlteracao .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaAlteracao .= "   <cdorgins>".$cdorgins."</cdorgins>";
	$xmlSolicitaAlteracao .= "   <nrrecben>".$nrrecben."</nrrecben>";
	$xmlSolicitaAlteracao .= "   <tpnrbene>".$tpnrbene."</tpnrbene>";
	$xmlSolicitaAlteracao .= "   <tpdpagto>CONTA CORRENTE</tpdpagto>";
	$xmlSolicitaAlteracao .= "   <dscsitua>".$dscsitua."</dscsitua>";
	$xmlSolicitaAlteracao .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlSolicitaAlteracao .= "   <cdagepac>".$cdagepac."</cdagepac>";
	$xmlSolicitaAlteracao .= "   <idbenefi>".$idbenefi."</idbenefi>";
	$xmlSolicitaAlteracao .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
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
	$xmlSolicitaAlteracao .= "   <tpdosexo>".$tpdosexo."</tpdosexo>";	
	$xmlSolicitaAlteracao .= "   <nomdamae>".$nomdamae."</nomdamae>";	
	$xmlSolicitaAlteracao .= "   <flgerlog>1</flgerlog>";	
	$xmlSolicitaAlteracao .= "   <dsiduser>".$dsiduser."</dsiduser>";	
	$xmlSolicitaAlteracao .= " </Dados>";
	$xmlSolicitaAlteracao .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaAlteracao, "INSS", "ALTCADINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicitaAlteracao = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaAlteracao->roottag->tags[0]->name) == "ERRO") {
	
		//Esta sendo utilizado a função utf8_encode devido ao SICREDI nos retornar mensagens com acentuação.
		$msgErro = utf8_encode($xmlObjSolicitaAlteracao->roottag->tags[0]->tags[0]->tags[4]->cdata);
		$nmdcampo = $xmlObjSolicitaAlteracao->roottag->tags[0]->attributes['NMDCAMPO'];
			
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input','#frmAlteracaoCadastral').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmAlteracaoCadastral');";  }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro.'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		
	}   
	
	include('altera_secao_nmrotina.php');
	
	echo 'fechaRotina($("#divRotina"));';
	exibirErro('inform','Cadastro atualizado com sucesso.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); solicitaConsultaBeneficiario($(\'#cddopcao\',\'#frmCabInss\').val());',false);
	

	function validaDados(){
		
		//NB
		if ( $GLOBALS["nrrecben"] == 0){ 
			exibirErro('error','NB deve ser informado.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		//Tipo do NB
		if ( $GLOBALS["tpnrbene"] == ''){ 
			exibirErro('error','Tipo do benef&iacute;cio inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		//Filiação
		if ( $GLOBALS["nomdamae"] == ''){ 
			exibirErro('error','Filia&ccedil;&atilde;o inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
			
		//OP
		if ( $GLOBALS["cdorgins"] == ''){ 
			exibirErro('error','&Oacute;rg&atilde;o pagador inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}		
		
		//Unidade de atendimento
		if ( $GLOBALS["cdagepac"] == 0){ 
			exibirErro('error','Unidade de atendimento inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}

		//Situação
		if ( $GLOBALS["dscsitua"] == ''){ 
			exibirErro('error','Situa&ccedil;&atilde;o inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		//Agência SICREDI
		if ( $GLOBALS["cdagesic"] == 0){ 
			exibirErro('error','Ag&ecirc;ncia SCIREDI inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}	
		
		//Conta
		if ( $GLOBALS["nrdconta"] == 0){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}	
		
		//CPF
		if ( $GLOBALS["nrcpfcgc"] == 0){ 
			exibirErro('error','CPF inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		//ID beneficiário
		if ( $GLOBALS["idbenefi"] == 0){ 
			exibirErro('error','C&oacute;digo do benefici&aacute;rio inv&acute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		//UF
		if ( $GLOBALS["cdufende"] == ''){ 
			exibirErro('error','UF inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
				
	}	
?>



				


				

