<?php
/*!
 * FONTE        : consulta_agencia_selecionada.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para buscar informações da agencia selecionada
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

	$cdagenci = (isset($_POST["cdagenci"])) ? $_POST["cdagenci"] : 0;

	// Monta o xml de requisição		
	$xml = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "     <cdagenci>".$cdagenci."</cdagenci>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "BUSCA_INFO_AGENCIA_GRP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjRegistros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','controlaVoltar(\'1\')',false);		
								
	} 
		
	$registros = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags;

	//include table
	include('tabela_agencia_selecionada.php');
?> 