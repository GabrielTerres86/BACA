<?php 
	/**************************************************************************
	  Fonte: imprime_proposta_prestamista.php
	  Autor: Mateus Zimmermann - Mouts
	  Data : Setembro/2018                   Última Alteração:

	  Objetivo  : Impressão da proposta prestamista

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

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctrseg = (isset($_POST['nrctrseg'])) ? $_POST['nrctrseg'] : '';
	$nrctrato = (isset($_POST['nrctrato'])) ? $_POST['nrctrato'] : '';
    

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}

	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nrctrseg>'.$nrctrseg.'</nrctrseg>';
	$xml .= '		<nrctremp>'.$nrctrato.'</nrctremp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = mensageria($xml, "SEGU0003", "IMP_PROPOSTA_SEG_PRES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = utf8ToHtml($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
		exit();
	}

	$nmarqpdf = getByTagName($xmlObj->roottag->tags[0]->tags,'nmarqpdf');
	
	if($nmarqpdf == 'FALSE'){
		?><script language="javascript">alert('Nao possui prestamista.');</script><?php
		exit();
	}

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
?>