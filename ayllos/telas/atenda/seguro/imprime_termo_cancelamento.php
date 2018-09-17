<? 
	/*!
	 * FONTE        : imprime_termo_cancelamento.php
	 * CRIAÇÃO      : Rogério Giacomini de Almeida (GATI)
	 * DATA CRIAÇÃO : 22/09/2011
	 * OBJETIVO     : Processo de impressão do termo de cancelamento
	 *
	 * ALTERACOES   : Ajuste em alerta de erro. (Jorge)
	**/
	
	session_cache_limiter("private");
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	
	isPostMethod();

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctrseg = (isset($_POST['nrctrseg'])) ? $_POST['nrctrseg'] : '';
	$tpseguro = (isset($_POST['tpseguro'])) ? $_POST['tpseguro'] : '';
	$nmendter = session_id();
		
	// Monta o xml de requisição
	$xml = "";
	$xml.= "<Root>";
	$xml.= "	<Cabecalho>";
	$xml.= "		<Bo>b1wgen0033.p</Bo>";
	$xml.= "		<Proc>imprimir_termo_cancelamento</Proc>";
	$xml.= "	</Cabecalho>";
	$xml.= "	<Dados>";
	$xml.= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml.= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml.= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml.= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml.= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml.= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
	$xml.= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml.= "		<nrctrseg>".$nrctrseg."</nrctrseg>";
	$xml.= "		<nrdconta>".$nrdconta."</nrdconta>";
    $xml.= "		<nmendter>".$nmendter."</nmendter>";
    $xml.= "		<idseqttl>1</idseqttl>";
	$xml.= "		<tpseguro>".$tpseguro."</tpseguro>";
	$xml.= "		<flgerlog>FALSE</flgerlog>";
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