<?php
	/**************************************************************************
	
	 Fonte: valida_dados.php
     Autor: Gabriel
     Data : Novembro/2010							Ultima alteracao: 23/07/2013
	 
	 Objetivo: Validar os campos da tela IMPROP.
	 
	 Altera�oes: 23/07/2013 - Paginar a tela de 10 em 10 registros (Gabriel)
	 
	**************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$cddopcao = $_POST["cddopcao"];
	$nrdconta = $_POST["nrdconta"];
	$cdagenci = $_POST["cdagenci"];
	$dtiniper = $_POST["dtiniper"];
	$dtfimper = $_POST["dtfimper"]; 
	
		
	// Verifica Permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],"",$cddopcao)) <> "") {
		exibeErro($msgError);
	}
		
	$xmlValidaDadosContrato  = "";
	$xmlValidaDadosContrato .= "<Root>";
	$xmlValidaDadosContrato .= " <Cabecalho>";
	$xmlValidaDadosContrato .= "    <Bo>b1wgen0024.p</Bo>";
	$xmlValidaDadosContrato .= "    <Proc>valida-dados-contratos</Proc>";
	$xmlValidaDadosContrato .= " </Cabecalho>";
	$xmlValidaDadosContrato .= " <Dados>";
	$xmlValidaDadosContrato .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlValidaDadosContrato .= "    <cdagenci>".$cdagenci."</cdagenci>";
	$xmlValidaDadosContrato .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlValidaDadosContrato .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlValidaDadosContrato .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlValidaDadosContrato .= "    <idorigem>5</idorigem>";
	$xmlValidaDadosContrato .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlValidaDadosContrato .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlValidaDadosContrato .= "    <dtiniper>".$dtiniper."</dtiniper>";
	$xmlValidaDadosContrato .= "    <dtfimper>".$dtfimper."</dtfimper>";
	$xmlValidaDadosContrato .= " </Dados>";
	$xmlValidaDadosContrato .= "</Root>";
	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlValidaDadosContrato);
	
	$xmlObjValidaDadosContrato = getObjectXML($xmlResult);
	
	echo 'hideMsgAguardo();';
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjValidaDadosContrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjValidaDadosContrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Se for validado corretamente, Listar os contratos 
	echo 'listaContratos("1")';
	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 		
		'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}

?>