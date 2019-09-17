<?php
	//*********************************************************************************************//
	//*** Fonte: buscar_seguradora.php                                                       ***//
	//*** Autor: Cristian Filipe                                                                ***//
	//*** Data : setembro/2013                                                                    ***//
	//*** Objetivo  : Efetuar pesquisa de seguradoras					                        ***//
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
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> "") {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$tipoBusca = $_POST['tipoBusca'];
	$cdsegura = $_POST['cdsegura'];
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0033.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>Buscar_seguradora</Proc>";
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
	
	if($tipoBusca == "pesquisa"){
		foreach($registros as $values)
		{
			if($cdsegura == getByTagName($values->tags, 'cdsegura'))
			{
				$nmsegura = getByTagName($values->tags, 'nmsegura');
				echo "$('#nmresseg', '#frmInfSeguradora').val('$nmsegura')";
				die;
			}
		}
		if($nmsegura == "") exibirErro('error','556 - Seguradora nao cadastrada','Alerta - Ayllos',"focaCampoErro('cdsegura', 'frmInfSeguradora');",false);
	}
	else
	include("tab_seguradora.php");
?>