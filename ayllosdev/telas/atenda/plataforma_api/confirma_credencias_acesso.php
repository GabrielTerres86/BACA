<? 
/*!
 * FONTE        : confirma_credencias_acesso.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Cria credencias de acesso.
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();	
	
$nrdconta   = ( ( !empty($_POST['nrdconta']) )   ? $_POST['nrdconta']   : '' );
$nv_senha   = ( ( !empty($_POST['nv_senha']) )   ? $_POST['nv_senha']   : '' );
$cf_senha   = ( ( !empty($_POST['cf_senha']) )   ? $_POST['cf_senha']   : '' );
$cddopcao   = ( ( !empty($_POST['cddopcao']) )   ? $_POST['cddopcao']   : '' );

// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '')
	exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Dados>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "		<dssenha>".$nv_senha."</dssenha>";
$xml .= "	</Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_API", "GRAVA_CREDENCIAIS_ACESSO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',utf8_encode(str_replace('"', "'", $msgErro)),'Alerta - Aimaro','bloqueiaFundo(divRotina);$(\'#nv_senha\', \'#frmCredenciasAcesso\').focus();',false);
}

exibirErro('inform','Credencial de Acesso incluída com sucesso.','Alerta - Aimaro','fechaRotina($(\'#divUsoGenerico\'));controlaOperacao(\'P\');',false);