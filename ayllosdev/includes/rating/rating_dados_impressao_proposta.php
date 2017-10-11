<?php 

	//************************************************************************//
	//*** Fonte: rating_dados_impressao_proposta.php                       ***//
	//*** Autor: Heitor                                                    ***//
	//*** Data : Setembro/2017                Última Alteração: 17/09/2017 ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar dados para impressão do RATING Proposta       ***//
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once("../controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpctrato"]) || !isset($_POST["nrctrato"]) || !isset($_POST["iddivcri"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$tpctrato = $_POST["tpctrato"];
	$nrctrato = $_POST["nrctrato"];
	$iddivcri = $_POST["iddivcri"];
	
		// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o tipo de contrato é um inteiro válido
	if (!validaInteiro($tpctrato)) {
		exibeErro("Tipo de contrato inv&aacute;lido.");		
	}

	// Verifica se número do contrato é um inteiro válido
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
	
	// Se ocorrer um erro, mostra crítica
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
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
		exit();
	}	

?>