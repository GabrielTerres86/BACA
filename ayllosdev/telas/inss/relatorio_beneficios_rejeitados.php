<?php

	/***********************************************************************************
	  Fonte: relatorio_beneficios_rejeitados.php                                               
	  Autor: Adriano                                                  
	  Data : Fevereiro/2014                   		  Última Alteração: 10/03/2015
	                                                                   
	  Objetivo  : Busca o relatório de beneficios rejeitados criado pelo
			      crps648.p para ser apresentado em tela.
	  
	                                                                 
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
		
	$xmlSolicitaRejeitados  = "";
	$xmlSolicitaRejeitados .= "<Root>";
	$xmlSolicitaRejeitados .= "   <Dados>";
	$xmlSolicitaRejeitados .= "	     <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaRejeitados .= "      <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaRejeitados .= "   </Dados>";
	$xmlSolicitaRejeitados .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaRejeitados, "INSS", "RELREJINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicitaRejeitados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaRejeitados->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjSolicitaRejeitados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjSolicitaRejeitados->roottag->tags[0]->attributes['NMDCAMPO'];
					
		if(empty ($nmdcampo)){ 
			$nmdcampo = "tprelato";
		}
		
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'input\',\'#divRelatorio\').removeClass(\'campoErro\');unblockBackground(); $(\'#'.$nmdcampo.'\',\'#divRelatorio\').habilitaCampo(); focaCampoErro(\'#'.$nmdcampo.'\',\'divRelatorio\');',false);			
					
	}   
	
	$nmarqpdf = $xmlObjSolicitaRejeitados->roottag->tags[0]->tags[0]->cdata;	
	
	echo 'Gera_Impressao("'.$nmarqpdf.'","$(\"#tprelato\",\"#divRelatorio\").focus();unblockBackground();");';			
		
	
			
?>



				


				

