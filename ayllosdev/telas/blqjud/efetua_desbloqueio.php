<?php 
	
	//***********************************************************************************//
	//*** Fonte: efetua_desbloqueio.php                                               ***//
	//*** Autor: Lucas R.                                                             ***//
	//*** Data : Julho/2013                   Última Alteração:  15/09/2014           ***//
	//***                                                                             ***//
	//*** Objetivo  : Efetua o Desbloqueio Judicial                                   ***//	
	//***                                                                             ***//
	//***                          								                      ***//
	//*** Alterações: 14/03/2014 - verificando desbloqueio judicial (Carlos)          ***//
	//***															                  ***//
	//***			  15/09/2014 - Ajuste em processo de desbloqueio judicial. 		  ***//
	//***						   (Jorge/Gielow - SD 175038)						  ***//
	//***********************************************************************************//
	
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
	$xmlRegistro .= "		<Proc>efetua-desbloqueio-jud</Proc>";
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
    $xmlRegistro .= "		<dsjuizem>".$dsjuizem."</dsjuizem>";
    $xmlRegistro .= "		<dsresord>".$dsresord."</dsresord>";
    $xmlRegistro .= "		<flblcrft>".$flblcrft."</flblcrft>";
    $xmlRegistro .= "		<dtenvres>".$dtenvres."</dtenvres>";
	$xmlRegistro .= "		<nroficon>".$nroficon."</nroficon>";
	$xmlRegistro .= "		<nrctacon>".$nrctacon."</nrctacon>"; 
	$xmlRegistro .= "       <dsinfadc>".$dsinfadc."</dsinfadc>";
	
	$xmlRegistro .= "       <nrofides>".$nrofides."</nrofides>";
	$xmlRegistro .= "       <dtenvdes>".$dtenvdes."</dtenvdes>";
	$xmlRegistro .= "       <dsinfdes>".$dsinfdes."</dsinfdes>";
	$xmlRegistro .= "       <fldestrf>".$fldestrf."</fldestrf>";
	
	$xmlRegistro .= "	</Dados>";
	$xmlRegistro .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRegistro);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);

	$msgErro = $xmlObjConsulta->roottag->tags[0]->tags[0]->tags[4]->cdata;
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsulta->roottag->tags[0]->name) == "ERRO") {
		exibeErro($msgErro);
	}else{
		echo "showError('inform','Opera&ccedil;&atilde;o efetuada com sucesso!','Informe - BLQJUD','hideMsgAguardo();estadoInicial();');";
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","hideMsgAguardo();");';
		exit();
	}
		
?>