<?php
	//*********************************************************************************************//
	//*** Fonte: buscar_garantias.php                                                           ***//
	//*** Autor: Cristian Filipe                                                                ***//
	//*** Data : setembro/2013                                                                    ***//
	//*** Objetivo  : Pesquisa das garantias do seguro				                              ***//
	//***                                                                                       ***//	 
	//*********************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	
	// Verifica Permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}	
	
	
	$cdsegura = $_POST['cdsegura'];
	$tpseguro = $_POST['tpseguro'];
	$tpplaseg = $_POST['tpplaseg'];
	$nrseqinc = $_POST['nrseqinc'];
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0033.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>buscar_garantias</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPesquisa .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPesquisa .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetPesquisa .= "        <nrdconta>".$glbvars["nrdconta"]."</nrdconta>";
	$xmlSetPesquisa .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetPesquisa .= "        <idseqttl>".$glbvars["idseqttl"]."</idseqttl>";
	$xmlSetPesquisa .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetPesquisa .= "        <flgerlog>".$glbvars["flgerlog"]."</flgerlog>";
	$xmlSetPesquisa .= "        <cdsegura>".$cdsegura."</cdsegura>";
	$xmlSetPesquisa .= "        <tpseguro>".$tpseguro."</tpseguro>";
	$xmlSetPesquisa .= "        <tpplaseg>".$tpplaseg."</tpplaseg>";
	$xmlSetPesquisa .= "        <nrseqinc>".$nrseqinc."</nrseqinc>";
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa);
	
	$xmlObjPesquisa = getObjectXML($xmlResult);
	
	
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
		$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$erros = exibirErro('error',$msgErro,'Alerta - Ayllos',"1",false);
	} 	

	$registros = $xmlObjPesquisa->roottag->tags[0]->tags;
	include('tab_garantia.php');
?>	