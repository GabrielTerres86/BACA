<?php 

	//************************************************************************//
	//*** Fonte: calcula_dias_uteis.php                                    ***//
	//*** Autor: Tiago                                                     ***//
	//*** Data : Fevereiro/2012             Última Alteração: 16/02/2012   ***//
	//***                                                                  ***//
	//*** Objetivo  : Calcula quantidade de dias uteis a partir            ***//
	//***             de uma data                                          ***//	 
	//***                                                                  ***//	 
	//*** Alterações: 19/04/2012 Modificado modo de tratamento da varivel  ***//
	//***                        dtiniper (Tiago)                          ***//
	//************************************************************************//
	
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	$cdcooper = (isset($glbvars["cdcooper"])) ? $glbvars["cdcooper"] : '' ;
	$cdoperad = (isset($glbvars["cdoperad"])) ? $glbvars["cdoperad"] : '' ;
	
	if($_POST["dtiniper"] != ""){
		$dtiniper = $_POST["dtiniper"];		
	}else{	
		$dtiniper = (isset($glbvars["dtmvtolt"])) ? $glbvars["dtmvtolt"] : '' ;		
	}	
	
	$dtfinper = (isset($_POST['dtfinper'])) ? $_POST['dtfinper'] : '' ;
	$cdagenci = "0";
	$nrdcaixa = "0";
	$nmdatela = "IDENTI";
	$idorigem = "0";
	$nrdconta = "0";			
		
	// Monta o xml de requisição
	$xmlPac  = "";
	$xmlPac .= "<Root>";
	$xmlPac .= "  <Cabecalho>";
	$xmlPac .= "	<Bo>b1wgen0097.p</Bo>";
	$xmlPac .= "    <Proc>RetornaDiasUteis</Proc>";
	$xmlPac .= "  </Cabecalho>";
	$xmlPac .= "  <Dados>";
	$xmlPac .= "        <cdcooper>".$cdcooper."</cdcooper>";
	$xmlPac .= "		<cdagenci>".$cdagenci."</cdagenci>";
	$xmlPac .= "		<nrdcaixa>".$nrdcaixa."</nrdcaixa>";
	$xmlPac .= "		<cdoperad>".$cdoperad."</cdoperad>";
	$xmlPac .= "		<nmdatela>".$nmdatela."</nmdatela>";
	$xmlPac .= "		<idorigem>".$idorigem."</idorigem>";	
	$xmlPac .= "		<dtiniper>".$dtiniper."</dtiniper>";	
	$xmlPac .= "		<dtfinper>".$dtfinper."</dtfinper>";	
	$xmlPac .= "  </Dados>";
	$xmlPac .= "</Root>";				
	
	// Executa script para envio do XML	
	$xmlResult = getDataXML($xmlPac);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPac = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjPac->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPac->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 				
			
	$dados = $xmlObjPac->roottag->tags[0]->tags[0];		
		
	echo "$('#qtdialib').val('".$xmlObjPac->roottag->tags[0]->attributes['QTDIALIB']."');";	
	echo "verificaQtDiaLib();";
	echo "hideMsgAguardo();";	
	
	
?>