<?php

	/**************************************************************************************
	  Fonte: manter_rotina.php                                               
	  Autor: Jonata - RKAM                                                  
	  Data : Junho/2017                       			Última Alteração:  
	                                                                   
	  Objetivo  : Gerencia a consulta/inclusão/alteração de parâmetros da tela MINCAP
	                                                                 
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
	$cdcopsel = (isset($_POST["cdcopsel"])) ? $_POST["cdcopsel"] : 0;    
	$tppessoa = (isset($_POST["tppessoa"])) ? $_POST["tppessoa"] : 0;    
	$cdtipcta = (isset($_POST["cdtipcta"])) ? $_POST["cdtipcta"] : 0;  
	$vlminimo = (isset($_POST["vlminimo"])) ? $_POST["vlminimo"] : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}					
	
	validaDados();
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "	   <cdcopsel>".$cdcopsel."</cdcopsel>";
	$xml .= "	   <tppessoa>".$tppessoa."</tppessoa>";
	$xml .= "	   <cdtipcta>".$cdtipcta."</cdtipcta>";
	$xml .= "	   <vlminimo>".$vlminimo."</vlminimo>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "CADA0003", "VALORMINCAP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjResult = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjResult->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjResult->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#vlminimo\',\'#frmValorMinimo\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#vlminimo\',\'#frmValorMinimo\').focus();',false);		
							
	}	
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso!','Alerta - Ayllos','fechaRotina($(\'#divRotina\'));buscaTiposConta(\'1\',\'30\');',false);
	
	function validaDados(){
		
		//Código da cooperativa
        if ( $GLOBALS["cdcopsel"] == '0'){
            exibirErro('error','Cooperativa inv&aacute;lida.','Alerta - Ayllos','$(\'#vlminimo\',\'#frmValorMinimo\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Tipo da pessoa
        if (  $GLOBALS["tppessoa"] != 1 && $GLOBALS["tppessoa"] != 2){
            exibirErro('error','Tipo da pessoa inv&aacute;lido.','Alerta - Ayllos','$(\'#vlminimo\',\'#frmValorMinimo\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
		//Tipo da conta
        if (  $GLOBALS["cdtipcta"] == 0 ){
            exibirErro('error','Tipo da conta inv&aacute;lido.','Alerta - Ayllos','$(\'#vlminimo\',\'#frmValorMinimo\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
        }
		
				
	}
	
?>