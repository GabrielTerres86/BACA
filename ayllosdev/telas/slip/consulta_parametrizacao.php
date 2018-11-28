<?php
	/*!
    * FONTE        : consulta_parametrizacao.php
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
	$cdhistor   = (isset($_POST["cdhistor"]))    ? $_POST["cdhistor"]    : ""; // conta contabil a ser validada
	$idexige_rateio_gerencial   = (isset($_POST["idexige_rateio_gerencial"]))    ? $_POST["idexige_rateio_gerencial"]    : ""; // conta contabil a ser validada
	$idexige_risco_operacional   = (isset($_POST["idexige_risco_operacional"]))    ? $_POST["idexige_risco_operacional"]    : ""; // conta contabil a ser validada

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <nrconta_contabil>".$nrconta_contabil."</nrconta_contabil>";
	$xml .= "   <cdhistor>".$cdhistor."</cdhistor>";	
	$xml .= "   <id_rateio_gerencial></id_rateio_gerencial>";
	$xml .= "   <id_risco_operacional></id_risco_operacional>";	
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "CONSULTA_PARAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
		                    $glbvars["cdoperad"],  "</Root>");

	//Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);	
	$dscritic = $xmlObjeto->Erro->Registro->dscritic;
    $command = "";
	// Se ocorrer um erro, mostra crítica
 	if ($dscritic != "") {
		echo "showError('alert','".$dscritic."','Alerta - Aimaro','focarInputCtaContabil();')";

		//$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		//exibirErro("error",utf8ToHtml($msgErro),"Alerta - Aimaro","",false);
	}else{
		
		$command .= "limpaTabelaParam();";	
	    $flgconsulta = False;	    
		foreach($xmlObjeto->parametros as $parametros){

			$flgconsulta = True;
			$command .=  "criarLinhaConParam('".$parametros->nrconta_contabil. 
			                                "','" .$parametros->cdhistor.
									        "','" .$parametros->id_rateio_gerencial.
									        "','".$parametros->id_risco_operacional."');";
		}

     	if (!$flgconsulta){
     		$command .=  "criarLinhaConParam('','','','');";
		}
		
		$command .= "formatarTabelaConParam();mostrartabelaConParam();";

		echo "hideMsgAguardo();".$command;
		//criarLinhaParametro();limparCamposParam();formatarTabelaParam();focarInputCtaContabil();
	}

	
?>

