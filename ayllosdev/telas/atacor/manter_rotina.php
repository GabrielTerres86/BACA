<?php

	/*************************************************************************
	  Fonte: manter_rotina.php                                               
	  Autor: Reginaldo (AMcom)                                                  
	  Data : Fevereiro/2018                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Executar ações da tela de vinculação de acordo com contratos 
	              de empréstimo LC100              
	                                                                 
	  Alterações:                                                     
	***********************************************************************/

	session_start();	
	
	// Includes para controle da session, variрveis globais de controle, e biblioteca de funушes	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	// Verifica se tela foi chamada pelo mжtodo POST
	isPostMethod();	

	$nrctremp 	 = $_POST["nrctremp"]; 
	$nracordo 	 = $_POST["nracordo"]; 
	$operacao 	 = $_POST["operacao"]; 
	$msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], 'C');

	if (!empty($msgError)) {		
		exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
	}

	if ($operacao == 'ATUALIZA_CONTRATO') {
		$indpagar = $_POST['indpagar'];

		if (empty($nracordo)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";			
		$xml .= "    <nracordo>".$nracordo."</nracordo>";
		$xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "    <indpagar>".$indpagar."</indpagar>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_ATACOR", "ATUALIZA_CONTRATO_ACORDO", 
								$glbvars["cdcooper"], 
								$glbvars["cdagenci"], 
								$glbvars["nrdcaixa"], 
								$glbvars["idorigem"], 
								$glbvars["cdoperad"], 
								"</Root>");

		$xmlObject = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		}
	}
	elseif ($operacao == 'EXCLUIR_CONTRATO') {
		if (empty($nracordo) || empty($nrctremp)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";			
		$xml .= "    <nracordo>".$nracordo."</nracordo>";
		$xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_ATACOR", "EXCLUI_CONTRATO_ACORDO", 
								$glbvars["cdcooper"], 
								$glbvars["cdagenci"], 
								$glbvars["nrdcaixa"], 
								$glbvars["idorigem"], 
								$glbvars["cdoperad"], 
								"</Root>");

		$xmlObject = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		}

		exibirErro('inform', 'Contrato removido.', 'Alerta - Ayllos','removeContratoTabela();',false);
	}
	elseif ($operacao == 'VALIDAR_CONTRATO') {
		if (empty($nracordo) || empty($nrctremp)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";			
		$xml .= "    <nracordo>".$nracordo."</nracordo>";
		$xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_ATACOR", "VALIDA_CONTRATO_LC100", 
								$glbvars["cdcooper"], 
								$glbvars["cdagenci"], 
								$glbvars["nrdcaixa"], 
								$glbvars["idorigem"], 
								$glbvars["cdoperad"], 
								"</Root>");

		$xmlObject = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		}

		if (getByTagName($xmlObject->roottag->tags[0]->tags, 'valido') == 'N') {
			exibirErro('error','Contrato inv&aacute;lido.','Alerta - Ayllos',"$('#nrctremp', '#frmincctr').focus();",false);
		}
	}
	elseif($operacao == 'INCLUIR_CONTRATO') {
		if (empty($nracordo) || empty($nrctremp)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";			
		$xml .= "    <nracordo>".$nracordo."</nracordo>";
		$xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_ATACOR", "INCLUI_CONTRATO_ACORDO", 
								$glbvars["cdcooper"], 
								$glbvars["cdagenci"], 
								$glbvars["nrdcaixa"], 
								$glbvars["idorigem"], 
								$glbvars["cdoperad"], 
								"</Root>");

		$xmlObject = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		}

		if (getByTagName($xmlObject->roottag->tags[0]->tags, 'valido') == 'N') {
			exibirErro('error','Contrato inv&aacute;lido.','Alerta - Ayllos',"$('#nrctremp', '#frmincctr').focus();",false);
		}
		elseif (getByTagName($xmlObject->roottag->tags[0]->tags, 'Inserido') == 'S') {
			exibirErro('inform', 'Contrato inclu&iacute;do.', 'Alerta - Ayllos',"fechaRotina($('#divUsoGenerico'),$('#divTela')); addContratoTabela(" . $nrctremp . ");",false);
		}
	}
