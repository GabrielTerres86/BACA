<?php
/*!
 * FONTE        : consulta_periodo_edital_assembleias.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para buscas os períodos de edital de assembléias
 * --------------
 * ALTERAÇÕES   : 
 */
?> 

<?php	
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

	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 0;
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 0;
	
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrregist>".$nrregist."</nrregist>";
	$xml 	   .= "     <nriniseq>".$nriniseq."</nriniseq>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "BUSCA_PERIODO_EDT_ASSEM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjRegistros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);		
					
	} 
		
	$registros	= $xmlObjRegistros->roottag->tags[0]->tags[0]->tags;

	$qtregist = $xmlObjRegistros->roottag->tags[0]->attributes['QTREGIST'];
	
	include("tabela_periodo_edital_assembleias.php");


 ?>
