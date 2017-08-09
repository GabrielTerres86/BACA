<?php

	/************************************************************************
	  Fonte: imprimir_relatorio.php
	  Autor: Lombardi
	  Data : 29/03/2017                   Última Alteração: --/--/----

	  Objetivo  : Carregar dados para impress&otilde;es de desconto de cheques

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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}

	// Verifica se o número da conta foi informado
	if (!isset($_POST["idarquivo"])) {
			?><script language="javascript">alert('Par&acirc;metros incorretos.');</script>
	  <?php
		exit();
	}

	$idarquivo = $_POST["idarquivo"];
	$flgcriti = isset($_POST["idarquivo"]) ? $_POST["flgcriti"] : 0;
	$dsiduser = session_id();

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($idarquivo)) {
		?>
  <script language="javascript">alert('Arquivo inv&aacute;lido.');</script><?php
		exit();
	}

	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($flgcriti)) {
		?><script language="javascript">alert('Contrato inv&aacute;lido.');</script><?php
		exit();
	}

  $xml  = "<Root>";
  $xml .= "  <Dados>";
  $xml .= "    <idarquiv>".$idarquivo."</idarquiv>";
  $xml .= "    <flgcriti>".$flgcriti."</flgcriti>";
  $xml .= "  </Dados>";
  $xml .= "</Root>";

  $xmlResult = mensageria($xml, "TELA_COBEMP", "COBEMP_IMPRI_RELAT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
  $xmlObject = getObjectXML($xmlResult);

  if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
			?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
			exit();
	}

  // Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
  $nmarqpdf = $xmlObject->roottag->tags[0]->tags[0]->cdata;

	// Chama função para mostrar PDF do impresso gerado no browser
  visualizaPDF($nmarqpdf);
?>
