<? 
/*!
 * FONTE        : cancela_portabilidade.php
 * CRIAÇÃO      : Andre Clemer - Supero
 * DATA CRIAÇÃO : 18/10/2018
 * OBJETIVO     : Cancela a portabilidade.
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');	
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();	
	
// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'S',false)) <> '') 
	exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
$nrdconta = ( ( !empty($_POST['nrdconta']) ) ? $_POST['nrdconta'] : 0 );
$cdmotivo = ( ( !empty($_POST['cdmotivo']) ) ? $_POST['cdmotivo'] : 0 );

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Dados>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "		<cdmotivo>".$cdmotivo."</cdmotivo>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "ATENDA", "CANCELA_PORTABILIDADE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
}

exibirErro('inform','Portabilidade cancelada com sucesso.','Alerta - Ayllos','acessaOpcaoAba(2,0,\"0\");bloqueiaFundo(divRotina)',false);
