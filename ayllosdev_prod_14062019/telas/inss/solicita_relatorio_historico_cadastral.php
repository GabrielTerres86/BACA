<?php

	/***********************************************************************************
	  Fonte: solicita_relatorio_historico_cadastral.php                                               
	  Autor: Adriano                                                  
	  Data : Março/2015                     		  Última Alteração: 10/03/2015 
	                                                                   
	  Objetivo  : Solicita relatorio de historico cadastral
	                                                                 
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
		
	validaDados();
	
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;
	$dsiduser = session_id();			
		
	$xmlSolicitaRelatorioHistCadastral .= "";
	$xmlSolicitaRelatorioHistCadastral .= " <Root>";
	$xmlSolicitaRelatorioHistCadastral .= "    <Dados>";
	$xmlSolicitaRelatorioHistCadastral .= "	    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaRelatorioHistCadastral .= "        <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaRelatorioHistCadastral .= "        <nrrecben>".$nrrecben."</nrrecben>";
	$xmlSolicitaRelatorioHistCadastral .= "        <tpnrbene>NB</tpnrbene>";
	$xmlSolicitaRelatorioHistCadastral .= "        <dsiduser>".$dsiduser."</dsiduser>";	
	$xmlSolicitaRelatorioHistCadastral .= "    </Dados>";
	$xmlSolicitaRelatorioHistCadastral .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xmlSolicitaRelatorioHistCadastral, "INSS", "RELHISCADINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjSolicitaRelatorioHistCadastral = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaRelatorioHistCadastral->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjSolicitaRelatorioHistCadastral->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjSolicitaRelatorioHistCadastral->roottag->tags[0]->attributes['NMDCAMPO'];
		
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input','#frmRelatorioHistoricoCadastral').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmRelatorioHistoricoCadastral');$('#".$nmdcampo."','#frmRelatorioHistoricoCadastral').val('');";  }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro.'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			
	}   
	
	$nmarqpdf = $xmlObjSolicitaRelatorioHistCadastral->roottag->tags[0]->tags[0]->cdata;
		
	echo 'Gera_Impressao("'.$nmarqpdf.'","$(\"#nrrecben\",\"#frmRelatorioHistoricoCadastral\").val(\'\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';			
	
			
	function validaDados(){

		
	}	
			
?>



				


				

