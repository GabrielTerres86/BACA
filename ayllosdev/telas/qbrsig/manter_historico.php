<?php
	/*!
	 * FONTE        : consulta_regra.php
	 * CRIAÇÃO      : Heitor - Mouts
	 * DATA CRIAÇÃO : 07/12/2018
	 * OBJETIVO     : Rotina para manter as operações da tela QBRSIG
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
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : "";
	$cdhistor = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : "";
	$cdhisrec = (isset($_POST["cdhisrec"])) ? $_POST["cdhisrec"] : "";
	$cdestsig = (isset($_POST["cdestsig"])) ? $_POST["cdestsig"] : "";

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "    <cdhisrec>".$cdhisrec."</cdhisrec>";
	$xml .= "    <cdestsig>".$cdestsig."</cdestsig>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "QBRSIG", "QBRSIG_SALVAR_HISTORICO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

	// Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if ($xmlObjeto->Erro->Registro->dscritic != "") {
		$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		exibirErro("error",$msgErro,"Alerta - Aimaro","",false);
	}

	//Comando para ser excutado em caso de sucesso na operação
	$command = "";
	$command .=  "msgSucessoSalvar();";

	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>