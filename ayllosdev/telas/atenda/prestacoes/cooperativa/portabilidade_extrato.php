<? 
/*!
 * FONTE        : portabilidade_extrato.php
 * CRIAÇÃO      : Lucas Moreira
 * DATA CRIAÇÃO : 16/06/2015
 * OBJETIVO     : Gera o XML de extrato
 *************
 * ALTERAÇÃO: 
 *************
 */
    session_cache_limiter("private");
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');		
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();	

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';

	// Monta o xml de requisição
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