<? 
/*!
 * FONTE        : imprime_simulacao.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 04/07/2011
 * OBJETIVO     : Executa os processos da rotina filha de Simulações da rotina de Empréstimos 
**/
	session_cache_limiter("private");
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	
	isPostMethod();
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrsimula = (isset($_POST['nrsimula'])) ? $_POST['nrsimula'] : '';
	$tpemprst = (isset($_POST['tpemprst'])) ? $_POST['tpemprst'] : '';
	$dsiduser = session_id();
	
	// Monta o xml de requisição
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
	$xml .= "		<tpemprst>".$tpemprst."</tpemprst>";
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
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObj->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
?>