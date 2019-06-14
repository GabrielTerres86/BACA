<?php
	/*************************************************************************
	  Fonte: alterar_garantia.php                                               
	  Autor: Rogério Giacomini de Almeida                                                  
	  Data : setembro/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Alterar os dados de uma garantia.
	                                                                 
	  Alterações: 										   			  
	                                                                  
	***********************************************************************/
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Dados necessários
	
	$nrseqinc = $_POST["nrseqinc"];
	$cdsegura = $_POST["cdsegura"];
	$tpseguro = $_POST["tpseguro"];
	$tpplaseg = $_POST["tpplaseg"];
	$tpplaseg = $_POST["tpplaseg"];
	$dsgarant = $_POST["dsgarant"];
	$vlgarant = $_POST["vlgarant"];
	$dsfranqu = $_POST["dsfranqu"];
	$nomeform = (isset($_POST['nomeform'])) ? $_POST['nomeform'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Cabecalho>";
	$xml .= "    <Bo>b1wgen0033.p</Bo>";
	$xml .= "    <Proc>alterar_garantias</Proc>";
	$xml .= " </Cabecalho>";
	$xml .= " <Dados>";
	$xml .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "	<flgerlog>FALSE</flgerlog>";
	$xml .= "	<nrseqinc>".$nrseqinc."</nrseqinc>";
	$xml .= "	<cdsegura>".$cdsegura."</cdsegura>";
	$xml .= "	<tpseguro>".$tpseguro."</tpseguro>";
	$xml .= "	<tpplaseg>".$tpplaseg."</tpplaseg>";
	$xml .= "	<dsgarant>".$dsgarant."</dsgarant>";
	$xml .= "	<vlgarant>".$vlgarant."</vlgarant>";
	$xml .= "	<dsfranqu>".$dsfranqu."</dsfranqu>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'))', false);
	}
	
	echo 'escondeRotina();carrega_dados();';
?>