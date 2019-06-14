<?php
	/*************************************************************************
	  Fonte: desfazer_cancelamento_seguro.php                                               
	  Autor: Rogério Giacomini de Almeida                                                  
	  Data : 22/09/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo : Cancelar um seguro (Tela ATENDA / SEGURO).
	                                                                 
	  Alterações: 										   			  
	                                                                  
	***********************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Dados necessários
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$tpseguro = $_POST["tpseguro"];
	$nrctrseg = $_POST["nrctrseg"];
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Cabecalho>";
	$xml .= "    <Bo>b1wgen0033.p</Bo>";
	$xml .= "    <Proc>desfaz_canc_seguro</Proc>";
	$xml .= " </Cabecalho>";
	$xml .= " <Dados>";
	$xml .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "	<idorigem>".$glbvars['idorigem']."</idorigem>";
	$xml .= "	<flgerlog>FALSE</flgerlog>";
	$xml .= "	<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "	<tpseguro>".$tpseguro."</tpseguro>";
	$xml .= "	<nrctrseg>".$nrctrseg."</nrctrseg>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Aimaro','');
	}
?>