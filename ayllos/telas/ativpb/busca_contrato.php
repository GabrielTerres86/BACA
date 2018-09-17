<? 
/*!
 * FONTE        : busca_contrato.php
 * CRIAÇÃO      : Diego Simas - AMcom
 * DATA CRIAÇÃO : 11/05/2018
 * OBJETIVO     : Rotina para busca dos contratos
 * ALTERAÇÕES   : 15/05/2018 - Alteração para a lupa que lista os contratos
 *                             listar somente os ativos
 *                             Diego Simas - AMcom 
 *
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
	
	// Monta o xml de requisicao
	$xml  = "<Root>";
	$xml .= "  <Dados>";
	$xml .= "  <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml .= "  <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "ZOOM0001", "BUSCA_CONTRATOS_ATIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
	}
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	//$registros = $xmlObj->roottag->tags[0]->tags;
	include('tab_contrato.php');
							
?>