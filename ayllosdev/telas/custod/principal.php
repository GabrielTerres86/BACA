<?php
/* !
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 19/01/2012
 * OBJETIVO     : Capturar dados para tela CUSTOD
 * --------------
 * ALTERAÇÕES   : 02/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 *              : 16/12/2016 - Alterações referentes ao projeto 300. (Reinert)
 * -------------- 
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Inicializa
$procedure = '';

// Variáveis globais
$glb_cdcooper = (isset($glbvars['cdcooper'])) ? $glbvars['cdcooper'] : 0;
$glb_nrdcaixa = (isset($glbvars['nrdcaixa'])) ? $glbvars['nrdcaixa'] : 0;
$glb_nmdatela = (isset($glbvars['nmdatela'])) ? $glbvars['nmdatela'] : '';
$glb_idorigem = (isset($glbvars['idorigem'])) ? $glbvars['idorigem'] : 0;
$glb_dtmvtolt = (isset($glbvars['dtmvtolt'])) ? $glbvars['dtmvtolt'] : '';
$glb_dtmvtoan = (isset($glbvars['dtmvtoan'])) ? $glbvars['dtmvtoan'] : '';


// Recebe o POST
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;
$tpcheque = (isset($_POST['tpcheque'])) ? $_POST['tpcheque'] : 0;
$dtlibini = (isset($_POST['dtlibini'])) ? $_POST['dtlibini'] : '';
$dtlibini = (validaData($dtlibini)) ? $dtlibini : '';
$dtlibfim = (isset($_POST['dtlibfim'])) ? $_POST['dtlibfim'] : '';
$dtlibfim = (validaData($dtlibfim)) ? $dtlibfim : '';
$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '';
$dtlibera = (isset($_POST['dtlibera'])) ? $_POST['dtlibera'] : '';
$dtlibera = (validaData($dtlibera)) ? $dtlibera : '';
$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : '';
$cdcmpchq = (isset($_POST['cdcmpchq'])) ? $_POST['cdcmpchq'] : '';
$cdbanchq = (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : '';
$cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : '';
$nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : '';
$nrcheque = (isset($_POST['nrcheque'])) ? $_POST['nrcheque'] : '';
$vlcheque = (isset($_POST['vlcheque'])) ? $_POST['vlcheque'] : '';
$dsdopcao = (isset($_POST['dsdopcao'])) ? $_POST['dsdopcao'] : 0;
$dtcusini = (isset($_POST['dtcusini'])) ? $_POST['dtcusini'] : '';
$dtcusini = (validaData($dtcusini)) ? $dtcusini : '';
$dtcusfim = (isset($_POST['dtcusfim'])) ? $_POST['dtcusfim'] : '';
$dtcusfim = (validaData($dtcusfim)) ? $dtcusfim : '';
$nrdolote = (isset($_POST['nrdolote'])) ? $_POST['nrdolote'] : '';
$dsdocmc7 = (isset($_POST['dsdocmc7'])) ? $_POST['dsdocmc7'] : '';
$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : (isset($glbvars['cdagenci'])) ? $glbvars['cdagenci'] : 0;

$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Aimaro', '', false);
}

switch ($operacao) {
    case 'CCC': $procedure = 'consulta_cheques_custodia';
        break;
    case 'BFD': $procedure = 'busca_fechamento_custodia';
        break;
    case 'PCC': $procedure = 'pesquisa_cheque_custodia';
        break;
    case 'TLC': $procedure = 'busca_todos_lancamentos_custodia';
        break;
    case 'SDC': $procedure = 'busca_saldo_custodia';
        break;
}

// Se a data for vazia, pega a data de hj.
if ($cddopcao == 'S' and empty($dtlibera)) {
    $dtlibera = $glbvars['dtmvtolt'];
}

// Monta o xml de requisição
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0018.p</Bo>';
$xml .= '		<Proc>' . $procedure . '</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>' . $glb_cdcooper . '</cdcooper>';
$xml .= '		<cdagenci>' . $cdagenci . '</cdagenci>';
$xml .= '		<nrdcaixa>' . $glb_nrdcaixa . '</nrdcaixa>';
$xml .= '		<nmdatela>' . $glb_nmdatela . '</nmdatela>';
$xml .= '		<idorigem>' . $glb_idorigem . '</idorigem>';
$xml .= '		<dtmvtolt>' . $glb_dtmvtolt . '</dtmvtolt>';
$xml .= '		<dtmvtoan>' . $glb_dtmvtoan . '</dtmvtoan>';
$xml .= '		<nrdconta>' . $nrdconta . '</nrdconta>';
$xml .= '		<nrcpfcgc>' . $nrcpfcgc . '</nrcpfcgc>';
$xml .= '		<tpcheque>' . $tpcheque . '</tpcheque>';
$xml .= '		<dtlibini>' . $dtlibini . '</dtlibini>';
$xml .= '		<dtlibfim>' . $dtlibfim . '</dtlibfim>';
$xml .= '		<dtlibera>' . $dtlibera . '</dtlibera>';
$xml .= '		<nrborder>' . $nrborder . '</nrborder>';
$xml .= '		<cdcmpchq>' . $cdcmpchq . '</cdcmpchq>';
$xml .= '		<cdbanchq>' . $cdbanchq . '</cdbanchq>';
$xml .= '		<cdagechq>' . $cdagechq . '</cdagechq>';
$xml .= '		<nrctachq>' . $nrctachq . '</nrctachq>';
$xml .= '		<nrcheque>' . $nrcheque . '</nrcheque>';
$xml .= '		<vlcheque>' . $vlcheque . '</vlcheque>';
$xml .= '		<tpdsaldo>' . $dsdopcao . '</tpdsaldo>';
$xml .= '		<nriniseq>' . $nriniseq . '</nriniseq>';
$xml .= '		<nrregist>' . $nrregist . '</nrregist>';
$xml .= '		<dtcusini>' . $dtcusini . '</dtcusini>';
$xml .= '		<dtcusfim>' . $dtcusfim . '</dtcusfim>';
$xml .= '		<nrdolote>' . $nrdolote . '</nrdolote>';
$xml .= '		<dsdocmc7>' . $dsdocmc7 . '</dsdocmc7>';
$xml .= '	</Dados>';
$xml .= '</Root>';

//// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    $nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
	$retornoAposErro = (isset($retornoAposErro)) ? $retornoAposErro : '';
    if (!empty($nmdcampo)) {
        $retornoAposErro = $retornoAposErro . " $('#" . $nmdcampo . "','#frmOpcao').focus();";
    }
    exibirErro('error', $msgErro, 'Alerta - Aimaro', $retornoAposErro, false);
}


$registro = (isset($xmlObjeto->roottag->tags[0]->tags)) ? $xmlObjeto->roottag->tags[0]->tags : array();
$dados = (isset($xmlObjeto->roottag->tags[0]->tags[0]->tags)) ? $xmlObjeto->roottag->tags[0]->tags[0]->tags : array();
$qtregist = (isset($xmlObjeto->roottag->tags[0]->attributes['QTREGIST'])) ? $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'] : 0;

// Verifica se voltou o numero do contrato
include('form_opcao_' . strtolower($cddopcao) . '.php');
?>

<script>
    controlaOpcao();
</script>
