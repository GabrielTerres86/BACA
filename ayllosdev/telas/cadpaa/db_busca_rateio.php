<?php 
/*!
 * FONTE        : db_busca_rateio.php
 * CRIAÇÃO      : Renato Darosci - Supero
 * DATA CRIAÇÃO : 07/11/2016
 * OBJETIVO     : Rotina para buscar os tipos de rateio a serem listados
 * ALTERAÇÕES   : 
 */

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");	

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_CADPAA", "BUSCA_RATEIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjeto 	= getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}

	// Agrupar nós num array
	$tagsCoop = $xmlObjeto->roottag->tags;
	$tamArray = count($tagsCoop);

	echo 'cTprateio.empty();';
	
	// Percorrer cada nó do xml - cada um é uma cooperativa retonada
	for ($i = 0;$i < $tamArray; $i++) {	
		echo 'cTprateio.append(\'<option value="'.$tagsCoop[$i]->tags[0]->cdata.'">'.$tagsCoop[$i]->tags[1]->cdata.'</option>\');';		
	}
	
?>
