<?php
	/*!
    * FONTE        : valida_conta_contabil.php
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
	$nrconta_contabil   = (isset($_POST["nrconta_contabil"]))    ? $_POST["nrconta_contabil"]    : ""; // conta contabil a ser validada
	$tipvalida   = (isset($_POST["tipvalida"]))    ? $_POST["tipvalida"]    : ""; // tipo da validacao 
	$nrctadeb   = (isset($_POST["nrctadeb"]))    ? $_POST["nrctadeb"]    : ""; // conta debito
	$nrctacrd   = (isset($_POST["nrctacrd"]))    ? $_POST["nrctacrd"]    : ""; // conta credito
   
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <tipvalida>".$tipvalida."</tipvalida>";
	$xml .= "   <nrconta_contabil>".$nrconta_contabil."</nrconta_contabil>";
	$xml .= "   <nrctadeb>".$nrctadeb."</nrctadeb>";
	$xml .= "   <nrctacrd>".$nrctacrd."</nrctacrd>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "VALIDA_CONTA_CONTABIL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
		                    $glbvars["cdoperad"],  "</Root>");

	//Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);
	$dscritic = $xmlObjeto->Erro->Registro->dscritic;
	// Se ocorrer um erro, mostra crítica
 	if ($dscritic != "") {
		echo "showError('alert','".$dscritic."','Alerta - Aimaro','focarCtaContabilRisco();')";

		//$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		//exibirErro("error",utf8ToHtml($msgErro),"Alerta - Aimaro","",false);
	}else{
		
		if ($tipvalida == ""){
			echo "hideMsgAguardo();criarLinhaParametro('OK');formatarTabelaParam();";
		}
		
		if ($tipvalida == "R"){
			echo "hideMsgAguardo();criarLinhaCtaContabilAlt('".$nrconta_contabil."');formatarTabelaIncRisco();";
		}

		if ($tipvalida == "LR"){ //risco
			echo "hideMsgAguardo();mostrarRiscoOperacional();";
		}

		if ($tipvalida == "LG"){ //gerencial
			echo "hideMsgAguardo();mostrarRateioGerencial();";
		}
		
	}

	
?>

