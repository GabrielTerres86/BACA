<?php

	/*****************************************************************************************************
	  Fonte: solicita_consulta_nat_ocp.php                                               
	  Autor: Adriano                                                  
	  Data : Fevereiro/2017                       						Última Alteração: 
	                                                                   
	  Objetivo  : Solicita consulta para natureza de ocupação.
	                                                                 
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
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nmrotina = $glbvars["nmrotina"];
	$glbvars["nmrotina"] = "OCUPACOES"; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cdsubrot)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdnatocp = (isset($_POST["cdnatocp"])) ? $_POST["cdnatocp"] : 0;
				
	validaDados();
	
	$xmlSolicitaConsulta  = "";
	$xmlSolicitaConsulta .= "<Root>";
	$xmlSolicitaConsulta .= "   <Dados>";
	$xmlSolicitaConsulta .= "	   <cdnatocp>".$cdnatocp."</cdnatocp>";	
	$xmlSolicitaConsulta .= "	   <cdsubrot>".$cdsubrot."</cdsubrot>";	
	$xmlSolicitaConsulta .= "   </Dados>";
	$xmlSolicitaConsulta .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaConsulta, "TELA_OCPPEP", "CONSNATOCUPACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$glbvars["nmrotina"] = $nmrotina;
	
	$xmlObjSolicitaConsulta = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaConsulta->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjSolicitaConsulta->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjSolicitaConsulta->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdnatocp";
		}
			
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','controlaVoltar(\'\V2\');',false);		
							
	}   
		
	$registros = $xmlObjSolicitaConsulta->roottag->tags;
	
	if ($operacao == '1'){
		
		echo 'controlaLayout("4");';
		echo '$("#dsnatocp","#divNaturezaOcupacao").val("'.getByTagName($registros[$i]->tags,'dsnatocp').'");';
		
	}else if($operacao == '2'){
		
		echo '$("#dsnatocp","#divNaturezaOcupacao").val("'.getByTagName($registros[$i]->tags,'dsnatocp').'");';
		
	}
		
	function validaDados(){
				
		//Código da natureza de ocupação
		if ( $GLOBALS["cdnatocp"] == 0  ){ 
			exibirErro('error','C&oacute;digo da natureza n&atilde;o informado!','Alerta - Ayllos','controlaVoltar(\'\V2\');',false);
		}				
			
	}
			 
?>



				


				

