<? 
/*!
 * FONTE        : busca_vinculacao_parametro.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 05/03/2013
 * OBJETIVO     : Rotina para busca do vinculo de parametro com tarifa.
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
	$cdfaixav = (isset($_POST['cdfaixav'])) ? $_POST['cdfaixav'] : 0;
	$cdtarifa = (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0;
	$dstarifa = (isset($_POST['dstarifa'])) ? $_POST['dstarifa'] : '';
/*
			
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0093.p</Bo>";
	$xml .= "		<Proc>busca-deb</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<cdidenti>".$cdidenti."</cdidenti>";
	$xml .= "		<cddpagto>".$cddpagto."</cddpagto>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);

	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','estadoInicial()',false);
	}
	
	$msgretor  = $xmlObj->roottag->tags[0]->attributes["MSGRETOR"];
	$registro  = $xmlObj->roottag->tags[0]->tags[0]->tags;
*/
	include('form_vinculacao_parametro.php');

?>