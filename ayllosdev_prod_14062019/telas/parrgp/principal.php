<?php

	/*****************************************************************************************************
	  Fonte: principal.php                                               
	  Autor: Jonata - Mouts                                               
	  Data : Maio/2017                       						Última Alteração:  
	                                                                   
	  Objetivo  : Solicita a busca de parametros para serem apresentadas em tela
	                                                                 
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
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	
	$xmlBuscarParametros  = "";
	$xmlBuscarParametros .= "<Root>";
	$xmlBuscarParametros .= "   <Dados>";
	$xmlBuscarParametros .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlBuscarParametros .= "	   <nrregist>".$nrregist."</nrregist>";
	$xmlBuscarParametros .= "	   <nriniseq>".$nriniseq."</nriniseq>";
	$xmlBuscarParametros .= "   </Dados>";
	$xmlBuscarParametros .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscarParametros, "TELA_PARRGP", "BUSCA_PROVISOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjBuscarParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBuscarParametros->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjBuscarParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjBuscarParametros->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cddopcao";
		}
				 
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#frmCabParrgp\').removeClass(\'campoErro\');unblockBackground(); estadoInicial();',false);		
							
	}   
	
	if($cddopcao != 'I'){	
	
		$registros = $xmlObjBuscarParametros->roottag->tags[0]->tags;
		
		$qtregist = $xmlObjBuscarParametros->roottag->attributes['QTREGIST'];
		
		include('tab_registros.php');
		
		if($qtregist == 0){
			exibirErro('inform','Nenhum registro encontrado.','Alerta - Ayllos','estadoInicial();');
		}
						
	}else{
		
		include('form_detalhes.php');
		
		?>
		
		<script type="text/javascript">
			
			formataDetalhes();
						
		</script>
			
		<?
		
	}
	
			 
?>



				


				

