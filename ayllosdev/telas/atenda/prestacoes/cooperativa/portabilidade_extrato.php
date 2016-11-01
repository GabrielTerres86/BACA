<? 
/*!
 * FONTE        : portabilidade_extrato.php
 * CRIA��O      : Lucas Moreira
 * DATA CRIA��O : 16/06/2015
 * OBJETIVO     : Gera o XML de extrato
 *************
 * ALTERA��O: 
 *************
 */
    session_cache_limiter("private");
	session_start();

	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');		
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();	

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}

	// Guardo os par�metos do POST em vari�veis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';

	// Monta o xml de requisi��o
	$xml = "";
	$xml.= "<Root>";
	$xml.= "	<Dados>";
	$xml.= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml.= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xml.= "	</Dados>";
	$xml.= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PORTAB_CRED", "PORTAB_EXTR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){
		$msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	}
	visualizaPDF($xmlObj->roottag->tags[0]->cdata);
?>