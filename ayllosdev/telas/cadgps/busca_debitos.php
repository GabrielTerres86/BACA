<? 
/*!
 * FONTE        : busca_debitos.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 10/06/2011 
 * OBJETIVO     : Rotina para busca do debito
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
	$cdidenti = (isset($_POST['cdidenti'])) ? $_POST['cdidenti'] : 0;
	$cddpagto = (isset($_POST['cddpagto'])) ? $_POST['cddpagto'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0;

			
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

	include('form_debitos.php');

?>

<script type='text/javascript'>
	// Alimenta as variáveis globais	
	msgretor = '<? echo $msgretor ?>';
</script>