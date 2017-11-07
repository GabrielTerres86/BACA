<?php

	/**************************************************************************************
	  Fonte: efetuar_devolucao_cotas.php                                               
	  Autor: Mateus Zimmermann - MoutS                                                  
	  Data : Julho/2017                      		 	Última Alteração:  
	                                                                   
	  Objetivo  : Efetuar o saque parcial de cotas
	                                                                 
	  Alterações:  
	                                                                  
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"C")) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$vldcotas = (isset($_POST["vldcotas"])) ? $_POST["vldcotas"] : 0;
	$formadev = (isset($_POST["formadev"])) ? $_POST["formadev"] : 0;
	$qtdparce = (isset($_POST["qtdparce"])) ? $_POST["qtdparce"] : 0;
	$datadevo = (isset($_POST["datadevo"])) ? $_POST["datadevo"] : 0;
	$mtdemiss = (isset($_POST["mtdemiss"])) ? $_POST["mtdemiss"] : 0;
	$dtdemiss = (isset($_POST["dtdemiss"])) ? $_POST["dtdemiss"] : '';
	
	validaDados();
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	 <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	 <vldcotas>".$vldcotas."</vldcotas>";
	$xml .= "    <formadev>".$formadev."</formadev>";
	$xml .= "    <qtdparce>".$qtdparce."</qtdparce>";
	$xml .= "    <datadevo>".$datadevo."</datadevo>";
	$xml .= "    <mtdemiss>".$mtdemiss."</mtdemiss>";
	$xml .= "    <dtdemiss>".$dtdemiss."</dtdemiss>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "CADA0003", "EFETUAR_DEVOLUCAO_COTAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		//Esta sendo utilizado a função utf8_encode devido ao SICREDI nos retornar mensagens com acentuação.
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
				 
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#frmSaqueParcial\').removeClass(\'campoErro\');$(\'#'.$nmdcampo.'\',\'#frmSaqueParcial\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmSaqueParcial\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
							
	}   	
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso','Alerta - Ayllos','controlaVoltar();',false);
	
	function validaDados(){
		
		//Data de demissao
        if (  $GLOBALS["dtdemiss"] == '' ){
            exibirErro('error','Data de demiss&atilde;o inv&aacute;lida.','Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Motivo da demissao
        if (  $GLOBALS["mtdemiss"] == 0 ){
            exibirErro('error','Motivo da demiss&atilde;o inv&aacute;lido.','Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
	}
	
?>



				


				

