<?php
	/*!
    * FONTE        : valida_risco.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : validar se já existe conta contabil tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/

	session_cache_limiter("private");
	session_start();

	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();

	// Ler parametros passados via POST
	$cddrisco   = (isset($_POST["cddrisco"]))    ? $_POST["cddrisco"]    : "";   // codigo de risco
    $tipvalida = (isset($_POST["tipvalida"]))    ? $_POST["tipvalida"]    : "";  // tipo de validacao 
	$nrctadeb   = (isset($_POST["nrctadeb"]))    ? $_POST["nrctadeb"]    : "";   // codigo conta contabil
	$nrctacrd   = (isset($_POST["nrctacrd"]))    ? $_POST["nrctacrd"]    : "";   // codigo conta contabil
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "   <cddrisco>".$cddrisco."</cddrisco>"; // codigo do risco operacional
	$xml .= "   <nrctadeb>".$nrctadeb."</nrctadeb>"; // codigo conta contabil
	$xml .= "   <nrctacrd>".$nrctacrd."</nrctacrd>"; // codigo conta contabil
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "VALIDA_RISCO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
		                    $glbvars["cdoperad"],  "</Root>");

	//Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);
	$dscritic = $xmlObjeto->Erro->Registro->dscritic;
	// Se ocorrer um erro, mostra crítica
 	if ($dscritic != "") {
		
		if ($tipvalida = "L"){
			echo "showError('alert','".$dscritic."','Alerta - Aimaro','focarRatRisco();')";
		}else{
			echo "showError('alert','".$dscritic."','Alerta - Aimaro','focarInputCtaContabil();')";
		}


		//$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		//exibirErro("error",utf8ToHtml($msgErro),"Alerta - Aimaro","",false);
	}else{
		
		echo "hideMsgAguardo();concluirValidacaoRisco('L');";
	}

	
?>

