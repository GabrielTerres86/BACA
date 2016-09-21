<?php

	/********************************************************************************************
	  Fonte: busca_orgao_pagador.php                                               
	  Autor: Adriano                                                  
	  Data : Maio/2013                       						�ltima Altera��o: 10/03/2015
	                                                                   
	  Objetivo  : Busca o org�o pagador refente a conta em quest�o
	                                                                 
	  Altera��es: 10/03/2015 - Realizado a chamada da rotina direto no oracle
							   devido a convers�o para PLSQSL
							   (Adriano).	  
  										   			  
	                                                                  
	*******************************************************************************************/


	session_start();
	
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
		
	// Carrega permiss�es do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	validaDados();
		
	$xmlBuscaOP  = "";
	$xmlBuscaOP .= "<Root>";
	$xmlBuscaOP .= "    <Dados>";
	$xmlBuscaOP .= "	   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlBuscaOP .= "       <nrdconta>".$nrdconta."</nrdconta>";	
	$xmlBuscaOP .= "    </Dados>";
	$xmlBuscaOP .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaOP, "INSS", "BUSCAOPINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjectBuscaOP = getObjectXML($xmlResult);
				
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjectBuscaOP->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjectBuscaOP->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$mtdErro = "$('input','#frmTrocaOpContaCorrente').removeClass('campoErro');$('#cdorgins','#frmTrocaOpContaCorrente').val('');focaCampoErro('#nrdconta','frmTrocaOpContaCorrente');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));"; 
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
					
	}   
	
	$cdorgins = $xmlObjectBuscaOP->roottag->tags[0]->tags[0]->cdata;
	$cdagenci = $xmlObjectBuscaOP->roottag->tags[0]->tags[1]->cdata;
		
	echo '$("#cdorgins","#frmTrocaOpContaCorrente").val("'.$cdorgins.'");'; 
	echo '$("#cdagepac","#frmTrocaOpContaCorrente").val("'.$cdagenci.'");'; 	
	echo 'buscaTitulares(normalizaNumero($("#nrdconta","#frmTrocaOpContaCorrente").val()),"'.$cddopcao.'");';
			
	function validaDados(){		
			
		//Numero da conta
		if ( $GLOBALS["nrdconta"] == 0  ){ 
			exibirErro('error','Conta inv&aacute;lida!','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmTrocaOpContaCorrente\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
	}
			 
?>



				


				

