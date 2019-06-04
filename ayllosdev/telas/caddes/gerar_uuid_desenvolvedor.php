<? 
/*!
 * FONTE        : gerar_uuid_desenvolvedor.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Gerar UUID para o Desenvolvedor.
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();	
	
// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A',false)) <> '')
	exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

$cddesenvolvedor = ( ( !empty($_POST['cddesenvolvedor']) ) ? $_POST['cddesenvolvedor'] : '' );

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Dados>";
$xml .= "		<cddesenvolvedor>".$cddesenvolvedor."</cddesenvolvedor>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "CADDES", "GERA_UUID_DESENVOLVEDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',utf8_encode(str_replace('"', "'", $msgErro)),'Alerta - Aimaro','',false);
}

$result = $xmlObject->roottag->tags[0];

$dschave = getByTagName($result->tags, "dsuuidds");

exibirErro('inform','UUID gerada com sucesso.','Alerta - Aimaro','$(\'#dschave\',\'#frmChaveAcesso\').val(\''.$dschave.'\');$(\'#btEnviarChaveEmail_2\',\'#frmChaveAcesso\').show();$(\'#btEnviarChaveEmail_1\',\'#frmChaveAcesso\').hide();$(\'#btGerarUUID\',\'#frmChaveAcesso\').remove();',false);