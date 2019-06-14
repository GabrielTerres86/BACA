<? 
/*!
 * FONTE        : busca_titulares.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 13/06/2011 
 * OBJETIVO     : Rotina para busca dos titulares
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 30;
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0059.p</Bo>";
	$xml .= "        <Proc>busca_crapttl</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}
	
	$registros = $xmlObj->roottag->tags[0]->tags;
	$qtregist  = $xmlObj->roottag->tags[0]->attributes["QTREGIST"];
	
		
	include('tab_titulares.php');
							
?>