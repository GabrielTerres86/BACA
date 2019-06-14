<?php
	/*!
    * FONTE        : valida_gerencial.php
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
	$cdgerencial   = (isset($_POST["cdgerencial"]))    ? $_POST["cdgerencial"]    : ""; // gerencial 
    $tipvalida = (isset($_POST["tipvalida"]))    ? $_POST["tipvalida"]    : "";

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
    $xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdgerencial>".$cdgerencial."</cdgerencial>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "VALIDA_GERENCIAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
		                    $glbvars["cdoperad"],  "</Root>");

	//Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);
	$dscritic = $xmlObjeto->Erro->Registro->dscritic;
	// Se ocorrer um erro, mostra crítica
 	if ($dscritic != "") {
        if ($tipvalida == "L"){
            echo "showError('alert','".$dscritic."','Alerta - Aimaro','focarRatGer();')";
        }else{
            echo "showError('alert','".$dscritic."','Alerta - Aimaro','focarCodRisco();')";
        }	
		//$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		//exibirErro("error",utf8ToHtml($msgErro),"Alerta - Aimaro","",false);
	}else{
		echo "hideMsgAguardo();concluirValidacaoGerencial('L');";
	}

	
?>

