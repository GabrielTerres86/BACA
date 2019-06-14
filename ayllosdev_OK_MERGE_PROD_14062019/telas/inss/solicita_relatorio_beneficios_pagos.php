<?php

	/************************************************************************************
	  Fonte: solicita_relatorio_beneficios_pagos.php                                               
	  Autor: Adriano                                                  
	  Data : Junho/2013                      			 Última Alteração: 10/03/2015 
	                                                                   
	  Objetivo  : Solicita relatorio de beneficios pagos
	                                                                 
	  Alterações: 10/03/2015 - Realizado a chamada da rotina direto no oracle
							   devido a conversão para PLSQSL
							   (Adriano).											   			  
	                                                                  
	************************************************************************************/
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
			
	$cdagesel = (isset($_POST["cdagesel"])) ? $_POST["cdagesel"] : '';
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;
	$dtinirec = (isset($_POST["dtinirec"])) ? $_POST["dtinirec"] : '';	
	$dtfinrec = (isset($_POST["dtfinrec"])) ? $_POST["dtfinrec"] : '';	
	$dsiduser = session_id();		
	
	validaDados();
	
	$xmlSolicitaRelatorioBeneficiosPagos  = "";
	$xmlSolicitaRelatorioBeneficiosPagos .= "<Root>";
	$xmlSolicitaRelatorioBeneficiosPagos .= " <Dados>";
	$xmlSolicitaRelatorioBeneficiosPagos .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaRelatorioBeneficiosPagos .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaRelatorioBeneficiosPagos .= "    <cdagesel>".$cdagesel."</cdagesel>";
	$xmlSolicitaRelatorioBeneficiosPagos .= "     <nrrecben>".$nrrecben."</nrrecben>";
	$xmlSolicitaRelatorioBeneficiosPagos .= "     <tpnrbene>NB</tpnrbene>";
	$xmlSolicitaRelatorioBeneficiosPagos .= "     <dtinirec>".$dtinirec."</dtinirec>";	
	$xmlSolicitaRelatorioBeneficiosPagos .= "     <dtfinrec>".$dtfinrec."</dtfinrec>";	
	$xmlSolicitaRelatorioBeneficiosPagos .= "     <tpconrel>PAGOS</tpconrel>";	
	$xmlSolicitaRelatorioBeneficiosPagos .= "     <idtiprel>PAGOS</idtiprel>";	
	$xmlSolicitaRelatorioBeneficiosPagos .= "     <dsiduser>".$dsiduser."</dsiduser>";	
	$xmlSolicitaRelatorioBeneficiosPagos .= " </Dados>";
	$xmlSolicitaRelatorioBeneficiosPagos .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaRelatorioBeneficiosPagos, "INSS", "RELPAGOSPAGARINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicitaRelatorioBeneficiosPagos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaRelatorioBeneficiosPagos->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjSolicitaRelatorioBeneficiosPagos->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjSolicitaRelatorioBeneficiosPagos->roottag->tags[0]->attributes['NMDCAMPO'];
			
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input','#frmRelatorioBeneficiosPagos').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmRelatorioBeneficiosPagos');";  }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro.'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			
	}   
	
	exibirErro('inform','Solicita&ccedil;&atilde;o efetuada com sucesso. Em alguns instantes o relat&oacute;rio estar&aacute; dispon&iacute;vel na op&ccedil;&atilde;o Visualizar.','Alerta - Aimaro','controlaVoltar(\'V7\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);		
	
	function validaDados(){
		
		//Data inicio do recebimento
		if ( $GLOBALS["dtinirec"] == ''){ 
			exibirErro('error','Data inicial de pagamento n&atilde;o informada.','Alerta - Aimaro','$(\'#dtinirec\',\'#frmRelatorioBeneficiosPagos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		//Data final do recebimento
		if ( $GLOBALS["dtfinrec"] == ''){ 
			exibirErro('error','Data final de pagamento n&atilde;o informada.','Alerta - Aimaro','$(\'#dtfinrec\',\'#frmRelatorioBeneficiosPagos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
							
	}
	
?>



				


				

