<?php
	/*!
    * FONTE        : insere_parametrizacao.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : Inserir parametrizacao tela SLIP
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
	$lsnrconta_contabil   = (isset($_POST["lsnrconta_contabil"]))    ? $_POST["lsnrconta_contabil"]    : ""; // conta contabil a ser validada
	$lscdhistor   = (isset($_POST["lscdhistor"]))    ? $_POST["lscdhistor"]    : ""; // conta contabil a ser validada
	$lsid_rateio_gerencial   = (isset($_POST["lsid_rateio_gerencial"]))    ? $_POST["lsid_rateio_gerencial"]    : ""; // conta contabil a ser validada
	$lsid_risco_operacional   = (isset($_POST["lsid_risco_operacional"]))    ? $_POST["lsid_risco_operacional"]    : ""; // conta contabil a ser validada

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <lsnrconta_contabil>".$lsnrconta_contabil."</lsnrconta_contabil>";
	$xml .= "   <lscdhistor>".$lscdhistor."</lscdhistor>";
	$xml .= "   <lsid_rateio_gerencial>".$lsid_rateio_gerencial."</lsid_rateio_gerencial>";
	$xml .= "   <lsid_risco_operacional>".$lsid_risco_operacional."</lsid_risco_operacional>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "INSERE_PARAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
		                    $glbvars["cdoperad"],  "</Root>");

	//Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);
	$dscritic = $xmlObjeto->Erro->Registro->dscritic;
	// Se ocorrer um erro, mostra crítica
 	if ($dscritic != "") {
		echo "showError('alert','".$dscritic."','Alerta - Aimaro','estadoInicial();')";
		//$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		//exibirErro("error",utf8ToHtml($msgErro),"Alerta - Aimaro","",false);
	}else{
		
		echo "hideMsgAguardo();concluirParam();";
	}

	
?>

