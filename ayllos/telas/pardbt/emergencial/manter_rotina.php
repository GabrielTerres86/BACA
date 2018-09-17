<?php

	/*************************************************************************
	  Fonte: manter_rotina.php                                               
	  Autor: Reginaldo Rubens da Silva (AMcom)                                                  
	  Data : Março/2018                      Última Alteração: 		   
	                                                                   
	  Objetivo  : Executar ações da tela de parametrização do DEBITADOR 
                  ÚNICO (Execução Emergencial de Processos)
	                                                                 
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

	$cddopcao = $_POST['cddopcao'];

    $msgError = validaPermissao($glbvars["nmdatela"],$glbvars['nmrotina'],$cddopcao, false);

    if ($msgError != '') {
		exibirErro('error', utf8ToHtml('Acesso não permitido.'), 'Alerta - Ayllos', 'estadoInicial()', false);
	}

    $processos = $_POST['processos'];
    $operacao = $_POST['operacao'];
	$cdcooper = $_POST['cdcooper'];
	$tipoExecucao = $_POST['tipoExecucao'];

	if (empty($cdcooper)) {
		exibirErro('error', 'Cooperativa não informada.', 'Alerta - Ayllos', 'unblockBackground(); $(\'#cdcooper\', \'#frmDet\').focus();', false);
	}

	if ($operacao == 'EXECUTAR_EMERGENCIAL') {
		if (empty($tipoExecucao)) {
			exibirErro('error', 'Tipo de execução não selecionado.', 'Alerta - Ayllos', 'unblockBackground(); $(\'#tipoExecucao\', \'#frmDet\').focus();', false);
		}

		if (empty($processos)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";			
		$xml .= "    <processos>" . $processos . "</processos>";
		$xml .= "    <cdcooper>" . $cdcooper . "</cdcooper>";
		$xml .= "    <tipoexecucao>" . $tipoExecucao . "</tipoexecucao>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_EM_EXECUTAR", 
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

        exibirErro('inform', 'Execu&ccedil;&atilde;o emergencial processada.', 'Alerta - Ayllos','estadoInicial();', false);
	}
	elseif ($operacao == 'VALIDAR_PROCESSO_EM') {
		if (empty($processos) || empty($cdcooper)) {
			exibirErro('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '', false);
		}

		$xml = "<Root>";
		$xml .= "  <Dados>";
        $xml .= "    <cdcooper>" . $cdcooper . "</cdcooper>";			
		$xml .= "    <cdprocesso>" . $processos . "</cdprocesso>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";

		//echo $xml;
		//die();

		$xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_VALIDAR_EX_PROC", 
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
			exibirErro('error', utf8_encode($msgErro), 'Alerta - Ayllos', 'desabilitarCheckProcesso(\'' . $processos . '\')', false);
		}

        echo '';
	}
    
	
