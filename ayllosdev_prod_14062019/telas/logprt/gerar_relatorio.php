<?php
//************************************************************************//
//*** Fonte: gerar_extrato.php                                         ***//
//*** Autor: Lombardi                                                  ***//
//*** Data : Junho/2015                   Ultima Alteracao: ??/06/2015 ***//
//***                                                                  ***//
//*** Objetivo: Imprimir relatório de críticas na liquidação de 	   ***//
//*** contratos por portabilidade ou na efetivação de contratos por    ***//
//*** portabilidade									 				   ***//
//***                                                                  ***//
//************************************************************************//
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();


if (($msgError = validaPermissao($glbvars['nmdatela'], '', '', false)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', 'fnVoltar();', false);
}


// Verifica se parâmetros necessários foram informados
if (!isset($_POST['cdopcao']) ||
        !isset($_POST['dtlogini']) ||
        !isset($_POST['dtlogfin'])) {
    ?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
    exit();
}

// Recebe as variaveis
$cdopcao = isset($_POST["cdopcao"]) ? $_POST["cdopcao"] : "C";
$dtlogini = isset($_POST["dtlogini"]) && validaData($_POST["dtlogini"]) ? $_POST["dtlogini"] : $glbvars["dtmvtolt"];
$dtlogfin = isset($_POST["dtlogfin"]) && validaData($_POST["dtlogfin"]) ? $_POST["dtlogfin"] : $glbvars["dtmvtolt"];

$dsiduser = session_id();

// Monta o xml de requisição
$xml = '';
$xml .= '<Root>';
$xml .= '	<Dados>';
$xml .= '		<cdopcao>' . $cdopcao . '</cdopcao>';
$xml .= '		<dtlogini>' . $dtlogini . '</dtlogini>';
$xml .= '		<dtlogfin>' . $dtlogfin . '</dtlogfin>';
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML
$xmlResult = mensageria($xml, "LOGPRT", "LOGPRT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

// Cria objeto para classe de tratamento de XML
$xmlObjDados = getObjectXML($xmlResult);

//echo ($xmlObjDados);
// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
    $msgErro = trim($xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
    
    if ( $msgErro == 'LogNaoEncontrado' ) {
        $msgErro = 'N&atilde;o foi poss&iacute;vel encontrar o arquivo de log ou n&atilde;o h&aacute; registros no log.';
    }
    exibirErro('error',$msgErro, 'Alerta - Ayllos', "estadoInicial();", false);
} else {
    echo ($xmlObjDados->roottag->tags[0]->cdata);
}
?>