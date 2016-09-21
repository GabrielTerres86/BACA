<?
/* !
 * FONTE        : consulta_linha_credito.php
 * CRIAÇÃO      : Lucas Lunelli
 * DATA CRIAÇÃO : 06/08/2015
 * OBJETIVO     : Consulta de Linhas de Crédito - Tela FINALI
 * --------------
 * ALTERACOES   : 10/08/2015 - Alterações e correções (Lunelli SD 102123)
 * --------------
 */

session_cache_limiter("private");
session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : 0;

$retornoAposErro = 'estadoInicial();';

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml dinâmico de acordo com a operação
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0167.p</Bo>';
$xml .= '		<Proc>lista-linha-credito</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
$xml .= '       <nrregist>1</nrregist>';
$xml .= '       <nriniseq>1</nriniseq>';
$xml .= '       <cdlcremp>'.$cdlcremp.'</cdlcremp>';
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

// ----------------------------------------------------------------------------------------------------------------------------------
// Controle de Erros
// ----------------------------------------------------------------------------------------------------------------------------------
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Ayllos', $retornoAposErro, false);
}

$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
$dslcremp = trim(getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'dslcremp'));

if (trim($dslcremp) == "") {
	echo "NAO ENCONTRADO";
} else {
	echo "$dslcremp";
}

?>