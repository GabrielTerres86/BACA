<?php

	/*************************************************************************
	  Fonte: valida_endereco.php                                               
	  Autor: Henrique                                                  
	  Data : Agosto/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Validar os dados da tela CADDNE.              
	                                                                 
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrcepend = $_POST["nrcepend"];
	$cdufende = $_POST["cdufende"];
	$dstiplog = $_POST["dstiplog"];
	$nmreslog = $_POST["nmreslog"];
	$nmresbai = $_POST["nmresbai"];
	$nmrescid = $_POST["nmrescid"];
	$dscmplog = $_POST["dscmplog"];
	$nrdrowid = $_POST["nrdrowid"];
		
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0038.p</Bo>";
	$xmlCarregaDados .= "    <Proc>valida-endereco-cep</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	 <nrcepend>".$nrcepend."</nrcepend>";
	$xmlCarregaDados .= "	 <cdufende>".$cdufende."</cdufende>";
	$xmlCarregaDados .= "	 <dstiplog>".$dstiplog."</dstiplog>";
	$xmlCarregaDados .= "	 <nmextlog>".$nmreslog."</nmextlog>";
	$xmlCarregaDados .= "	 <nmreslog>".$nmreslog."</nmreslog>";
	$xmlCarregaDados .= "	 <nmextbai>".$nmresbai."</nmextbai>";
	$xmlCarregaDados .= "	 <nmresbai>".$nmresbai."</nmresbai>";
	$xmlCarregaDados .= "	 <nmextcid>".$nmrescid."</nmextcid>";
	$xmlCarregaDados .= "	 <nmrescid>".$nmrescid."</nmrescid>";
	$xmlCarregaDados .= "	 <dscmplog>".$dscmplog."</dscmplog>";
	$xmlCarregaDados .= "	 <nrdrowid>".$nrdrowid."</nrdrowid>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	echo 'hideMsgAguardo();';
	
	$dados = $xmlObjCarregaDados->roottag->tags[0]->tags[0];
	
	$qtdedend = $xmlObjCarregaDados->roottag->tags[0]->attributes["QTDEDEND"];
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	echo "showConfirmacao('Confirma a altera&ccedil;&atilde;o do endere&ccedil;o?','Endere&ccedil;o','grava_endereco()','','sim.gif','nao.gif');";
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
	
?>