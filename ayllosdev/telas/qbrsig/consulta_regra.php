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

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
    $xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "QBRSIG", "QBRSIG_CON_REGRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

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
	// Verificar se a opção é de consulta
	
	foreach($xmlObjeto->estsig as $estsig){
		$command .=  "criaLinhaRegra('".$estsig->cdestsig.
								  "','".$estsig->nmestsig.
								  "');";
	}

	$command .= "formataTabParReg();";

	//Esconde a mensagem de aguardo do processo e executa o comando criado pelas opções
	echo "hideMsgAguardo();" . $command;
?>