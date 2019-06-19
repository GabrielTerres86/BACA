<?php
/* !
 * FONTE        : busca_cargas_sas.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Rotina para buscar as cargas
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 20;
$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;

$retornoAposErro = '';

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], 'I')) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml de requisição
$xml = '';
$xml .= '<Root>';
$xml .= '   <Dados>';
$xml .= '       <nrregist>' . $nrregist . '</nrregist>';
$xml .= '       <nriniseq>' . $nriniseq . '</nriniseq>';
$xml .= '   </Dados>';
$xml .= '</Root>';

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "TELA_IMPPRE", "LISTA_CARGAS_SAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);
//echo $xmlResult; die;
// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Ayllos', $retornoAposErro);
}

//var_dump($xmlResult);die;
$registros = $xmlObjeto->roottag->tags[0];
$qtregist = $xmlObjeto->roottag->tags[1]->cdata;
include('tab_cargas_sas.php');