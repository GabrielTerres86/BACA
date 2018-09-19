<?php

	/**************************************************************************************
	  Fonte: manter_conta_destino_ted_capital.php                                               
	  Autor: Jonata - RKAM                                                  
	  Data : Agosto/2017                       			Última Alteração:  
	                                                                   
	  Objetivo  : Gerencia a consulta/inclusão/alteração/exclusão de conta destino para envio de TED capital
	                                                                 
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
			
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';    
	$cdbantrf = (isset($_POST["cdbantrf"])) ? $_POST["cdbantrf"] : 0;    
	$cdagetrf = (isset($_POST["cdagetrf"])) ? $_POST["cdagetrf"] : 0;    
	$nrdigtrf = (isset($_POST["nrdigtrf"])) ? $_POST["nrdigtrf"] : 0;  
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
	$nmtitular = (isset($_POST["nmtitular"])) ? $_POST["nmtitular"] : '';
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$nrctatrf = (isset($_POST["nrctatrf"])) ? $_POST["nrctatrf"] : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}					
	
	validaDados();
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= '      <nrdconta>'.$nrdconta.'</nrdconta>';		
	$xml .= '      <nrconta_dest>'.$nrctatrf.'</nrconta_dest>';		
	$xml .= '      <cdbanco_dest>'.$cdbantrf.'</cdbanco_dest>';		
	$xml .= '      <cdagenci_dest>'.$cdagetrf.'</cdagenci_dest>';		
	$xml .= '      <nrdigito_dest>'.$nrdigtrf.'</nrdigito_dest>';		
	$xml .= '      <nrcpfcgc_dest>'.$nrcpfcgc.'</nrcpfcgc_dest>';		
	$xml .= '      <nmtitular_dest>'.$nmtitular.'</nmtitular_dest>';		
	$xml .= "   </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "CADA0003", "MANTER_CONTA_DESTINO_TED_CAP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjResult = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjResult->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjResult->roottag->tags[0]->tags[0]->tags[4]->cdata;

		$nmdcampo = $xmlObjResult->roottag->tags[0]->attributes["NMDCAMPO"];

        if(empty ($nmdcampo)){
            $nmdcampo = "nmtitular";
        }
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','focaCampoErro(\''.$nmdcampo.'\',\'frmDados\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
							
	}	
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso!','Alerta - Aimaro','fechaRotina($(\'#divRotina\'));',false);
	
	function validaDados(){
		
		//Titular
        if (  $GLOBALS["nmtitular"] == '' ){
            exibirErro('error','Nome do titular inv&aacute;lido.','Alerta - Aimaro','$(\'#nmtitular\',\'#frmDados\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//CPF/CNPJ
        if (  $GLOBALS["nrcpfcgc"] == 0 ){
            exibirErro('error','CPF/CNPJ inv&aacute;lido.','Alerta - Aimaro','$(\'#nrcpfcgc\',\'#frmDados\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
				
		//Código do banco
        if ( $GLOBALS["cdbantrf"] == 0){
            exibirErro('error','Banco inv&aacute;lido.','Alerta - Aimaro','$(\'#cdbantrf\',\'#frmDados\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Código da agência
        if (  $GLOBALS["cdagetrf"] == 0){
            exibirErro('error','Ag&ecirc;ncia inv&aacute;lida.','Alerta - Aimaro','$(\'#cdagetrf\',\'#frmDados\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Número da conta destino
        if ( $GLOBALS["nrctatrf"] == 0){
            exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','$(\'#nrctatrf\',\'#frmDados\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Dígito da conta
        if (  $GLOBALS["cdbantrf"] != '85' && $GLOBALS["nrdigtrf"] == 0 ){
            exibirErro('error','D&iacute;gito inv&aacute;lido.','Alerta - Aimaro','$(\'#nrdigtrf\',\'#frmDados\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Número da conta origem
        if ( $GLOBALS["nrdconta"] == 0){
            exibirErro('error','Conta origem inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesDados\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }		
	}
	
?>