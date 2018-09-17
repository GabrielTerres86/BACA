<?php 

	//************************************************************************//
	//*** Fonte: rating_dados_impressao_proposta.php                       ***//
	//*** Autor: Heitor                                                    ***//
	//*** Data : Setembro/2017                �ltima Altera��o: 17/09/2017 ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar dados para impress�o do RATING Proposta       ***//
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once("../controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpctrato"]) || !isset($_POST["nrctrato"]) || !isset($_POST["iddivcri"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$tpctrato = $_POST["tpctrato"];
	$nrctrato = $_POST["nrctrato"];
	$iddivcri = $_POST["iddivcri"];
	
		// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o tipo de contrato � um inteiro v�lido
	if (!validaInteiro($tpctrato)) {
		exibeErro("Tipo de contrato inv&aacute;lido.");		
	}

	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrato)) {
		exibeErro("Contrato inv&aacute;lido.");
	}	

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cddopcao>"."R"."</cddopcao>";
	$xml .= "   <nrctrrat>".$nrctrato."</nrctrrat>";
    $xml .= "   <tpctrrat>".$tpctrato."</tpctrrat>";
    $xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "GERARATINGPROPOSTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra cr�tica
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
		
	}
	
	$nmarqpdf = $xmlObj->roottag->tags[0]->tags[0]->cdata;

	echo 'Gera_Impressao_Proposta("'.$nmarqpdf.'","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';			
		
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
		exit();
	}	

?>