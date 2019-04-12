<? 
/*!
 * FONTE        : responde_contestacao.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Responde Contestação.
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();	

$dsrowid    = ( ( !empty($_POST['dsrowid']) )      ? $_POST['dsrowid']    : '' );
$cdmotivo   = ( ( !empty($_POST['cdmotivo']) )     ? $_POST['cdmotivo']   : 0 );
$idstatus   = ( ( !empty($_POST['idsituacao']) )   ? $_POST['idsituacao'] : 0 );

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Dados>";
$xml .= "		<dsrowid>".$dsrowid."</dsrowid>";
$xml .= "		<cdmotivo>".$cdmotivo."</cdmotivo>";
$xml .= "		<idstatus>".$idstatus."</idstatus>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "ATENDA", "RESPONDE_PORTABILIDADE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',utf8_encode(str_replace('"', "'", $msgErro)),'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
}

exibirErro('inform','Resposta da contestação enviada com sucesso.','Alerta - Aimaro','fechaRotina($(\"#divUsoGenerico\")); grid.carregar(cabecalho.getOpcaoSelecionada(), 1); exibeRotina($(\"#divRotina\"));',false);