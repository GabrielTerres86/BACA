<?php
	/*!
	 * FONTE        : incluir_historico.php
	 * CRIAÇÃO      : Alcemir Junior - Mout's
	 * DATA CRIAÇÃO : 21/09/2018
	 * OBJETIVO     : Rotina para manter as operações da tela PARCBA
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
	$cddopcao     = (isset($_POST["cddopcao"]))    ? $_POST["cddopcao"]    : ""; // Opção (C-Consulta/I-Inclusão/E-Exclusão)
	$cdtransa  = (isset($_POST["cdtransa"])) ? $_POST["cdtransa"] : ""; // Código da transacao
	$cdhistor  = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : ""; // Código da transacao
	$dstransa  = (isset($_POST["dstransa"])) ? $_POST["dstransa"] : "";
    $indebcre_transa  = (isset($_POST["indebcre_transa"])) ? $_POST["indebcre_transa"] : "";
    $indebcre_histor  = (isset($_POST["indebcre_histor"])) ? $_POST["indebcre_histor"] : "";

    $lscdhistor = (isset($_POST["lscdhistor"]))    ? $_POST["lscdhistor"]    : "";
    $lsindebcre = (isset($_POST["lsindebcre"]))    ? $_POST["lsindebcre"]    : "";

	//Validar permissão do usuário
	//if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
	//	exibirErro("error",$msgError,"Alerta - Aimaro","",false);
	//}

		
			$nmdeacao = "INSERE_PARAMETRO";
        

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";			
	   $xml .= "<cdtransa>".$cdtransa."</cdtransa>";
	   $xml .= "<dstransa>".$dstransa."</dstransa>";	
	   $xml .= "<cdhistor>".$cdhistor."</cdhistor>";
	   $xml .= "<indebcre_transa>".$indebcre_transa."</indebcre_transa>";
	   $xml .= "<indebcre_histor>".$indebcre_histor."</indebcre_histor>";
    $xml .= "<lscdhistor>".$lscdhistor."</lscdhistor>";
    $xml .= "<lsindebcre>".$lsindebcre."</lsindebcre>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PARCBA", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

	// Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->Erro->Registro->dscritic != "") {
		$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		exibirErro("error",$msgErro,"Alerta - Aimaro","",false);
	}

	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();";
?>