<?php
/**************************************************************************************
	ATEN��O: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODU��O TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/*************************************************************************
	  Fonte: carrega_dados.php                                               
	  Autor: Tiago                                                  
	  Data : Julho/2012                       �ltima Altera��o: 		   
	                                                                   
	  Objetivo  : Carregar os dados da tela TAB094.              
	                                                                 
	  Altera��es: 05/12/2016 - P341-Automatiza��o BACENJUD - Alterar a passagem da descri��o do 
                               departamento como parametros e passar o o c�digo (Renato Darosci)										   			  
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	} 
	
	$cddopcao = $_POST["cddopcao"];
	
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0139.p</Bo>";
	$xmlCarregaDados .= "    <Proc>acesso_opcao</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	 <cddepart>".$glbvars["cddepart"]."</cddepart>";
	$xmlCarregaDados .= "	 <cddopcao>".$cddopcao."</cddopcao>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		$msgErro  = $xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
						
	} 
		 
?>