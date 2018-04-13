<?php 
	
	//***********************************************************************************************************************//
	//*** Fonte: altera_bloqueio.php                                       ***//
	//*** Autor: Lucas R.                                                  ***//
	//*** Data : Junho/2013                   Última Alteração: 13/04/2018                                                ***//
	//***                                                                  ***//
	//*** Objetivo  : Funcoes relativas ao Bloqueio Judicial               ***//	
	//***                                                                  ***//
	//***                          								           ***//
	//*** Alterações: 												       ***//
	//***															       ***//
    //*** 13/04/2018 - inc0012826 Inclusão da função removeCaracteresInvalidos nos campos dsjuizem, dsresord, dsinfadc e  ***//
	//***              dsinfdes (Carlos)                                                                                  ***//
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
	
	$nrdconta = $_POST["nrdconta"];     
    $cdtipmov = $_POST["cdtipmov"];     
    $cdmodali = $_POST["cdmodali"];     
    $vlbloque = $_POST["vlbloque"];     
    $vlresblq = $_POST["vlresblq"];     
    $nroficio = $_POST["nroficio"];
    $nrproces = $_POST["nrproces"];
    $dsjuizem = $_POST["dsjuizem"];
    $dsresord = $_POST["dsresord"];
    $flblcrft = $_POST["flblcrft"];
    $dtenvres = $_POST["dtenvres"];
	$nroficon = $_POST["nroficon"];
	$nrctacon = $_POST["nrctacon"];
	$dsinfadc = $_POST["dsinfadc"];
	$nrofides = $_POST["nrofides"];
	$dtenvdes = $_POST["dtenvdes"];
	$dsinfdes = $_POST["dsinfdes"];
	$fldestrf = $_POST["fldestrf"];
	    
	// Monta o xml de requisição
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Cabecalho>";
	$xmlRegistro .= "		<Bo>b1wgen0155.p</Bo>";
	$xmlRegistro .= "		<Proc>altera-bloqueio-jud</Proc>";
	$xmlRegistro .= "	</Cabecalho>";
	$xmlRegistro .= "	<Dados>";
	$xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRegistro .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
    $xmlRegistro .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xmlRegistro .= "		<cdtipmov>".$cdtipmov."</cdtipmov>";
	$xmlRegistro .= "		<cdmodali>".$cdmodali."</cdmodali>";	
	$xmlRegistro .= "		<vlbloque>".$vlbloque."</vlbloque>";
	$xmlRegistro .= "		<vlresblq>".$vlresblq."</vlresblq>";
	$xmlRegistro .= "		<nroficio>".$nroficio."</nroficio>";
    $xmlRegistro .= "		<nrproces>".$nrproces."</nrproces>";
    $xmlRegistro .= "		<dsjuizem>".removeCaracteresInvalidos($dsjuizem)."</dsjuizem>";
    $xmlRegistro .= "		<dsresord>".removeCaracteresInvalidos($dsresord)."</dsresord>";
    $xmlRegistro .= "		<flblcrft>".$flblcrft."</flblcrft>";
    $xmlRegistro .= "		<dtenvres>".$dtenvres."</dtenvres>";
	$xmlRegistro .= "		<nroficon>".$nroficon."</nroficon>";
	$xmlRegistro .= "		<nrctacon>".$nrctacon."</nrctacon>"; 	
	$xmlRegistro .= "       <dsinfadc>".removeCaracteresInvalidos($dsinfadc)."</dsinfadc>"; 
	$xmlRegistro .= "       <nrofides>".$nrofides."</nrofides>"; 
	$xmlRegistro .= "       <dtenvdes>".$dtenvdes."</dtenvdes>"; 
	$xmlRegistro .= "       <dsinfdes>".removeCaracteresInvalidos($dsinfdes)."</dsinfdes>"; 
	$xmlRegistro .= "       <fldestrf>".$fldestrf."</fldestrf>"; 
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
	
	echo "showError('inform','Bloqueio Alterado com sucesso!','Informe - BLQJUD','hideMsgAguardo();estadoInicial();');";

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","hideMsgAguardo();");';
		exit();
	}
	
?>