<?php

	/*************************************************************************
	  Fonte: manter_rotina.php                                               
	  Autor: Reginaldo Rubens da Silva (AMcom)                                                  
	  Data : Março/2018                      Última Alteração: 		   
	                                                                   
	  Objetivo  : Executar ações da tela de parametrização do DEBITADOR 
                  ÚNICO (Cadastro de Prioridades) 
	                                                                 
	  Alterações:                                                     
	***********************************************************************/

	session_start();	
	
	// Includes para controle da session, variрveis globais de controle, e biblioteca de funушes	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");	
	require_once("../../../includes/controla_secao.php");
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	// Verifica se tela foi chamada pelo mжtodo POST
	isPostMethod();	

    $cdprocesso = $_POST['cdprocesso'];
    $nrprioridade = $_POST['nrprioridade'];
    $horarios = $_POST['horarios'];
    $operacao = $_POST['operacao'];

	if ($operacao == 'REDEFINIR_PRIORIDADE') {
		if (empty($cdprocesso) || empty($nrprioridade)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";			
		$xml .= "    <nrprioridade>" . $nrprioridade . "</nrprioridade>";
        $xml .= "    <cdprocesso>" . $cdprocesso . "</cdprocesso>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_PR_REDEF_PRIORIDADE", 
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
			exibirErro('error', utf8_encode($msgErro), 'Alerta - Ayllos', '', false);
		}

        echo 'carregarPrioridadesProcessos(' . $nrprioridade . ');';
	}
	elseif ($operacao == 'ATIVAR_PROCESSO') {
		if (empty($cdprocesso) || empty($horarios)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";
        $xml .= "    <cdprocesso>" . $cdprocesso . "</cdprocesso>";			
		$xml .= "    <horarios>" . $horarios . "</horarios>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_PR_ATIVAR", 
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
			exibirErro('error', utf8_encode($msgErro), 'Alerta - Ayllos', '', false);
		}

        exibirErro('inform', 'Programa ativado.', 'Alerta - Ayllos','trocaBotao(\'\'); carregarPrioridadesProcessos();', false);
	}
    elseif ($operacao == 'DESATIVAR_PROCESSO') {
		if (empty($cdprocesso)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";
        $xml .= "    <cdprocesso>" . $cdprocesso . "</cdprocesso>";			
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_PR_DESATIVAR", 
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
			exibirErro('error', utf8_encode($msgErro), 'Alerta - Ayllos', '', false);
		}

        exibirErro('inform', 'Programa desativado.', 'Alerta - Ayllos','trocaBotao(\'\'); carregarPrioridadesProcessos();', false);
	}
    elseif ($operacao == 'EXCLUIR_HORARIO_PROC') {
		if (empty($cdprocesso) || empty($horarios)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";
        $xml .= "    <cdprocesso>" . $cdprocesso . "</cdprocesso>";			
        $xml .= "    <idhora_processamento>" . $horarios . "</idhora_processamento>";	
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_PR_EXC_HORARIO", 
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
			exibirErro('error', utf8_encode($msgErro), 'Alerta - Ayllos', '', false);
		}

		$prioridade = getByTagName($xmlObject->roottag->tags[0]->tags, 'nrprioridade');

        exibirErro('inform', 'Hor&aacute;rio de processamento exclu&iacute;do.', 'Alerta - Ayllos','carregarPrioridadesProcessos(' . $prioridade . ');', false);
	}
    elseif ($operacao == 'INCLUIR_HORARIO_PROC') {
		if (empty($cdprocesso) || empty($horarios)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";
        $xml .= "    <cdprocesso>" . $cdprocesso . "</cdprocesso>";			
        $xml .= "    <idhora_processamento>" . $horarios . "</idhora_processamento>";	
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_PR_INC_HORARIO", 
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
			exibirErro('error', utf8_encode($msgErro), 'Alerta - Ayllos', '', false);
		}

		$prioridade = getByTagName($xmlObject->roottag->tags[0]->tags, 'nrprioridade');

        exibirErro('inform', 'Hor&aacute;rio adicionado.', 'Alerta - Ayllos',"fechaRotina($('#divUsoGenerico'),$('#divTela')); $('#divUsoGenerico').empty(); carregarPrioridadesProcessos(" . $prioridade . ");",false);
	}
    