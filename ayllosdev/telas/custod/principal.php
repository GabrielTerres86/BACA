<?php
/* !
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 19/01/2012
 * OBJETIVO     : Capturar dados para tela CUSTOD
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Recebe o POST
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;
$tpcheque = (isset($_POST['tpcheque'])) ? $_POST['tpcheque'] : 0;
$dtlibini = (validaData($_POST['dtlibini'])) ? $_POST['dtlibini'] : '';
$dtlibfim = (validaData($_POST['dtlibfim'])) ? $_POST['dtlibfim'] : '';
$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '';
$dtlibera = (validaData($_POST['dtlibera'])) ? $_POST['dtlibera'] : '';
$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : '';
$cdcmpchq = (isset($_POST['cdcmpchq'])) ? $_POST['cdcmpchq'] : '';
$cdbanchq = (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : '';
$cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : '';
$nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : '';
$nrcheque = (isset($_POST['nrcheque'])) ? $_POST['nrcheque'] : '';
$vlcheque = (isset($_POST['vlcheque'])) ? $_POST['vlcheque'] : '';
$dsdopcao = (isset($_POST['dsdopcao'])) ? $_POST['dsdopcao'] : 0;

$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
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
$xml .= '       <cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
$xml .= '		<cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
$xml .= '		<nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
$xml .= '		<nmdatela>' . $glbvars['nmdatela'] . '</nmdatela>';
$xml .= '		<idorigem>' . $glbvars['idorigem'] . '</idorigem>';
$xml .= '		<dtmvtolt>' . $glbvars['dtmvtolt'] . '</dtmvtolt>';
$xml .= '		<dtmvtoan>' . $glbvars['dtmvtoan'] . '</dtmvtoan>';
$xml .= '		<dsdepart>' . $glbvars['dsdepart'] . '</dsdepart>';
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

$xml .= '	</Dados>';
$xml .= '</Root>';

//// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    $nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
    if (!empty($nmdcampo)) {
        $retornoAposErro = $retornoAposErro . " $('#" . $nmdcampo . "','#frmOpcao').focus();";
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', $retornoAposErro, false);
}


$registro = $xmlObjeto->roottag->tags[0]->tags;
$dados = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
$qtregist = $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];

// Verifica se voltou o numero do contrato
include('form_opcao_' . strtolower($cddopcao) . '.php');
?>

<script>
    controlaOpcao();
</script>