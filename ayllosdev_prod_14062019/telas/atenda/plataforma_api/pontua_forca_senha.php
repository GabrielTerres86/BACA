<? 
/*!
 * FONTE        : pontua_forca_senha.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Valida a força da senha.
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();	
	
// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C',false)) <> '')
	exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
$nrdconta   = ( ( !empty($_POST['nrdconta']) )   	? $_POST['nrdconta']   	  : '' );
$senha   	= ( ( !empty($_POST['str_senha_1']) )   ? $_POST['str_senha_1']   : '' );

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Dados>";
$xml .= "		<dssenha>".$senha."</dssenha>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_ATENDA_API", "PONTUA_FORCA_SENHA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',utf8_encode(str_replace('"', "'", $msgErro)),'Alerta - Aimaro','',false);
}

$result = $xmlObject->roottag->tags[0];

$dsnvlpw = getByTagName($result->tags, "dsnvlpw");
$nivelpw = getByTagName($result->tags, "nivelpw");

switch($nivelpw){
	case 1:
		$addStyle = "color: #FF0000;";
		break;
	case 2:
		$addStyle = "color: #FFBC00;";
		break;
	case 3:
		$addStyle = "color: #06A24C;";
		break;
	case 4:
		$addStyle = "color: #009C1A;";
		break;
	default:
		$addStyle = "color: #FF0000;";
}

$addStyle .= 'padding: 5px;float: left;font-weight: bold;';

echo "$('.frc_pw', '#frmCredenciasAcesso').attr('style', '$addStyle').html('$dsnvlpw')";