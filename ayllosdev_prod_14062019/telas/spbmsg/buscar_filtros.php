<?php 
/*!
 * FONTE        : buscar_fitros.php
 * CRIAÇÃO      : Mateus Zimmermann - Mouts
 * DATA CRIAÇÃO : 18/08/2018
 * OBJETIVO     : Rotina para busca as cooperativas e fases a serem listadas
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
	$xmlResult = mensageria($xml, "TELA_SPBMSG", "SPBMSG_BUSCA_FILTROS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjeto 	= simplexml_load_string($xmlResult);	
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	}

	$cooperativas = $xmlObjeto->cooperativas->item;
	$fases = $xmlObjeto->fases->item;

	echo '$(\'#cdfase\',\'#frmFiltro\').empty();';
	echo '$(\'#cdcooper\',\'#frmFiltro\').empty();';

	echo '$(\'#cdfase\',\'#frmFiltro\').append(\'<option value=""></option>\');';
	echo '$(\'#cdcooper\',\'#frmFiltro\').append(\'<option value=""></option>\');';

	// Percorrer cada nó do xml - cada um é uma fase retornada
	foreach( $fases as $fase ) {
		echo '$(\'#cdfase\',\'#frmFiltro\').append(\'<option value="'.$fase->codigo.'">'.$fase->nome.'</option>\');';
	}
	
	// Percorrer cada nó do xml - cada um é uma cooperativa retornada
	foreach( $cooperativas as $cooperativa ) {
		echo '$(\'#cdcooper\',\'#frmFiltro\').append(\'<option value="'.$cooperativa->codigo.'">'.$cooperativa->nome.'</option>\');';
	}
	
?>
