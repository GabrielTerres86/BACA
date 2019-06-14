<?php
	/*!
    * FONTE        : insere_gerenciais.php
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
	$cdcooper   = (isset($_POST["cdcooper"]))    ? $_POST["cdcooper"]    : ""; // 
	$lsidativo   = (isset($_POST["lsidativo"]))    ? $_POST["lsidativo"]    : ""; // 
	$lscdgerencial   = (isset($_POST["lscdgerencial"]))    ? $_POST["lscdgerencial"]    : ""; // 
	

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "   <lsidativo>".$lsidativo."</lsidativo>";
	$xml .= "   <lscdgerencial>".$lscdgerencial."</lscdgerencial>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "INSERE_GERENCIAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
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
		echo "hideMsgAguardo();concluirGerencial();";
	}

	
?>

