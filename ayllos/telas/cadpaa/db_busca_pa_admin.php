<?php 
/*!
 * FONTE        : db_busca_pa_admin.php
 * CRIAÇÃO      : Renato Darosci - Supero
 * DATA CRIAÇÃO : 08/11/2016
 * OBJETIVO     : Rotina para buscar os dados do pa administrativo
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
	
	// Receber parametros	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
	$cdpaadmi = (isset($_POST['cdpaadmi'])) ? $_POST['cdpaadmi'] : '';
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "	<cdcooper>" . $cdcooper . "</cdcooper>";
	$xml .= "	<cdpaadmi>" . $cdpaadmi . "</cdpaadmi>";
	$xml .= "	<cddopcao>" . $cddopcao . "</cddopcao>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_CADPAA", "BUSCA_PA_ADMIN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjeto 	= getObjectXML($xmlResult);	
	
	// Limpar os campos da tela
	echo 'cDspa_admin.val("");';
	echo 'cTprateio.val("");';
	echo 'cFlgativo.val("");';
	echo 'cDSDtinclus.val("");';
	echo 'cDSDsinclus.val("");';
	echo 'cDSDtaltera.val("");';
	echo 'cDSDsaltera.val("");';
	echo 'cDSDtinativ.val("");';
	echo 'cDSDsinativ.val("");';
		
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		$foco = '';
		// Se for consulta
		if ($cddopcao == 'C') {
			$foco = 'cCdpa_admin.focus();';
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$foco,false);
	}

	// Agrupar nós num array
	$tagsXML = $xmlObjeto->roottag->tags;
	
	echo 'cDspa_admin.val("' . $tagsXML[0]->cdata . '");';
	echo 'cTprateio.val("' . $tagsXML[1]->cdata . '");';
	
	// Verifica se está ativo ou não 
	if ($tagsXML[2]->cdata == 1) {
		echo 'cFlgativo.prop( "checked", true );';
	} else {
		echo 'cFlgativo.prop( "checked", false);';
	}
	
	echo 'cDSDtinclus.val("' . $tagsXML[3]->cdata . '");';
	echo 'cDSDsinclus.val("' . $tagsXML[4]->cdata . '");';
	echo 'cDSDtaltera.val("' . $tagsXML[5]->cdata . '");';
	echo 'cDSDsaltera.val("' . $tagsXML[6]->cdata . '");';
	echo 'cDSDtinativ.val("' . $tagsXML[7]->cdata . '");';
	echo 'cDSDsinativ.val("' . $tagsXML[8]->cdata . '");';
	
	// Se for alteração
	if ($cddopcao == 'A') {
		echo 'formataAltera();';
	}
	
	// Se for consulta
	if ($cddopcao == 'C') {
		echo 'cCdpa_admin.focus();';
	}
	
	// Se for replicacao
	if ($cddopcao == 'R') {
		$registros = $tagsXML[9]->tags; // Lista com as cooperativas que não possuem o código cadastrado
		
		include('tab_replicar.php');
		echo 'formataReplicar();';
	}
	
?>
