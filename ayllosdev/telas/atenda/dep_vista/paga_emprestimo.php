<?
/*
 * FONTE        : paga_emprestimo.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 02/08/2018
 * OBJETIVO     : Realizar pagamento de empréstimo (Conta Transitória - Bloqueado Prejuízo).
   ALTERACOES   :
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');

	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
    $nrctremp = (isset($_POST['nrctremp'])) ? str_replace(".","", $_POST['nrctremp']) : 0;
	$vlrpagto = (isset($_POST['vlrpagto'])) ? str_replace(",",".",str_replace(",","", $_POST['vlrpagto'])) : 0;    
	$vlrabono = (isset($_POST['vlrabono'])) ? str_replace(",",".",str_replace(",","", $_POST['vlrabono'])) : 0;    
  
    // pagamento de empréstimo	

	$xml2  = "<Root>";
	$xml2 .= " <Dados>";
	$xml2 .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml2 .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml2 .= "   <nrctremp>".$nrctremp."</nrctremp>";	
	$xml2 .= "   <vlrabono>".$vlrabono."</vlrabono>";
	$xml2 .= "   <vlrpagto>".$vlrpagto."</vlrpagto>";
	$xml2 .= " </Dados>";
	$xml2 .= "</Root>";

	$acao = "PAGA_EMPRESTIMO_CT";	

	$xmlResult = mensageria($xml2, "TELA_ATENDA_DEPOSVIS", $acao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos',"",false);
	}else{
		$msgRetorno = getByTagName($xmlObjeto->roottag->tags[0], 'msg');
		exibirErro('inform',utf8ToHtml($msgRetorno),'Alerta - Ayllos',"mostraDetalhesCT()",false);
	}	

?>
