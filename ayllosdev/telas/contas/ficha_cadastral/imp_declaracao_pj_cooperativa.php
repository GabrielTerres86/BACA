<?php 
	/**************************************************************************
	  Fonte: imp_declaracao_pj_cooperativa.php
	  Autor: Diogo - MoutS
	  Data : Novembro/2017                   Última Alteração: 26/06/2015

	  Objetivo  : Carregar dados para impressões da declaração de pessoa jurídica cooperativa

	  Alterações:  
	 ************************************************************************* */

	session_cache_limiter("private");
	session_start();


	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");


	if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], "C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}

	$nrdconta = $_POST["nrdconta"];
	$nrcpfcgc = $_POST['nrcpfcgc'];

	$dsiduser = session_id();

	// verifica se opcao eh contrato

	// Executa script para envio do XML
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';		


	$xmlResult = mensageria($xml, "CONTAS", "IMP_DECPJCOOPER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObj = simplexml_load_string($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if ($xmlObj->Erro->Registro->dscritic != '') {
		$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
		?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
		exit();
	}

	// Obtém nome do arquivo PDF 
	$nmarqpdf = $xmlObj;

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
?>
