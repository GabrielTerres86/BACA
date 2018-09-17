<?php

	/************************************************************************
	  Fonte: gerar_boletos.php
	  Autor: Lombardi
	  Data : 29/03/2017                   Última Alteração: --/--/----

	  Objetivo  : Gerar boletos do arquivo

	  Alterações:
	************************************************************************/

	session_cache_limiter("private");
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"Y")) <> "") {
		exibirErro('error',$msgError, 'Alerta - Ayllos','unblockBackground();', false);
		exit();
	}

	// Verifica se o número do arquivo foi informado
	if (!isset($_POST["idarquivo"])) {
			exibirErro('error','Par&acirc;metros incorretos.', 'Alerta - Ayllos','unblockBackground();', false);
		exit();
	}

	$idarquivo = $_POST["idarquivo"];

	// Verifica se número do arquivo é um inteiro válido
	if (!validaInteiro($idarquivo)) {
		exibirErro('error','Arquivo inv&aacute;lido.', 'Alerta - Ayllos','unblockBackground();', false);
		exit();
	}


  $xml  = "<Root>";
  $xml .= "  <Dados>";
  $xml .= "    <idarquiv>".$idarquivo."</idarquiv>";
  $xml .= "  </Dados>";
  $xml .= "</Root>";

  $xmlResult = mensageria($xml, "TELA_COBEMP", "COBEMP_GERA_BOLETO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
  $xmlObject = getObjectXML($xmlResult);

  if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error', htmlentities($msg), 'Alerta - Ayllos','unblockBackground();', false);
			exit();
	}

  // Obtém mensagem final vindo do oracle
  $msg = $xmlObject->roottag->tags[0]->tags[0]->cdata;
	exibirErro('inform', htmlentities($msg), 'Alerta - Ayllos','carregaArquivos(1, 15); unblockBackground();', false);
?>
