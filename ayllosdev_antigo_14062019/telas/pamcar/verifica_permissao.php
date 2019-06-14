<?php 
	
	//************************************************************************//
	//*** Fonte: verifica_permissao.php                                    ***//
	//*** Autor: Fabr�cio                                                  ***//
	//*** Data : Dezembro/2011                �ltima Altera��o:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Verificar permissao para alteracao dos dados         ***//	
	//***                                                                  ***//	 
	//*** Altera��es: 												       ***//
	//***                          									       ***//
	//***	05/12/2016 - P341-Automatiza��o BACENJUD - Alterar a passagem  ***//
	//***             	 da descri��o do departamento como parametros e    ***//
	//***                passar o o c�digo (Renato Darosci)                ***//
	//***                          									       ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
					
	// Monta o xml de requisi��o
	$xmlPermissao  = "";
	$xmlPermissao .= "<Root>";
	$xmlPermissao .= "	<Cabecalho>";
	$xmlPermissao .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlPermissao .= "		<Proc>verifica_permissao</Proc>";
	$xmlPermissao .= "	</Cabecalho>";
	$xmlPermissao .= "	<Dados>";
	$xmlPermissao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlPermissao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";	
	$xmlPermissao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlPermissao .= "		<cddepart>".$glbvars["cddepart"]."</cddepart>";
	$xmlPermissao .= "	</Dados>";
	$xmlPermissao .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlPermissao);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjPermissao = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjPermissao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPermissao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';

	echo 'liberaCampos();';
		 
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
?>