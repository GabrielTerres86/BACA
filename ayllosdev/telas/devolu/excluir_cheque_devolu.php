<?php
/**
 * User: Bruno Luiz K.
 * File: excluir_cheque_devolu.php
 * Date: 01/10/2018
 * Time: 13:55
 *
 * ALTERAÇOES: 
 *            07/12/2018 - Melhoria no processo de devoluções de cheques.
 *                         Alcemir Mout's (INC0022559).
 *
 *
 */

session_cache_limiter("private");
session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');

// Verifica se tela foi chamada pelo m�todo POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

$data = $_POST;
extract($data); //Post -> function btExcluir() -> devolu.js

$cdcooper = $glbvars['cdcooper'];
$cdoperad = $glbvars['cdoperad'];

$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0175.p</Bo>';
$xml .= '		<Proc>excluir-cheque-devolu</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '		<cdcooper>'.$cdcooper.'</cdcooper>';
$xml .= '		<cdbanchq>'.$cdbanchq.'</cdbanchq>';
$xml .= '		<cdagechq>'.$cdagechq.'</cdagechq>';
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '		<nrctachq>'.$nrctachq.'</nrctachq>';
$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>'; //nrcheque
$xml .= '		<cdoperad>'.$cdoperad.'</cdoperad>';
$xml .= '		<cdbandep>'.$cdbandep.'</cdbandep>';
$xml .= '		<cdagedep>'.$cdagedep.'</cdagedep>';
$xml .= '		<nrctadep>'.$nrctadep.'</nrctadep>';
$xml .= '		<vllanmto>'.$vllanmto.'</vllanmto>';
$xml .= '	</Dados>';
$xml .= '</Root>';

$retornoAposErro = 'focaCampoErro(\'cdalinea\', \'frmAlinea\');';

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);


// --------------------------------------------------------------------------------------------------------------------
// Controle de Erros
// --------------------------------------------------------------------------------------------------------------------
if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
	$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
}else{
	//echo $xmlResult;
	exibirErro('inform','Cheque removido com sucesso!','Alerta - Ayllos','hideMsgAguardo();btnContinuar(1,30);',false);
}