<?php

	/*************************************************************************
	  Fonte: manter_rotina.php                                               
	  Autor: Reginaldo Rubens da Silva(AMcom)                                                  
	  Data : Março/2018                      Última Alteração: 		   
	                                                                   
	  Objetivo  : Executar ações da tela de parametrização do DEBITADOR 
                  ÚNICO (Cadastro de Horários)
	                                                                 
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

    $idhora_processamento = $_POST['idhora_processamento'];
    $dhprocessamento = $_POST['dhprocessamento'];
    $operacao = $_POST['operacao'];

	/*$msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], 'C');

	if (!empty($msgError)) {		
		exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
	}*/

	if ($operacao == 'INCLUIR_HORARIO') {
		if (empty($dhprocessamento)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";			
		$xml .= "    <dhprocessamento>" . $dhprocessamento . "</dhprocessamento>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_HR_INCLUIR", 
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

		$mensagemRetorno = getByTagName($xmlObject->roottag->tags[0]->tags, 'mensagem');

        exibirErro('inform', utf8_encode($mensagemRetorno), 'Alerta - Ayllos','estadoInicial();', false);
	}
	elseif ($operacao == 'ALTERAR_HORARIO') {
		if (empty($dhprocessamento) || empty($idhora_processamento)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";
        $xml .= "    <idhora_processamento>" . $idhora_processamento . "</idhora_processamento>";			
		$xml .= "    <dhprocessamento>" . $dhprocessamento . "</dhprocessamento>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_HR_ALTERAR", 
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

        exibirErro('inform', 'Hor&aacute;rio alterado.', 'Alerta - Ayllos','trocaBotao(\'\'); carregaDetalhamentoHorarios();', false);
	}
    elseif ($operacao == 'EXCLUIR_HORARIO') {
		if (empty($idhora_processamento)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";
        $xml .= "    <idhora_processamento>" . $idhora_processamento . "</idhora_processamento>";			
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_HR_EXCLUIR", 
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

        exibirErro('inform', 'Hor&aacute;rio exclu&iacute;do.', 'Alerta - Ayllos','carregaDetalhamentoHorarios();', false);
	}
	