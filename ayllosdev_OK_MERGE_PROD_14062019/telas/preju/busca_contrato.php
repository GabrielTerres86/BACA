<? 
/*!
 * FONTE        : busca_contrato.php
 * CRIAÇÃO      : Jean Calao
 * DATA CRIAÇÃO : 20/06/2017
 * OBJETIVO     : Rotina para busca os dados dos contratos
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
	$inprejuz = (isset($_POST['inprejuz'])) ? $_POST['inprejuz'] : 0;	
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "   <inprejuz>".$inprejuz."</inprejuz>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PREJU", "BUSCA_CONTRATOS_PRJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',"",false);
	}
	
    $registros = $xmlObj->roottag->tags;
	
	include('tab_contrato.php');
?>