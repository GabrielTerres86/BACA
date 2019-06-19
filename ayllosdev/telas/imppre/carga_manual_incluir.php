<?php
/* !
 * FONTE        : carga_manual_incluir.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Incluir e excluir cargas manuais
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$dsarquivo = (isset($_POST['dsarquivo'])) ? $_POST['dsarquivo'] : '';
$dsdiretor = (isset($_POST['dsdiretor'])) ? $_POST['dsdiretor'] : '';

// Monta o xml de requisição
$xml = '<Root>';
$xml .= '   <Dados>';
$xml .= '       <tpexecuc>'.$operacao.'</tpexecuc>';
$xml .= '       <dsdiretor>'.$dsdiretor.'</dsdiretor>';
$xml .= '       <dsarquivo>'.$dsarquivo.'</dsarquivo>';
$xml .= '   </Dados>';
$xml .= '</Root>';

if ($operacao == 'L') {
	$nmeacao = "EXEC_CARGA_MANUAL";
} else {
	$nmeacao = "EXEC_EXCLU_MANUAL";
}

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "TELA_IMPPRE", $nmeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
	$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error', htmlentities($msgErro), 'Alerta - Ayllos', 'hideMsgAguardo();', false);
} else {
	echo 'showError("inform", "Operação realizada com sucesso!", "Alerta - Ayllos", "hideMsgAguardo();btnVoltar()");';
}