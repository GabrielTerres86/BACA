<?php

	/*****************************************************************************************************
	  Fonte: manter_ocupacoes.php                                               
	  Autor: Adriano                                                  
	  Data : Março/2017                       						Última Alteração: 
	                                                                   
	  Objetivo  : Responsável pela inclusão/alteração/exclusão de ocupações.
	                                                                 
	  Alterações:
	                                                                  
	*****************************************************************************************************/


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
	
	// Se ocorrer um erro, mostra crítica
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
				
		//Código da ocupação
		if ( $GLOBALS["cdocupa"] == 0  ){ 
			exibirErro('error','C&oacute;digo de ocupa&ccedil;&atilde;o n&atilde;o informado!','Alerta - Ayllos','controlaVoltar(\'V4\');$(\'#cdocupa\',\'#divOcupacao\').habilitaCampo();focaCampoErro(\'cdocupa\',\'divOcupacao\');',false);
		}				
			
		//Código da natureza de ocupação
		if ( $GLOBALS["cdnatocp"] != '99'  ){ 
			exibirErro('error','C&oacute;digo da natureza inv&aacute;lido!','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesDetalhesOcupacao\').focus();',false);
		}
		
	}
			 
?>



				


				

