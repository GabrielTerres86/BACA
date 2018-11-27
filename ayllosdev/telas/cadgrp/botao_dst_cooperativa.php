<?php
/*!
 * FONTE        : botao_dst_cooperativa.php
 * CRIAÇÃO      : Gabriel Marcos (Mouts)
 * DATA CRIAÇÃO : Novembro/2018 
 * OBJETIVO     : Rotina para gerar distribuicao de grupos para a cooperativa
 * --------------
 * ALTERAÇÕES   : 
 */

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição		
	$xml = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "DST_COOPERATIVA_GRP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjRegistros = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);		
								
	}
	
	exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','controlaVoltar(\'7\');', false);
	
/*
	$agencias = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags;

	//include table
	include('tabela_lista_agencias.php');*/
?> 