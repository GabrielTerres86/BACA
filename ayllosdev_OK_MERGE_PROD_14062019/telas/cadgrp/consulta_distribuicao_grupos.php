<?php
/*!
 * FONTE        : consulta_distribuicao_grupos.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para buscas de previas de distribuição Automatica de grupos
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

	$cdagenci = 0;

	// Monta o xml de requisição		
	$xml = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "     <cdagenci>".$cdagenci."</cdagenci>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "BUSCA_AGENCIAS_GRP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjRegistros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','controlaVoltar(\'1\')',false);		
								
	} 
		
	$agencias = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags;

	//include table
	include('tabela_distribuicao_grupos.php');
?> 