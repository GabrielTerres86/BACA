<?php
	/*!
	 * FONTE          : gerar_relsdv.php
	 * CRIA��O      : Jean Cal�o (Mout�S)
	 * DATA CRIA��O : 24/02/2017
	 * OBJETIVO     : Rotina para gerar o relat�rio de saldo devedor de empr�stimo
	 * --------------
	 * ALTERA��ES   : 
    * -------------- 
	 */		

	session_start();

	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();

	// Ler parametros passados via POST
	$nmdarqui      = (isset($_POST["nmdarqui"]))     ? $_POST["nmdarqui"]      : ""; // Nome do arquivo para importar
	$nmdarsai      = (isset($_POST["nmdarsai"]))     ? $_POST["nmdarsai"]      : "";  // Nome do arquivo para gerar
     
	// Identificar as opera��es/
	$procedure = "RELSDV_GERA_RELAT";
	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "		<nmdarqui>".$nmdarqui."</nmdarqui>";
	$xml .= "		<nmdarsai>".$nmdarsai."</nmdarsai>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "RELSDV", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
		
	// verificar a passagem de parametros
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
		
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial();",false);
	}
		--
		
?>