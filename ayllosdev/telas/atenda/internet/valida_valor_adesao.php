<? 
/*!
 * FONTE        : valida_valor_adesao.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 02/04/2018
 * OBJETIVO     : Verificar se o valor contratado é permitido pelo tipo de conta.
 * 
 *    Alterações:
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');	
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0;
	$vllimweb = (isset($_POST['vllimweb'])) ? $_POST['vllimweb'] : 0;
	$vllimted = (isset($_POST['vllimted'])) ? $_POST['vllimted'] : 0;
	$vllimvrb = (isset($_POST['vllimvrb'])) ? $_POST['vllimvrb'] : 0;
	
	$vlrmaior = ($vllimweb > $vllimted ? $vllimweb : $vllimted);	
	$vlrmaior = ($vlrmaior > $vllimvrb ? $vlrmaior : $vllimvrb);
	
	$vlrmenor = ($vllimweb < $vllimted ? $vllimweb : $vllimted);	
	$vlrmenor = ($vlrmenor < $vllimvrb ? $vlrmenor : $vllimvrb);
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdprodut>".   14    ."</cdprodut>";
	$xml .= "		<vlcontra>".$vlrmenor."</vlcontra>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_VALOR_ADESAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
	}
	
	$solcoord = $xmlObj->roottag->tags[0]->cdata;
	$mensagem = $xmlObj->roottag->tags[1]->cdata;
	
	// Se ocorrer um erro, mostra crítica
	if ($mensagem != "") {
		exibirErro("error",$mensagem,"Alerta - Ayllos", ($solcoord == 1 ? "senhaCoordenador(\\\"validaDadosLimites(".$inpessoa.");\\\");" : ""),false);
	} else {
			
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<cdprodut>".   14    ."</cdprodut>";
		$xml .= "		<vlcontra>".$vlrmaior."</vlcontra>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "CADA0006", "VALIDA_VALOR_ADESAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
		}
		
		$solcoord = $xmlObj->roottag->tags[0]->cdata;
		$mensagem = $xmlObj->roottag->tags[1]->cdata;
		
		// Se ocorrer um erro, mostra crítica
		if ($mensagem != "") {
			exibirErro("error",$mensagem,"Alerta - Ayllos", ($solcoord == 1 ? "senhaCoordenador(\\\"validaDadosLimites(".$inpessoa.");\\\");" : ""),false);
		} else {
			echo "validaDadosLimites(".$inpessoa.");";
		}
	}
	
?>