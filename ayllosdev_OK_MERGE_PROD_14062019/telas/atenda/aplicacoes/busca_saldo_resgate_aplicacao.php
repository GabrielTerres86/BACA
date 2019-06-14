<? 
/*!
 * FONTE        : busca_saldo_resgate_aplicacao.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 14/05/2018
 * OBJETIVO     : Busca saldo de resgate da aplicacao.
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');	
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	echo $nrdconta;
	echo $idseqttl;
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nraplica = (isset($_POST['nraplica'])) ? $_POST['nraplica'] : 0;
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".    1    ."</idseqttl>";
	$xml .= "		<nraplica>".$nraplica."</nraplica>";
	$xml .= "		<cdprodut>".    0    ."</cdprodut>";
	$xml .= "		<idconsul>".    6    ."</idconsul>";
	$xml .= "		<idgerlog>".    0    ."</idgerlog>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "ATENDA", "LISAPLI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	$dados = $xmlObj->roottag->tags[0]->tags;
	
	$sldresga = getByTagName($dados,'sldresga');
	
	echo "vlresgat = ".$sldresga.";";

?>