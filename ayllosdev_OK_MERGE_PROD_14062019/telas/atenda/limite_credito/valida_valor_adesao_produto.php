<? 
/*!
 * FONTE        : valida_valor_adesao_produto.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 13/04/2018
 * OBJETIVO     : Verificar se a adesao e o valor contratado para o produto 31 - Emprestimo é permitido pelo tipo de conta.
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');	
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0;
	$executar = (isset($_POST['executar'])) ? $_POST['executar'] : "";
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdprodut>".   13    ."</cdprodut>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','',false);
	}
	
	$vllimite = str_replace(',','.',$vllimite);
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdprodut>".   13    ."</cdprodut>";
	$xml .= "		<vlcontra>".$vllimite."</vlcontra>";
	$xml .= "       <cddchave>".    0    ."</cddchave>";
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
		exibirErro("error",$mensagem,"Alerta - Aimaro", "senhaCoordenador(\\\"".$executar."\\\");",false);
	} else {
		echo $executar;
	}

?>