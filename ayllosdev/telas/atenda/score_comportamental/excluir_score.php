<?php 

	/****************************************************************
	 Fonte: excluir_score.php                                            
	 Autor: Thaise Medeiros - Envolti                                                  
	 Data : Outubro/2018                 Última Alteração: 
	                                                                 
	 Objetivo  : Rotina que realiza a exclusão do score.
	                                                                 
	 Alter.:  
																   	 
	*****************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"E")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o CPF/CNPJ foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos - Conta.");
	}	

	// Verifica se o CPF/CNPJ foi informado
	if (!isset($_POST["cdmodelo"])) {
		exibeErro("Par&acirc;metros incorretos - Modelo.");
	}

	// Verifica se a data foi informada
	if (!isset($_POST["dtbase"])) {
		exibeErro("Par&acirc;metros incorretos - Data.");
	}

	$cdmodelo = $_POST["cdmodelo"];
	$nrdconta = $_POST["nrdconta"];
	$dtbase   = $_POST["dtbase"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta inv&aacute;lida.");
	}
	
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdmodelo>" . $cdmodelo . "</cdmodelo>";
	$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
	$xml .= "   <dtbase>" . $dtbase . "</dtbase>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "SCORE", "LISTA_EXCL_SCORE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		echo 'hideMsgAguardo();';
		echo 'showError("error", "'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'", "Alerta - Ayllos", "bloqueiaFundo(divRotina);fechaRotina(divRotina);");';
	} else {
		$exclusoes = $xmlObj->roottag->tags[0]->tags;
		include('tab_exclusao.php');
	}

	
	
?>