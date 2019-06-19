<?php
/* !
 * FONTE        : busca_motivos.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Rotina para buscar os motivos cadastrados
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

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], '@')) <> '') {
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
$xmlResult = mensageria($xml, "CADMOT", "LISTA_MOTIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
//echo $xmlResult;
$xmlObjeto = getObjectXML(utf8_encode($xmlResult));

// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Ayllos', $retornoAposErro);
}

//var_dump($xmlResult);die;
$registros = $xmlObjeto->roottag->tags[0];
$qtregist = $xmlObjeto->roottag->tags[0]->attributes['QTDREGIS'];
include('tab_motivo.php');