<?php
/*!
 * FONTE         : obtem_nro_contrato.php
 * CRIAÇÃO       : Anderson Schloegel (Mout's) - PJ470
 * DATA CRIAÇÃO  : 15/05/2019
 * OBJETIVO      : Efetuar consulta do nro do contrato para novo limite
 *
 * ALTERACOES    :
 */
 
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	$nrdconta = empty($_POST["nrdconta"]) ? 0 : $_POST["nrdconta"];

	
	$xml = new XmlMensageria();
	$xml->add('nrdconta',$flg_unid_oper);

	$xmlResult = mensageria($xml, "CNTR0001", 'NOVO_NUM_CNT_LIMITE', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = simplexml_load_string($xmlResult);

	if(!is_null($xmlObj->Erro->Registro)){
		if ($xmlObj->Erro->Registro->dscritic != '') {
			$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
			exibeErro($msgErro);
		}
	}

	$nrctrlim = $xmlObj->inf->nrctrlim;

	echo $nrctrlim;
?>