<?php

	/*************************************************************************
	  Fonte: carrega_dados.php                                               
	  Autor: Henrique                                                  
	  Data : Junho/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Carregar os dados da tela ALTERA.              
	                                                                 
	  Alterações: 										   			  
	  [27/03/2012] Rogérius Militão (DB1) : Novo layout padrão, adiciona $returnError com focu no campo conta;
	                                                                  
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
	
	$returnError = "$('#nrdconta','#frmCabAltera').focus();";
	$nrdconta 	 = $_POST["nrdconta"]; // Opcao Utilizada no carrega_dados
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Altera','',false);
	}

	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0031.p</Bo>";
	$xmlCarregaDados .= "    <Proc>busca-alteracoes</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	 <nrdconta>".$nrdconta."</nrdconta>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Altera',$returnError,false);
	} 
	
	$registros = $xmlObjCarregaDados->roottag->tags[0]->tags;
	
	// A funcao 'attributes' deve ser utilizada com o campo em maiúsculo
	// Informacoes do cooperado
	$nmprimtl = $xmlObjCarregaDados->roottag->tags[0]->attributes["NMPRIMTL"]; 
	$nrdctitg = mascara($xmlObjCarregaDados->roottag->tags[0]->attributes["NRDCTITG"],"#.###.###-#");
	$dssititg = $xmlObjCarregaDados->roottag->tags[0]->attributes["DSSITITG"];
	
	include "tabela_altera.php";
		
?>
<script type="text/javascript">
	formataTabela();	
	$('#nmprimtl','#frmCabAltera').val('<? echo $nmprimtl ?>');
	$('#nrdctitg','#frmCabAltera').val('<? echo $nrdctitg." ".$dssititg ?>');
</script>