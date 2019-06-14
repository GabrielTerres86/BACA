<?php

	//************************************************************************//
	//*** Fonte: consulta_icf.php                                          ***//
	//*** Autor: Marcelo Ricardo Kestring (Supero)                         ***//
	//*** Data : Marco/2013                   Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Exibir os dados obtidos na consulta dos              ***//	
	//***             processamentos do ICF.                               ***//
	//***                                                                  ***//
	//***                                                                  ***//
	//*** Alterações: 												       ***//
	//***                          									       ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$nrsctareq = $_POST["nrsctareq"];
	$listaacaojud = $_POST["listaacaojud"];
	
	
	// Monta o xml de requisição
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Cabecalho>";
	$xmlRegistro .= "		<Bo>b1wgen0154.p</Bo>";
	$xmlRegistro .= "		<Proc>reenviar-registros-icf</Proc>";
	$xmlRegistro .= "	</Cabecalho>";
	$xmlRegistro .= "	<Dados>";
	$xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRegistro .= "		<nrsctareq>".$nrsctareq."</nrsctareq>";
	$xmlRegistro .= "		<listaacaojud>".$listaacaojud."</listaacaojud>";
	$xmlRegistro .= "	</Dados>";
	$xmlRegistro .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRegistro);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistro->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	
	echo 'alert("ICFs reenviadas com sucesso!");';

	echo 'consultaICF();';
		 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
	
	
	
?>