<?php

	/**************************************************************************************
	  Fonte: efetuar_devolucao_cotas.php                                               
	  Autor: Mateus Zimmermann - MoutS                                                  
	  Data : Julho/2017                      		 	Última Alteração: 14/11/2017
	                                                                   
	  Objetivo  : Efetuar o saque parcial de cotas
	                                                                 
	  Alterações:  14/11/2017 - Ajuste decorrente a remoção de informações de parcelamento (Jonata - RKAM P364).
	                                                                  
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
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	$rowiddes = (isset($_POST["rowiddes"])) ? $_POST["rowiddes"] : 0;
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$vldcotas = (isset($_POST["vldcotas"])) ? $_POST["vldcotas"] : 0;
	$mtdemiss = (isset($_POST["mtdemiss"])) ? $_POST["mtdemiss"] : 0;
	$dtdemiss = (isset($_POST["dtdemiss"])) ? $_POST["dtdemiss"] : '';
	
	validaDados();
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	 <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	 <vldcotas>".$vldcotas."</vldcotas>";
	$xml .= "    <formadev>1</formadev>";
	$xml .= "    <qtdparce>0</qtdparce>";
	$xml .= "    <datadevo>".$dtdemiss."</datadevo>";
	$xml .= "    <mtdemiss>".$mtdemiss."</mtdemiss>";
	$xml .= "    <dtdemiss>".$dtdemiss."</dtdemiss>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "MATRIC", "DEVOLUCAO_COTAS_MATRIC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		//Esta sendo utilizado a função utf8_encode devido ao SICREDI nos retornar mensagens com acentuação.
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
				 
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'input\',\'#frmSaqueParcial\').removeClass(\'campoErro\');$(\'#'.$nmdcampo.'\',\'#frmSaqueParcial\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmSaqueParcial\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
							
	}

	// Atualizar a tabela tb_cotas_saque_controle
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	 <rowid>".$rowiddes."</rowid>";
	$xml .= "	 <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_CADMAT", "ATUALIZA_TBCOTAS_SAQUE_CONTROLE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','',false);		
							
	}   	
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso','Alerta - Aimaro','controlaVoltar();',false);
	
	function validaDados(){
		
		//Data de demissao
        if (  $GLOBALS["dtdemiss"] == '' ){
            exibirErro('error','Data de demiss&atilde;o inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Motivo da demissao
        if (  $GLOBALS["mtdemiss"] == 0 ){
            exibirErro('error','Motivo da demiss&atilde;o inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
	}
	
?>



				


				

