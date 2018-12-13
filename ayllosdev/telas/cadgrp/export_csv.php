<?php
/*!
 * FONTE        : export_csv.php
 * CRIAÇÃO      : Andrey Formigari (Mouts)
 * DATA CRIAÇÃO : Outubro/2018 
 * OBJETIVO     : Rotina exportar os dados da consulta
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

	$cdagenci 	= (isset($_POST["cdagenci"])) 	? $_POST["cdagenci"] : 0;
	$nrdgrupo 	= (isset($_POST["nrdgrupo"])) 	? $_POST["nrdgrupo"] : 0;
	$nriniseq 	= 1;
	$nrregist 	= (isset($_POST["nrregist"])) 	? $_POST["nrregist"] : 0;

	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <cdagenci>".$cdagenci."</cdagenci>";
	$xml 	   .= "     <nrdgrupo>".$nrdgrupo."</nrdgrupo>";
	$xml 	   .= "     <nrregist>".$nrregist."</nrregist>";
	$xml 	   .= "     <nriniseq>".$nriniseq."</nriniseq>"; //Numero inicial sequencia
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";

	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "CONSULTA_DET_GRP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjRegistros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistros->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);		
	}
		
	$registros = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags;
	//$qtregist = $xmlObjRegistros->roottag->tags[0]->attributes['QTREGIST'];
	
	$csv = "Cargo;Conta;CPF/CNPJ;Nome Completo;|";
	
	foreach( $registros as $result ) {	
		$csv .= getByTagName($result->tags,'dsfuncao') . ";";
		$csv .= getByTagName($result->tags,'nrdconta') . ";";
		$csv .= getByTagName($result->tags,'nrcpfcgc') . ";";
		$csv .= getByTagName($result->tags,'nmprimtl') . ";";
		$csv .= "|";
	}
	exit($csv);
 ?>