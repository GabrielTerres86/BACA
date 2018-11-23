<?php
	/*!
    * FONTE        : insere_historicos.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : Inserir parametrizacao de historicos para usar nos lançamentos contabeis tela SLIP
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
	$lscdhistor   = (isset($_POST["lscdhistor"]))    ? $_POST["lscdhistor"]    : ""; // 
	$lsnrctadeb   = (isset($_POST["lsnrctadeb"]))    ? $_POST["lsnrctadeb"]    : ""; // 
	$lsnrctacrd   = (isset($_POST["lsnrctacrd"]))    ? $_POST["lsnrctacrd"]    : ""; // 
	

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <cdcooper></cdcooper>";		
	$xml .= "   <lscdhistor>".$lscdhistor."</lscdhistor>";
	$xml .= "   <lsnrctadeb>".$lsnrctadeb."</lsnrctadeb>";
	$xml .= "   <lsnrctacrd>".$lsnrctacrd."</lsnrctacrd>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "INSERE_HISTORICOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"]                    , $glbvars["cdoperad"],  "</Root>");

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
		echo "hideMsgAguardo();concluirHistorico();";
	}

	
?>

