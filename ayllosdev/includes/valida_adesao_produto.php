<? 
/*!
 * FONTE        : valida_adesao_produto.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 02/04/2018
 * OBJETIVO     : Verificar se o tipo de conta permite a contratação do produto.
 */

	session_start();
	require_once('../includes/config.php');
	require_once('../includes/funcoes.php');	
	require_once('../includes/controla_secao.php');
	require_once('../class/xmlfile.php');
	isPostMethod();
	
	$nrdconta 		= (isset($_POST['nrdconta'])) 		? $_POST['nrdconta']		: 0;
	$cdprodut 		= (isset($_POST['cdprodut'])) 		? $_POST['cdprodut']		: 0;
	$executa_depois = (isset($_POST['executa_depois'])) ? $_POST['executa_depois']	: '';
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdprodut>".$cdprodut."</cdprodut>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
		
	} else {
		
		echo $executa_depois;
		
	}
?>