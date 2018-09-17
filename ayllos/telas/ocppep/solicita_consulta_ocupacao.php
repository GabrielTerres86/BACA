<?php

	/*****************************************************************************************************
	  Fonte: solicita_consulta_ocupacao.php                                               
	  Autor: Adriano                                                  
	  Data : Fevereiro/2017                       						Última Alteração: 
	                                                                   
	  Objetivo  : Solicita consulta de ocupação.
	                                                                 
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
	$cdocupa = (isset($_POST["cdocupa"])) ? $_POST["cdocupa"] : 0;
				
	validaDados();
	
	$xmlSolicitaConsulta  = "";
	$xmlSolicitaConsulta .= "<Root>";
	$xmlSolicitaConsulta .= "   <Dados>";
	$xmlSolicitaConsulta .= "	   <cdnatocp>".$cdnatocp."</cdnatocp>";	
	$xmlSolicitaConsulta .= "	   <cdocupa>".$cdocupa."</cdocupa>";	
	$xmlSolicitaConsulta .= "	   <cdsubrot>".$cdsubrot."</cdsubrot>";	
	$xmlSolicitaConsulta .= "   </Dados>";
	$xmlSolicitaConsulta .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaConsulta, "TELA_OCPPEP", "CONSOCUPACOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$glbvars["nmrotina"] = $nmrotina;
	
	$xmlObjSolicitaConsulta = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaConsulta->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjSolicitaConsulta->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjSolicitaConsulta->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdocupa";
		}
			
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','$(\'input\',\'#frmOcupacao\').removeClass(\'campoErro\');unblockBackground(); $(\'#'.$nmdcampo.'\',\'#divOcupacao\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divOcupacao\');',false);		
							
	}   
		
	$registros = $xmlObjSolicitaConsulta->roottag->tags;
	
	echo 'controlaLayout("5");';
	
	echo '$("#dsdocupa","#divDetalhesOcupacao").val("'.getByTagName($registros[$i]->tags,'dsdocupa').'");';
	echo '$("#rsdocupa","#divDetalhesOcupacao").val("'.getByTagName($registros[$i]->tags,'rsdocupa').'");';
	
	function validaDados(){
				
		//Código da natureza de ocupação
		if ( $GLOBALS["cdnatocp"] == 0  ){ 
			exibirErro('error','C&oacute;digo da natureza n&atilde;o informado!','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesOcupacao\').click();',false);
		}	

		//Código da ocupação
		if ( $GLOBALS["cdocupa"] == 0  ){ 
			exibirErro('error','C&oacute;digo da ocupa&ccedil;&atilde;o n&atilde;o informado!','Alerta - Ayllos','$(\'#cdocupa\',\'#divOcupacao\').habilitaCampo();focaCampoErro(\'cdocupa\',\'divOcupacao\');',false);
		}			
			
	}
			 
?>



				


				

