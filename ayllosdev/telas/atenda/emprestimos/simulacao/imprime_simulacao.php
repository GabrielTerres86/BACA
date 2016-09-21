<? 
/*!
 * FONTE        : imprime_simulacao.php
 * CRIA��O      : Marcelo L. Pereira (GATI)
 * DATA CRIA��O : 04/07/2011
 * OBJETIVO     : Executa os processos da rotina filha de Simula��es da rotina de Empr�stimos 
**/
	session_cache_limiter("private");
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	
	isPostMethod();
	// Guardo os par�metos do POST em vari�veis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrsimula = (isset($_POST['nrsimula'])) ? $_POST['nrsimula'] : '';
	$dsiduser = session_id();
	
	// Monta o xml de requisi��o
	$xml = "";
	$xml.= "<Root>";
	$xml.= "	<Cabecalho>";
	$xml.= "		<Bo>b1wgen0097.p</Bo>";
	$xml.= "		<Proc>imprime_simulacao</Proc>";
	$xml.= "	</Cabecalho>";
	$xml.= "	<Dados>";
	$xml.= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml.= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml.= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml.= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml.= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml.= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml.= "		<nrdconta>".$nrdconta."</nrdconta>";
    $xml.= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<flgerlog>TRUE</flgerlog>";
	$xml.= "		<nrsimula>".$nrsimula."</nrsimula>";
	$xml .= "		<dsiduser>".$dsiduser."</dsiduser>";
	$xml.= "	</Dados>";
	$xml.= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ){
		$msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	}
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObj->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
?>