<? 
/*!
 * FONTE        : imprime_proposta_seguro_vidaprestamista.php
 * CRIAÇÃO      : Rogério Giacomini de Almeida (GATI)
 * DATA CRIAÇÃO : 22/09/2011
 * OBJETIVO     : Processo de impressão de uma proposta de seguro
 *
 * ALTERACOES   : Ajuste em alerta de erro. (Jorge)
				  21/02/2013 - Incluir parametro cddopcao em procedure (Lucas R.) 	
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
	$cdsegura = (isset($_POST['cdsegura'])) ? $_POST['cdsegura'] : '';
	$tpplaseg = (isset($_POST['tpplaseg'])) ? $_POST['tpplaseg'] : '';
	$tpseguro = (isset($_POST['tpseguro'])) ? $_POST['tpseguro'] : '';
	$reccraws = (isset($_POST['reccraws'])) ? $_POST['reccraws'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	
	//$nrctrseg = $_POST['nrctrseg'];
	$nmendter = session_id();
		
	// Monta o xml de requisição
	$xml = "";
	$xml.= "<Root>";
	$xml.= "	<Cabecalho>";
	$xml.= "		<Bo>b1wgen0033.p</Bo>";
	$xml.= "		<Proc>imprimir_alt_seg_vida</Proc>";
	$xml.= "	</Cabecalho>";
	$xml.= "	<Dados>";
	$xml.= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml.= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml.= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml.= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml.= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml.= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml.= "		<idseqttl>1</idseqttl>";
	$xml.= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
	$xml.= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml.= "		<flgerlog>FALSE</flgerlog>";
	$xml.= "		<tpseguro>".$tpseguro."</tpseguro>";
    $xml.= "		<tpplaseg>".$tpplaseg."</tpplaseg>";
	$xml.= "		<cdsegura>".$cdsegura."</cdsegura>";
    $xml.= "		<nrctrseg>".$nrctrseg."</nrctrseg>";    
    $xml.= "		<nmendter>".$nmendter."</nmendter>";
	$xml.= "		<reccraws>".$reccraws."</reccraws>";
    $xml.= "		<cddopcao>".$cddopcao."</cddopcao>";	
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