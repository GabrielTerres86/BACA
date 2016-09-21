<?php 
	
	//************************************************************************//
	//*** Fonte: grava_registro_convenio.php                               ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Janeiro/2012                 Última Alteração: 26/02/2014 ***//
	//***                                                                  ***//
	//*** Objetivo  : Incluir, alterar registro do Cartao Transportadora   ***//	
	//***             para as contas dos cooperados                        ***//
	//***                                                                  ***//
	//*** Alterações: 08/02/2012 - Ajustes Pamcar (Adriano).		       ***//
	//***                          									       ***//
	//***															       ***//
	//***             08/03/2013 - Layout padrao (Gabriel).				   ***//
	//***                          									       ***//
	//***             26/02/2014 - Removido chamada da funcao 'trocaBotao'.***//
	//***                          (Fabricio)                              ***//
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
	
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H");
	
	$nrdconta = $_POST["nrdconta"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$flgpamca = $_POST["flgpamca"];
	$vllimpam = $_POST["vllimpam"];
	$dddebpam = $_POST["dddebpam"];
	$nrctapam = $_POST["nrctapam"];
	
					
	// Monta o xml de requisição
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Cabecalho>";
	$xmlRegistro .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlRegistro .= "		<Proc>grava_registro_convenio</Proc>";
	$xmlRegistro .= "	</Cabecalho>";
	$xmlRegistro .= "	<Dados>";
	$xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRegistro .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRegistro .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRegistro .= "		<dthabpam>".$glbvars["dtmvtolt"]."</dthabpam>";
	$xmlRegistro .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlRegistro .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlRegistro .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	
	if ($flgpamca == "S")
		$xmlRegistro .= "		<flgpamca>'true'</flgpamca>";
	else
		$xmlRegistro .= "		<flgpamca>'false'</flgpamca>";
	
	$xmlRegistro .= "		<vllimpam>".$vllimpam."</vllimpam>";	
	$xmlRegistro .= "		<dddebpam>".$dddebpam."</dddebpam>";
	$xmlRegistro .= "		<nrctapam>".$nrctapam."</nrctapam>";
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

	echo 'obtemDadosConta();';
		
	echo 'geraTermo();';
		 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
?>