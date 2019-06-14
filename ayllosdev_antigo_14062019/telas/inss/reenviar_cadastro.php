<?php

	/***************************************************************************************
	  Fonte: reenviar_cadastro.php                                               
	  Autor: Jonata - Mouts                                                  
	  Data : Outubro/2018                      			 Última Alteração: 
	                                                                   
	  Objetivo  : Solicita reenvio de cadastro 
	                                                                 
	  Alterações: 
 										   			  
	                                                                  
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
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : 0;
		
	validaDados();
	
	$xmlReenviarCadastro  = "";
	$xmlReenviarCadastro .= "<Root>";
	$xmlReenviarCadastro .= " <Dados>";
	$xmlReenviarCadastro .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlReenviarCadastro .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlReenviarCadastro .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlReenviarCadastro .= "   <cdorgins>".$cdorgins."</cdorgins>";
	$xmlReenviarCadastro .= "   <nrrecben>".$nrrecben."</nrrecben>";	
	$xmlReenviarCadastro .= "   <idseqttl>".$idseqttl."</idseqttl>";
	$xmlReenviarCadastro .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlReenviarCadastro .= "   <flgerlog>1</flgerlog>";	
	$xmlReenviarCadastro .= " </Dados>";
	$xmlReenviarCadastro .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlReenviarCadastro, "INSS", "REENVIACADBENEF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjReenviarCadastro = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjReenviarCadastro->roottag->tags[0]->name) == "ERRO") {
	
		//Esta sendo utilizado a função utf8_encode devido ao SICREDI nos retornar mensagens com acentuação.
		$msgErro = $xmlObjReenviarCadastro->roottag->tags[0]->tags[0]->tags[4]->cdata;
			
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();',false);			
					
		
	}   
	
	include('altera_secao_nmrotina.php');
	
	exibirErro('inform','Cadastro reenviado com sucesso.','Alerta - Aimaro','solicitaConsultaBeneficiario($(\'#cddopcao\',\'#frmCabInss\').val());',false);
	

	function validaDados(){
		
		//NB
		if ( $GLOBALS["nrrecben"] == 0){ 
			exibirErro('error','NB deve ser informado.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();',false);
		}
					
		//OP
		if ( $GLOBALS["cdorgins"] == ''){ 
			exibirErro('error','&Oacute;rg&atilde;o pagador inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();',false);
		}		
		
		//OP
		if ( $GLOBALS["cdorgins"] == ''){ 
			exibirErro('error','&Oacute;rg&atilde;o pagador inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();',false);
		}			
				
		//Conta
		if ( $GLOBALS["nrdconta"] == 0){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();',false);
		}		
		
	}	
?>



				


				

