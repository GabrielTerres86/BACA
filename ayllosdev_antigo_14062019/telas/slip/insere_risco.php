<?php
	/*!
    * FONTE        : insere_risco.php
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
	$cdrisco_operacional   = (isset($_POST["cdrisco_operacional"]))    ? $_POST["cdrisco_operacional"]    : ""; // 
	$dsrisco_operacional   = (isset($_POST["dsrisco_operacional"]))    ? $_POST["dsrisco_operacional"]    : ""; // 
	$lsnrconta_contabil   = (isset($_POST["lsnrconta_contabil"]))    ? $_POST["lsnrconta_contabil"]    : ""; // 
	
	

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <cdrisco_operacional>".$cdrisco_operacional."</cdrisco_operacional>";
	$xml .= "   <dsrisco_operacional>".$dsrisco_operacional."</dsrisco_operacional>";
	$xml .= "   <lsnrconta_contabil>".$lsnrconta_contabil."</lsnrconta_contabil>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "INSERE_RISCO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
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
		echo "hideMsgAguardo();concluirRisco();";
	}

	
?>

