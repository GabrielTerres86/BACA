<?php
/* !
 * FONTE        : consulta_tarifas.php
 * CRIAÇÃO      : André Clemer (Supero)
 * DATA CRIAÇÃO : 29/10/2018
 * OBJETIVO     : Rotina para busca os dados das tarifas
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Busca os parâmetos do POST guardando em variáveis
$cddopcao              = (!empty($_POST['cddopcao']))  ? $_POST['cddopcao'] : 'C';
$idservico_api         = (!empty($_POST['idservico_api'])) ? (int) $_POST['idservico_api'] : null;
$arr_dsfinalidade  	   = (!empty($_POST['arr_dsfinalidade'])) ? $_POST['arr_dsfinalidade'] : null;
$carregarFinalidades   = (!empty($_POST['carregarFinalidades'])) ? $_POST['carregarFinalidades'] : 0;

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
	exibeErroNew($msgError);
}

if ($carregarFinalidades == 1){
	$xml = new XmlMensageria();

	$xml->add('idservico_api',$idservico_api);

	$xmlResult = mensageria($xml, "TELA_CADAPI", "CONSULTA_FINALIDADES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
		exibeErroNew($msgErro.'[MENSAGERIA]');exit;
	}

	$registros = $xmlObj->roottag->tags[0]->tags;
}

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");');
}

include('grid_finalidades.php');