<?php 
	
	//************************************************************************//
	//*** Fonte: busca_cooperado.php                                       ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Março/2013                   Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar o nome do cooperado com base no numero da     ***//	
	//***             conta.                                               ***//	 
	//***                                                                  ***//
	//*** Alterações: 												       ***//
	//***                          								           ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	
	$nrctaori = $_POST["nrdconta"];
	
					
	// Monta o xml de requisição
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Cabecalho>";
	$xmlRegistro .= "		<Bo>b1wgen0154.p</Bo>";
	$xmlRegistro .= "		<Proc>busca-cooperado</Proc>";
	$xmlRegistro .= "	</Cabecalho>";
	$xmlRegistro .= "	<Dados>";
	$xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRegistro .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRegistro .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRegistro .= "		<nrctaori>".$nrctaori."</nrctaori>";
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
	
	$nmprimtl = $xmlObjRegistro->roottag->tags[0]->attributes["NMPRIMTL"];
	
	echo 'cNmprimtl.val("'.$nmprimtl.'");';
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
		 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
?>