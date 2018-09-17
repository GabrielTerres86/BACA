<?php 

	//************************************************************************//
	//*** Fonte: consulta_pac_ope.php                                      ***//
	//*** Autor: Tiago                                                     ***//
	//*** Data : Janeiro/2012             Última Alteração: 04/04/2013     ***//
	//***                                                                  ***//
	//*** Objetivo  : Consulta do pac de trabalho do operador              ***//
	//***                                                                  ***//	 
	//*** Alterações: 04/04/2013 - Retirar validação de número inteiro para código do operador (David).       
	//***
	//***		      11/07/2016 - Correcao do erro de inexistencia do indice 0	dentro da TAG de retorno do XML. SD 479874 (Carlos R.) 
	//***
	//***			  27/07/2016 - Corrigi a forma de recuperacao do erro no XML de retorno. SD 479874 (Carlos R.)									
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("includes/config.php");
	require_once("includes/funcoes.php");	
	
	// Classe para leitura do xml de retorno
	require_once("class/xmlfile.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '' ;
	$cdoperad = (isset($_POST['cdoperad'])) ? $_POST['cdoperad'] : '' ;
	$cdagenci = "0";
	$nrdcaixa = "0";
	$nmdatela = "IDENTI";
	$idorigem = "0";
	$nrdconta = "0";
	$cdpactra = '0';
	
	// Monta o xml de requisição
	$xmlPac  = "";
	$xmlPac .= "<Root>";
	$xmlPac .= "  <Cabecalho>";
	$xmlPac .= "	<Bo>b1wgen0000.p</Bo>";
	$xmlPac .= "    <Proc>consulta-pac-ope</Proc>";
	$xmlPac .= "  </Cabecalho>";
	$xmlPac .= "  <Dados>";
	$xmlPac .= "        <cdcooper>".$cdcooper."</cdcooper>";
	$xmlPac .= "		<cdagenci>".$cdagenci."</cdagenci>";
	$xmlPac .= "		<nrdcaixa>".$nrdcaixa."</nrdcaixa>";
	$xmlPac .= "		<cdoperad>".$cdoperad."</cdoperad>";
	$xmlPac .= "		<nmdatela>".$nmdatela."</nmdatela>";
	$xmlPac .= "		<idorigem>".$idorigem."</idorigem>";	
	$xmlPac .= "		<cdpactra>".$cdpactra."</cdpactra>";	
	$xmlPac .= "  </Dados>";
	$xmlPac .= "</Root>";				
	
	// Executa script para envio do XML	
	$xmlResult = getDataXML($xmlPac);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPac = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjPac->roottag->tags[0]->name) && strtoupper($xmlObjPac->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPac->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
			
	$dados = ( isset($xmlObjPac->roottag->tags[0]->tags[0]) ) ? $xmlObjPac->roottag->tags[0]->tags[0] : null;
		
	$cdpactra = ( isset($xmlObjPac->roottag->tags[0]->attributes['CDPACTRA']) ) ? $xmlObjPac->roottag->tags[0]->attributes['CDPACTRA'] : null;

	echo "$('#cdpactra').val('".$cdpactra."');";
	echo "$('#cddsenha').focus();";
	echo "hideMsgAguardo();";	
	
?>