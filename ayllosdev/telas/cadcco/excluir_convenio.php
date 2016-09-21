<?php 
	/*******************************************************************************
	 Fonte: excluir_convenio.php                                                 
	 Autor: Jonathan - RKAM                                                    
	 Data : Fevereiro/2016                   �ltima Altera��o:  
	                                                                  
	 Objetivo  : Efetua a exclus�o do convenio de cobran�a.                                  
	                                                                  
	 Altera��es: 
							  
	********************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
		
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Guardo os par�metos do POST em vari�veis	
	$nrconven = (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0;
	
	validaDados();

	// Monta o xml de requisi��o
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrconven>".$nrconven."</nrconven>";
	$xml 	   .= "     <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "     <dsdepart>".$glbvars["dsdepart"]."</dsdepart>";
	$xml 	   .= "     <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";		
		
	$xmlResult = mensageria($xml, "TELA_CADCCO", "EXCLUSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjExclui = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjExclui->roottag->tags[0]->name) == "ERRO") {
	
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);		
					
	}else{
		exibirErro('inform','Conv&ecirc;nio excluido com sucesso!','Alerta - Ayllos','estadoInicial();',false);
	}


	function validaDados(){

		//Convenio
		if ( $GLOBALS["nrconven"] == 0){ 
			exibirErro('error','Conv&ecirc;nio inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesCadcco\').focus();',false);
		}
	
	}
					
?>
