<?php

	/*****************************************************************************************************
	  Fonte: manter_ocupacoes.php                                               
	  Autor: Adriano                                                  
	  Data : Mar�o/2017                       						�ltima Altera��o: 
	                                                                   
	  Objetivo  : Respons�vel pela inclus�o/altera��o/exclus�o de ocupa��es.
	                                                                 
	  Altera��es:
	                                                                  
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
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$cdsubrot = (isset($_POST["cdsubrot"])) ? $_POST["cdsubrot"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nmrotina = $glbvars["nmrotina"];
	$glbvars["nmrotina"] = "OCUPACOES"; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cdsubrot)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdnatocp = (isset($_POST["cdnatocp"])) ? $_POST["cdnatocp"] : 0;
	$cdocupa  = (isset($_POST["cdocupa"])) ? $_POST["cdocupa"] : 0;
	$dsdocupa = (isset($_POST["dsdocupa"])) ? $_POST["dsdocupa"] : '';
	$rsdocupa = (isset($_POST["rsdocupa"])) ? $_POST["rsdocupa"] : '';
				
	validaDados();
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	   <cdnatocp>".$cdnatocp."</cdnatocp>";	
	$xml .= "	   <cdocupa>".$cdocupa."</cdocupa>";	
	$xml .= "	   <dsdocupa>".$dsdocupa."</dsdocupa>";	
	$xml .= "	   <rsdocupa>".$rsdocupa."</rsdocupa>";	
	$xml .= "	   <cdsubrot>".$cdsubrot."</cdsubrot>";	
	$xml .= "   </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_OCPPEP", "MANTEROCUPACOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$glbvars["nmrotina"] = $nmrotina;
	
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "dsdocupa";
		}
			
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','$(\'input\',\'#divDetalhesOcupacao\').removeClass(\'campoErro\');unblockBackground(); $(\'#'.$nmdcampo.'\',\'#divDetalhesOcupacao\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divDetalhesOcupacao\');',false);		
							
	}   
	
	if($cdsubrot == 'A'){
		exibirErro('inform','Ocupa&ccedil;&atilde;o alterada com sucesso!','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesDetalhesOcupacao\').click();',false);		
	}elseif($cdsubrot == 'E'){
		exibirErro('inform','Ocupa&ccedil;&atilde;o exclu&icirc;da com sucesso!','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesDetalhesOcupacao\').click();',false);		
	}elseif($cdsubrot == 'I'){
		exibirErro('inform','Ocupa&ccedil;&atilde;o inclu&icirc;da com sucesso!','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesDetalhesOcupacao\').click();',false);		
	}
		
	function validaDados(){
				
		//C�digo da ocupa��o
		if ( $GLOBALS["cdocupa"] == 0  ){ 
			exibirErro('error','C&oacute;digo de ocupa&ccedil;&atilde;o n&atilde;o informado!','Alerta - Ayllos','controlaVoltar(\'V4\');$(\'#cdocupa\',\'#divOcupacao\').habilitaCampo();focaCampoErro(\'cdocupa\',\'divOcupacao\');',false);
		}				
			
		//C�digo da natureza de ocupa��o
		if ( $GLOBALS["cdnatocp"] != '99'  ){ 
			exibirErro('error','C&oacute;digo da natureza inv&aacute;lido!','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesDetalhesOcupacao\').focus();',false);
		}
		
	}
			 
?>



				


				

