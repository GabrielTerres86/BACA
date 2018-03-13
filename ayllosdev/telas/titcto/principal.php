<?php
/* !
 * FONTE        : principal.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 07/03/2018
 * OBJETIVO     : Capturar dados para tela TITCTO
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$retornoAposErro = '';
$formulario = 'frmOpcao';

// Recebe o POST
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;
// $dtlibini = (validaData($_POST['dtlibini'])) ? $_POST['dtlibini'] : '';
// $dtlibfim = (validaData($_POST['dtlibfim'])) ? $_POST['dtlibfim'] : '';
$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '';
// $dtlibera = (validaData($_POST['dtlibera'])) ? $_POST['dtlibera'] : '';
$tpcobran = (isset($_POST['tpcobran'])) ? $_POST['tpcobran'] : 'T';
$flresgat = (isset($_POST['flresgat'])) ? $_POST['flresgat'] : '';
$dtvencto = (validaData($_POST['dtvencto'])) ? $_POST['dtvencto'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

switch ($operacao) {
    case 'CT': 
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <tpcobran>".$tpcobran."</tpcobran>";
        $xml .= "   <flresgat>".$flresgat."</flresgat>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"TITCTO","TITCTO_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
            
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);controlaOperacao();");';
           exit;

        }

        $registros = $xmlObj->roottag->tags[0]->tags;
        $qtregist = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
        break;
    case 'FD':
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <tpcobran>".$tpcobran."</tpcobran>";
        $xml .= "   <dtvencto>".$dtvencto."</dtvencto>";
        $xml .= "   <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"TITCTO","TITCTO_RESUMO_DIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
            
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);controlaOperacao();");';
           exit;

        }

        $dados = $xmlObj->roottag->tags[0]->tags[0];

        break;
    case 'BC': $procedure = 'busca_alterar_cheques_descontados';
        break;
    case 'PC': $procedure = 'pesquisa_cheque_descontado';
        break;
    case 'QD': $procedure = 'consulta_quem_descontou';
        $retornoAposErro = 'estadoInicial();';
        break;
    case 'BT': $procedure = 'busca_todos_lancamentos_descto';
        break;
    case 'SD': $procedure = 'busca_saldo_descto';
        break;
}

// Se a data for vazia, pega a data de hj.
if ($cddopcao == 'S' and empty($dtlibera)) {
    $dtlibera = $glbvars['dtmvtolt'];
}
// Verifica se voltou o numero do contrato
include('form_opcao_' . strtolower($cddopcao) . '.php');
?>

<script>
    controlaOpcao();
</script>