<?php

	/*************************************************************************
	  Fonte: solicita_troca_domicilio.php                                               
	  Autor: Adriano                                                  
	  Data : Maio/2013                       Última Alteração: 25/11/2015
	                                                                   
	  Objetivo  : Solicita troca de domicilio para o beneficio em questão.
	                                                                 
	  Alterações: 10/03/2015 - Realizado a chamada da rotina direto no oracle
                             devido a conversão para PLSQSL (Adriano).										   			  
                
                25/11/2015 - Adicionada verificacao para gerar contrato
                             somente quando o beneficiario não tiver senha
                             de internet cadastrada. Projeto 255 (Lombardi).
	                                                                  
	***********************************************************************/


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
	
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : 0;	
	$cdorgins = (isset($_POST["cdorgins"])) ? $_POST["cdorgins"] : 0;
	$cdagepac = (isset($_POST["cdagepac"])) ? $_POST["cdagepac"] : 0;
	$cdagesic = (isset($_POST["cdagesic"])) ? $_POST["cdagesic"] : 0;
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
	$nmbairro = (isset($_POST["nmbairro"])) ? $_POST["nmbairro"] : '';
	$nrcepend = (isset($_POST["nrcepend"])) ? $_POST["nrcepend"] : 0;
	$dsendres = (isset($_POST["dsendres"])) ? $_POST["dsendres"] : '';
	$nrendere = (isset($_POST["nrendere"])) ? $_POST["nrendere"] : '';
	$nmcidade = (isset($_POST["nmcidade"])) ? $_POST["nmcidade"] : '';
	$cdufdttl = (isset($_POST["cdufdttl"])) ? $_POST["cdufdttl"] : '';
    $nmextttl = (isset($_POST["nmextttl"])) ? $_POST["nmextttl"] : '';
	$nmmaettl = (isset($_POST["nmmaettl"])) ? $_POST["nmmaettl"] : '';
	$nrdddtfc = (isset($_POST["nrdddtfc"])) ? $_POST["nrdddtfc"] : 0;
	$nrtelefo = (isset($_POST["nrtelefo"])) ? $_POST["nrtelefo"] : 0;
	$cdsexotl = (isset($_POST["cdsexotl"])) ? $_POST["cdsexotl"] : 0;
	$dtnasttl = (isset($_POST["dtnasttl"])) ? $_POST["dtnasttl"] : '';
	$nrdconta = (isset($_POST["nrdconta"])) ? str_ireplace($c, '',$_POST["nrdconta"]) : 0;
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;
	$temsenha = (isset($_POST["temsenha"])) ? $_POST["temsenha"] : 'false';
			
	$dsiduser = session_id();	
					
	validaDados();
		
	$xmlSolicitaAlteracao  = "";
	$xmlSolicitaAlteracao .= "<Root>";
	$xmlSolicitaAlteracao .= " <Dados>";
	$xmlSolicitaAlteracao .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaAlteracao .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaAlteracao .= "   <cdorgins>".$cdorgins."</cdorgins>";
	$xmlSolicitaAlteracao .= "   <nrrecben>".$nrrecben."</nrrecben>";
	$xmlSolicitaAlteracao .= "   <tpbenefi>NB</tpbenefi>";
	$xmlSolicitaAlteracao .= "   <tpdpagto>CONTA CORRENTE</tpdpagto>";
	$xmlSolicitaAlteracao .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlSolicitaAlteracao .= "   <cdagepac>".$cdagepac."</cdagepac>";
	$xmlSolicitaAlteracao .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlSolicitaAlteracao .= "   <idseqttl>".$idseqttl."</idseqttl>";
	$xmlSolicitaAlteracao .= "   <nmbairro>".$nmbairro."</nmbairro>";
	$xmlSolicitaAlteracao .= "   <nrcepend>".$nrcepend."</nrcepend>";
	$xmlSolicitaAlteracao .= "   <dsendres>".$dsendres."</dsendres>";
	$xmlSolicitaAlteracao .= "   <nrendere>".$nrendere."</nrendere>";
	$xmlSolicitaAlteracao .= "   <nmcidade>".$nmcidade."</nmcidade>";
	$xmlSolicitaAlteracao .= "   <cdufdttl>".$cdufdttl."</cdufdttl>";
	$xmlSolicitaAlteracao .= "   <cdagesic>".$cdagesic."</cdagesic>";	
	$xmlSolicitaAlteracao .= "   <nmextttl>".$nmextttl."</nmextttl>";	
	$xmlSolicitaAlteracao .= "   <nmmaettl>".$nmmaettl."</nmmaettl>";	
	$xmlSolicitaAlteracao .= "   <nrdddtfc>".$nrdddtfc."</nrdddtfc>";	
	$xmlSolicitaAlteracao .= "   <nrtelefo>".$nrtelefo."</nrtelefo>";		
	$xmlSolicitaAlteracao .= "   <cdsexotl>".$cdsexotl."</cdsexotl>";	
	$xmlSolicitaAlteracao .= "   <dtnasttl>".$dtnasttl."</dtnasttl>";	
	$xmlSolicitaAlteracao .= "   <dscsitua>NORMAL</dscsitua>";	
	$xmlSolicitaAlteracao .= "   <dsiduser>".$dsiduser."</dsiduser>";	
	$xmlSolicitaAlteracao .= "   <flgerlog>1</flgerlog>";	
  $xmlSolicitaAlteracao .= "   <temsenha>".$temsenha."</temsenha>";	
	$xmlSolicitaAlteracao .= " </Dados>";
	$xmlSolicitaAlteracao .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaAlteracao, "INSS", "TRCDOMINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicitaAlteracao = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaAlteracao->roottag->tags[0]->name) == "ERRO") {
	
		//Esta sendo utilizado a função utf8_encode devido ao SICREDI nos retornar mensagens com acentuação.
		$msgErro = utf8_encode($xmlObjSolicitaAlteracao->roottag->tags[0]->tags[0]->tags[4]->cdata);
		$nmdcampo = $xmlObjSolicitaAlteracao->roottag->tags[0]->attributes['NMDCAMPO'];
				
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input,select','#frmTrocaDomicilio').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmTrocaDomicilio');";  }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
				
	}   
	
	$nmarqpdf = $xmlObjSolicitaAlteracao->roottag->tags[0]->tags[1]->cdata;
	
	$strGeraImpressao = $temsenha != 'true' ? 'Gera_Impressao(\"'.$nmarqpdf.'\",\"fechaRotina($(\'#divRotina\'));solicitaConsultaBeneficiario(\'C\');\");' : 'fechaRotina($(\"#divRotina\"));solicitaConsultaBeneficiario(\"C\");';
	
  exibirErro('inform','Alteracao efetuada com sucesso.','Alerta - Aimaro',$strGeraImpressao,false);
  
		
	function validaDados(){
					
		//NB
		if ( $GLOBALS["nrrecben"] == 0 ){ 
			exibirErro('error','NB n&atilde;o foi informado!','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}	
		
		//Filiação
		if ( $GLOBALS["nmmaettl"] == ''){ 
			exibirErro('error','Filia&ccedil;&atilde;o inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//OP
		if ( $GLOBALS["cdorgins"] == 0){ 
			exibirErro('error','&Oacute;rg&atilde;o pagador inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}

		//Unidade de atendimento
		if ( $GLOBALS["cdagepac"] == 0){ 
			exibirErro('error','Unidade de atendimento inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
				
		//Agencia Sicredi
		if ( $GLOBALS["cdagesic"] == 0){ 
			exibirErro('error','Ag&ecirc;ncia SICREDI inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//Conta
		if ( $GLOBALS["nrdconta"] == 0){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//CPF	
		if ( $GLOBALS["nrcpfcgc"] == 0){ 
			exibirErro('error','CPF inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
		//Data de nascimento	
		if ( $GLOBALS["dtnasttl"] == ''){ 
			exibirErro('error','Data de nascimento inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmTrocaDomicilio\');',false);
		}
		
	}
			 
?>



				


				

