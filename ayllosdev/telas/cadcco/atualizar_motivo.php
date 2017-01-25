<?php 
	/*******************************************************************************
	 Fonte: atualizar_motivo.php                                                 
	 Autor: Jonathan - RKAM                                                    
	 Data : Fevereir/2016                   Última Alteração:  
	                                                                  
	 Objetivo  : Efetua a atualizacao das tarifas e histórico do motivo                              
	                                                                  
	 Alterações: 30/11/2016 - P341-Automatização BACENJUD - Alterado para passar como parametro o  
                              código do departamento ao invés da descrição (Renato Darosci - Supero)
							  
	********************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
		
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Guardo os parâmetos do POST em variáveis	
	$nrconven = (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0;
	$motivo   = isset($_POST["motivo"]) ? $_POST["motivo"] : '';	
	
	validaDados();

	$vlmotivo = '';

	foreach($motivo as $dados){

		$valores = '';

		foreach($dados as $valor){

			if($valores == ''){

				$valores = $valor;
				
			}else{
				
				$valores = $valores.'|'.$valor;
				
			}
		
		}

		if($vltarifa == ''){

			$vlmotivo = $valores;

		}else{

			$vlmotivo = $vlmotivo.'#'.$valores;

		}

	}

	// Monta o xml de requisição
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml 	   .= "     <nrconven>".$nrconven."</nrconven>";		
	$xml 	   .= "     <cddepart>".$glbvars["cddepart"]."</cddepart>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "     <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml 	   .= "     <vlmotivo>".$vlmotivo."</vlmotivo>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";		
				   
	$xmlResult = mensageria($xml, "TELA_CADCCO", "ATUALIZAMOTIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjMotivo = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjMotivo->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjMotivo->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesMotivos\').focus();',false);		
					
	}else{
		exibirErro('inform','Motivo atualizado com sucesso!','Alerta - Ayllos','fechaRotina($(\'#divRotina\'));',false);
	}


	function validaDados(){

		//Convenio
		if ( $GLOBALS["nrconven"] == 0){ 
			exibirErro('error','Conv&ecirc;nio inv&aacute;lido.','Alerta - Ayllos','fechaRotina($(\'#divRotina\'));return false;',false);
		}
	
	}
					
?>
