<?php
/**************************************************************************
  Fonte: grava_tarifa.php
  Autor: Lucas Moreira
  Data : 09/09/2015                   Última Alteração: --/--/----

  Objetivo  : Grava as tarifas por canal nos parametros do sistema
************************************************************************** */

session_cache_limiter("private");
session_start();
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

/*if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], "C")) <> "") {
    ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
    exit();
}*/

$dsiduser = session_id();

$exercicio = $_POST["exercicio"];
$integral = $_POST['integral'];
$parcelado = $_POST['parcelado'];
$ehnovo = $_POST['ehnovo'];

$xml = '';
$xml .= '<Root>';
$xml .= '	<Dados>';
$xml .= '		<exercicio>' . $exercicio . '</exercicio>';
$xml .= '		<integral>'  . $integral  . '</integral>';
$xml .= '		<parcelado>' . $parcelado . '</parcelado>';
$xml .= '		<ehnovo>' 	 . $ehnovo    . '</ehnovo>';
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML
$xmlResult = mensageria($xml, "PRMDPV", "GRAVA_CUSTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");


// Cria objeto para classe de tratamento de XML
$xmlObjDados = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
    $msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msg, 'Alerta - Ayllos', 'unblockBackground()', false);
}

if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "MSGERRO") {
	$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[0]->cdata;
    exibirErro('error', $msg, 'Alerta - Ayllos', 'unblockBackground()', false);
}

echo 'exibirMensagens("'.$xmlObjDados->roottag->tags[0]->cdata.'","unblockBackground()");bloqueiaFundo($("#divError"));controlaOperacao("BC");';
?>