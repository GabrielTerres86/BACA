<?php 
	
	//***********************************************************************************//
	//*** Fonte: efetua_desbloqueio.php                                               ***//
	//*** Autor: Lucas R.                                                             ***//
	//*** Data : Julho/2013                   Última Alteração:  03/05/2017           ***//
	//***                                                                             ***//
	//*** Objetivo  : Efetua o Desbloqueio Judicial                                   ***//	
	//***                                                                             ***//
	//***                          								                      ***//
	//*** Alterações: 14/03/2014 - verificando desbloqueio judicial (Carlos)          ***//
	//***															                  ***//
	//***			  15/09/2014 - Ajuste em processo de desbloqueio judicial. 		  ***//
	//***						   (Jorge/Gielow - SD 175038)						  ***//
	//***															                  ***//
	//***			  03/11/2016 - Realizar a chamada da rotina EFETUA-DESBLOQUEIO-JUD***//
	//***					       diretamente do oracle via mensageria				  ***//
	//***						   (Renato Darosci - Supero)                          ***//
	//***															                  ***//
	//***			  03/05/2017 - Passagem do parametro NROFIDES para gravacao dos   ***//
	//***					       dados. (Jaison/Andrino)                            ***//
	//***															                                          ***//
  //***       29/09/2017 - Melhoria 460 - (Andrey Formigari - Mouts)          ***//
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
  $nroficio = $_POST["nroficio"];
	$nrctacon = $_POST["nrctacon"];
	$dtenvdes = $_POST["dtenvdes"];
	$dsinfdes = $_POST["dsinfdes"];
	$fldestrf = $_POST["fldestrf"];
  $vldesblo = $_POST["vldesblo"];	
	$cdmodali = $_POST["cdmodali"];	
    
	// Monta o xml de requisição
	$xmlRegistro  = "";
	$xmlRegistro .= "<Root>";
	$xmlRegistro .= "	<Dados>";
	$xmlRegistro .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRegistro .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
  $xmlRegistro .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xmlRegistro .= "		<nroficio>".$nroficio."</nroficio>";
	$xmlRegistro .= "		<nrctacon>".$nrctacon."</nrctacon>"; 
	$xmlRegistro .= "   <dtenvdes>".$dtenvdes."</dtenvdes>";
	$xmlRegistro .= "   <dsinfdes>".$dsinfdes."</dsinfdes>";
	$xmlRegistro .= "   <fldestrf>".$fldestrf."</fldestrf>";
	$xmlRegistro .= "   <vldesblo>".$vldesblo."</vldesblo>";
	$xmlRegistro .= "   <cdmodali>".$cdmodali."</cdmodali>";
	$xmlRegistro .= "	</Dados>";
	$xmlRegistro .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = mensageria($xmlRegistro, "BLQJUD", "EFETUA_DESBLOQUEIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
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