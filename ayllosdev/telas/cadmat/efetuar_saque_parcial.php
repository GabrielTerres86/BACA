<?php

	/**************************************************************************************
	  Fonte: efetuar_saque_parcial.php                                               
	  Autor: Jonata - RKAM                                                  
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
	
	$rowidsaq = (isset($_POST["rowidsaq"])) ? $_POST["rowidsaq"] : 0;
	$nrctaori = (isset($_POST["nrctaori"])) ? $_POST["nrctaori"] : 0;
	$nrctadst = (isset($_POST["nrctadst"])) ? $_POST["nrctadst"] : 0;
	$vldsaque = (isset($_POST["vldsaque"])) ? $_POST["vldsaque"] : 0;
	
	
	validaDados();
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	 <nrctaori>".$nrctaori."</nrctaori>";
	$xml .= "	 <nrctadst>".$nrctadst."</nrctadst>";
	$xml .= "    <vldsaque>".$vldsaque."</vldsaque>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADA0003", "EFETUAR_SAQUE_PARCIAL_COTAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		//Esta sendo utilizado a função utf8_encode devido ao SICREDI nos retornar mensagens com acentuação.
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "vldsaque";
		}
				 
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#frmSaqueParcial\').removeClass(\'campoErro\');$(\'#'.$nmdcampo.'\',\'#frmSaqueParcial\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmSaqueParcial\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
							
	}

	// Atualizar a tabela tb_cotas_saque_controle
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	 <rowid>".$rowidsaq."</rowid>";
	$xml .= "	 <nrdconta>".$nrctaori."</nrdconta>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADMAT", "ATUALIZA_TBCOTAS_SAQUE_CONTROLE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);		
							
	}
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso','Alerta - Ayllos','fechaRotina($(\'#divRotina\'));',false);	
					
	function validaDados(){
		
		//Conta origem
		if ( $GLOBALS["nrctaori"] == 0){ 
			exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmSaqueParcial\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		//Conta destino
		if ( $GLOBALS["nrctadst"] == 0){ 
			exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmSaqueParcial\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		//Valor do saque
		if ( $GLOBALS["vldsaque"] == 0){ 
			exibirErro('error','Valor para saque inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'vldsaque\',\'frmSaqueParcial\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		
	}
	
?>
