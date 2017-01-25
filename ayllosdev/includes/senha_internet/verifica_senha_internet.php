<?php

	/*****************************************************************************************************
	  Fonte: verifica_senha_internet.php                                               
	  Autor: Lombardi                                                  
	  Data : Outubro/2016                       						�ltima Altera��o: 21/10/2016
	                                                                   
	  Objetivo  : Verifica situacao da senha do beneficiario.
	                                                                 
	  Altera��es: 21/10/2016 - Movido rotina para includes para uso generico - Odirlei Busana - AMcom 
					                                                                  
	*****************************************************************************************************/


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
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : "";
	$retorno  = (isset($_POST["retorno"])) ? $_POST["retorno"] : "";
  
	//Data
  if ( $idseqttl == "" ){
    exibirErro('error','O campo Sequencial do Titular n&atilde;o foi preenchido!','Alerta - Ayllos','',false);
  }
  
  if ( $nrdconta == "" ){
    exibirErro('error','O campo Numero da Conta n&atilde;o foi preenchido!','Alerta - Ayllos','',false);
  }
  
	$xmlConsultaLog  = "";
	$xmlConsultaLog .= "<Root>";
	$xmlConsultaLog .= "   <Dados>";
	$xmlConsultaLog .= "	   <nrdconta>".$nrdconta."</nrdconta>";	
	$xmlConsultaLog .= "	   <idseqttl>".$idseqttl."</idseqttl>";
	$xmlConsultaLog .= "   </Dados>";
	$xmlConsultaLog .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlConsultaLog, "INSS", "VERSENH", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjConsultaLog = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjConsultaLog->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjConsultaLog->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjConsultaLog->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrrecben";
		}
				 
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
							
	}
  
	$situacao = $xmlObjConsultaLog->roottag->tags[0]->cdata;
  //$situacao = 'INATIVA';
  
  switch($situacao) {
    
    case 'ATIVA':
      echo 'possui_senha_internet = true; solicitaSenhaInternet("'.$retorno.'","'.$nrdconta.'","'.$idseqttl.'");';
      break;
    
    case 'BLOQUEADA':
      exibirErro('error','Senha bloqueada.','Alerta - Ayllos','',false);
      break;

    case 'CANCELADA':
      echo 'possui_senha_internet = false;'.$retorno;
      break;
    case 'INATIVA':
      echo 'possui_senha_internet = false;'.$retorno;
      break;
      
  }