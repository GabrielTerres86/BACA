<?php

	/*************************************************************************
	  Fonte: carrega_contratos.php                                               
	  Autor: Gabriel                                                  
	  Data : Novembro/2010                       Última Alteração: 	23/07/2013	   
	                                                                   
	  Objetivo  : Carregar os contratos da tela Improp.              
	                                                                 
	  Alterações: 23/07/2013 - Paginar a tela de 10 em 10 registros (Gabriel)										   			  
	                                                                  
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
	

	$cddopcao = $_POST["cddopcao"]; // Opcao Utilizada no carrega_contratos
	$nrdconta = $_POST["nrdconta"];
	$cdagenci = $_POST["cdagenci"];
	$dtiniper = $_POST["dtiniper"];
	$dtfimper = $_POST["dtfimper"];
	$nmrelato = $_POST["nmrelato"];
	
	$nrregist = 10; // CUIDAR PRA NÃO AUMENTAR MUITO ESTE VALOR, POIS OCASIONA ERRO NA GERAÇÃO DO PDF
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;

	
	$xmlCarregaContratos  = "";
	$xmlCarregaContratos .= "<Root>";
	$xmlCarregaContratos .= " <Cabecalho>";
	$xmlCarregaContratos .= "    <Bo>b1wgen0024.p</Bo>";
	$xmlCarregaContratos .= "    <Proc>lista-contratos-sede</Proc>";
	$xmlCarregaContratos .= " </Cabecalho>";
	$xmlCarregaContratos .= " <Dados>";
	$xmlCarregaContratos .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaContratos .= "	 <cdagenci>".$cdagenci."</cdagenci>";
	$xmlCarregaContratos .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaContratos .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaContratos .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCarregaContratos .= "    <idorigem>5</idorigem>";
	$xmlCarregaContratos .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlCarregaContratos .= "    <nmrelato>".$nmrelato."</nmrelato>";
	$xmlCarregaContratos .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlCarregaContratos .= "	 <dtiniper>".$dtiniper."</dtiniper>";
	$xmlCarregaContratos .= " 	 <dtfimper>".$dtfimper."</dtfimper>";
	$xmlCarregaContratos .= " 	 <nrregist>".$nrregist."</nrregist>";
	$xmlCarregaContratos .= " 	 <nriniseq>".$nriniseq."</nriniseq>";
	$xmlCarregaContratos .= " </Dados>";
	$xmlCarregaContratos .= "</Root>";
	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaContratos);
	
	$xmlObjCarregaContratos = getObjectXML($xmlResult);

	// Esconder a mensagem que carrega contratos 
	echo 'hideMsgAguardo();';
	
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaContratos->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaContratos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Quantidade de registros
	$qtregist   = $xmlObjCarregaContratos->roottag->tags[0]->attributes["QTREGIST"];
	
	// Carga a lista dos contratos 
	$contratos  = $xmlObjCarregaContratos->roottag->tags[1]->tags;
	
	// Contabiliza o numero de contratos 
	$qtContratos = count ($contratos);	
		
	// Mostrar os contratos 
	include('mostra_contratos.php');
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
	
?>