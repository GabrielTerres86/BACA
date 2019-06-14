<? 
/*!
 * FONTE        : exclui_desenvolvedor.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Exclusão de Desenvolvedores.
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();	
	
// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E',false)) <> '')
	exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
$cddesenvolvedor = ((!empty($_POST['cddesenvolvedor'])) ? $_POST['cddesenvolvedor'] : '');

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Dados>";
$xml .= "		<cddesenvolvedor>".$cddesenvolvedor."</cddesenvolvedor>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "CADDES", "EXCLUI_DESENVOLVEDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
	$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',utf8_encode(str_replace('"', "'", $msgErro)),'Alerta - Aimaro','',false);
}

exibirErro('inform','Desenvolvedor excluido com sucesso.','Alerta - Aimaro','estadoInicial();',false);