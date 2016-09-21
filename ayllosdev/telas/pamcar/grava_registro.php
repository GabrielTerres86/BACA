<?php 
	
	/************************************************************************
	 Fonte: grava_registro.php                                       
	 Autor: Fabr�cio                                                 
	 Data : Dezembro/2011                �ltima Altera��o: 08/03/2013            
	                                                              
	 Objetivo  : Incluir, alterar registro do Cartao Transportadora  
				 para a cooperativa                                   
	                                                                  
	 Altera��es: 08/02/2012 - Incluido a passagem dos parametros     
	                          cdagenci, nrdcaixa (Adriano).           
																     
	             08/03/2013 - Layout padrao (Gabriel).													  
	                          									     
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
		
	$vllimpam = $_POST["vllimpam"];
	$vlmenpam = $_POST["vlmenpam"];
	$pertxpam = $_POST["pertxpam"];
	$cdcooper = $_POST["cdcooper"];
	
					
	// Monta o xml de requisi��o
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Cabecalho>";
	$xmlRegistro .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlRegistro .= "		<Proc>grava_registro</Proc>";
	$xmlRegistro .= "	</Cabecalho>";
	$xmlRegistro .= "	<Dados>";
	
	if ($glbvars["cdcooper"] == 3)
		$xmlRegistro .= "		<cdcooper>".$cdcooper."</cdcooper>";
	else
		$xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	
	$xmlRegistro .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRegistro .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRegistro .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlRegistro .= "		<dthabpam>".$glbvars["dtmvtolt"]."</dthabpam>";
	$xmlRegistro .= "		<vllimpam>".$vllimpam."</vllimpam>";
	$xmlRegistro .= "		<vlmenpam>".$vlmenpam."</vlmenpam>";	
	$xmlRegistro .= "		<pertxpam>".$pertxpam."</pertxpam>";
	$xmlRegistro .= "	</Dados>";
	$xmlRegistro .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRegistro);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjRegistro->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';

	echo 'trocaBotao("Alterar","frmLimite");';
	echo 'cNmrescop.habilitaCampo();';
	echo 'controlaLayout("false");';
		 
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
?>