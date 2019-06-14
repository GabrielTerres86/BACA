<?php

	/*************************************************************************
	  Fonte: carrega_dados.php                                               
	  Autor: Rogério Giacomini                                                 
	  Data : setembro/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Carregar os dados da tela GARSEG.
	                                                                 
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
	$cdsegura = $_POST["cdsegura"];
	$nmsegura = $_POST["nmsegura"];
	$tpseguro = $_POST["tpseguro"];
	$tpplaseg = $_POST["tpplaseg"];
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0033.p</Bo>";
	$xmlCarregaDados .= "    <Proc>buscar_garantias</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlCarregaDados .= "	<nrdconta>".$glbvars["nrdconta"]."</nrdconta>";
    $xmlCarregaDados .= "	<idseqttl>".$idseqttl."</idseqttl>";	
	$xmlCarregaDados .= "	<idorigem>1</idorigem>";
	$xmlCarregaDados .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCarregaDados .= "	<flgerlog>FALSE</flgerlog>";
	$xmlCarregaDados .= "	<cdsegura>".$cdsegura."</cdsegura>";
	$xmlCarregaDados .= "	<tpseguro>".$tpseguro."</tpseguro>";
	$xmlCarregaDados .= "	<tpplaseg>".$tpplaseg."</tpplaseg>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	$flagErro  = strtoupper($xmlObjCarregaDados->roottag->tags[0]->name);
	
	$registros = $xmlObjCarregaDados->roottag->tags[0]->tags;

	include "tabela_garseg.php";
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		$flagErro  = $xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[5]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Ayllos','formataTabela()');
	}
	
?>
<script type="text/javascript">
	formataTabela();
	$('#cdsegura','#frmGarseg').val('<? echo $cdsegura ?>');
	$('#nmsegura','#frmGarseg').val('<? echo $nmsegura ?>');
	$('#tpseguro','#frmGarseg').val('<? echo $tpseguro ?>');
	$('#tpplaseg','#frmGarseg').val('<? echo $tpplaseg ?>');
	habilita = true;
</script>