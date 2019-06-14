<? 
/*!
 * FONTE        : valida_valor_produto.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 13/04/2018
 * OBJETIVO     : Verificar se o valor contratado para o produto é permitido pelo tipo de conta.
 */

	session_start();
	require_once('../includes/config.php');
	require_once('../includes/funcoes.php');	
	require_once('../includes/controla_secao.php');
	require_once('../class/xmlfile.php');
	isPostMethod();
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$cdprodut = (isset($_POST['cdprodut'])) ? $_POST['cdprodut'] : 0;
	$vlcontra = (isset($_POST['vlcontra'])) ? $_POST['vlcontra'] : 0;
	$executar = (isset($_POST['executar'])) ? $_POST['executar'] : "";
	$nmdivfnc = (isset($_POST['nmdivfnc'])) ? $_POST['nmdivfnc'] : "";
	$cddchave = (isset($_POST['cddchave'])) ? $_POST['cddchave'] : 0;
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdprodut>".$cdprodut."</cdprodut>";
	$xml .= "		<vlcontra>".$vlcontra."</vlcontra>";
	$xml .= "		<cddchave>".$cddchave."</cddchave>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_VALOR_ADESAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	$solcoord = $xmlObj->roottag->tags[0]->cdata;
	$mensagem = $xmlObj->roottag->tags[1]->cdata;
	
	// Se ocorrer um erro, mostra crítica
	if ($solcoord == 1) {
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		
		exibirErro("error",$mensagem,"Alerta - Aimaro", "pedeSenhaCoordenador(2,\\\"".$executar."\\\",\\\"".$nmdivfnc."\\\");",false);
	} else {
		echo $executar;
	}

?>