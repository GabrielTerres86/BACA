<?php
	/*!
	 * FONTE        : cancelar_agendamento.php
	 * CRIAÇÃO      : Adriano Marchi
	 * DATA CRIAÇÃO : 24/05/2016
	 * OBJETIVO     : Rotina para buscar cancelar agendamentos
	 * --------------
	 * ALTERAÇÕES   : 15/07/2016 Ajustes de acentuacao (Carlos)
	 * -------------- 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);	
	}

	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
	$dtmvtolt = isset($_POST["dtmvtolt"]) ? $_POST["dtmvtolt"] : "";
	$nrdocmto = isset($_POST["nrdocmto"]) ? $_POST["nrdocmto"] : 0;
	
	validaDados();
	
	$xmlCancelar  = "";
	$xmlCancelar .= "<Root>";
	$xmlCancelar .= " <Cabecalho>";
	$xmlCancelar .= "    <Bo>b1wgen0016.p</Bo>";
	$xmlCancelar .= "    <Proc>cancelar_agendamento</Proc>";
	$xmlCancelar .= " </Cabecalho>";
	$xmlCancelar .= " <Dados>";
	$xmlCancelar .= "	 <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCancelar .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCancelar .= "	 <idseqttl>1</idseqttl>";
	$xmlCancelar .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlCancelar .= "	 <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCancelar .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlCancelar .= "    <nrdocmto>".$nrdocmto."</nrdocmto>";
	$xmlCancelar .= "    <dtmvtage>".$dtmvtolt."</dtmvtage>";
	$xmlCancelar .= "    <nrcpfope>0</nrcpfope>";
	$xmlCancelar .= " </Dados>";
	$xmlCancelar .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCancelar);
		
	$xmlObjCancelar = getObjectXML($xmlResult);
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCancelar->roottag->tags[0]->name) == "ERRO") {
				
		$msgErro = $xmlObjCancelar->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','focaCampoErro(\'btVoltar\',\'divBotoes\');',false);		
				
	} 
	
	exibirErro('inform','Agendamento cancelado com sucesso.','Alerta - Ayllos','controlaVoltar();',false);		
		
	function validaDados(){
		
		IF($GLOBALS["nrdconta"] == 0 ){ 
			exibirErro('error','Conta inválida.','Alerta - Ayllos','focaCampoErro(\'btVoltar\',\'divBotoes\');',false);
		}
			
		IF($GLOBALS["dtmvtolt"] == "" ){ 
			exibirErro('error','Data do agendamento inválida.','Alerta - Ayllos','focaCampoErro(\'btVoltar\',\'divBotoes\');',false);
		}

		IF($GLOBALS["nrdocmto"] == 0 ){ 
			exibirErro('error','Número do documento inválido.','Alerta - Ayllos','focaCampoErro(\'btVoltar\',\'divBotoes\');',false);
		}
				
	}	
		
?>
