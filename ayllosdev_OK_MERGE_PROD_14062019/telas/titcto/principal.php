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
$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '';
$tpcobran = (isset($_POST['tpcobran'])) ? $_POST['tpcobran'] : 'T';
$flresgat = (isset($_POST['flresgat'])) ? $_POST['flresgat'] : '';
$dtvencto = (validaData($_POST['dtvencto'])) ? $_POST['dtvencto'] : '';
$tpdepesq = (isset($_POST['tpdepesq'])) ? $_POST['tpdepesq'] : '';
$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : '';
$vltitulo = (isset($_POST['vltitulo'])) ? $_POST['vltitulo'] : '';

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
            
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","unblockBackground();btnVoltar();");';
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
            
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","unblockBackground();btnVoltar();");';
           exit;

        }

        $dados = $xmlObj->roottag->tags[0]->tags[0];

        break;
    case 'SD':
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <tpcobran>".$tpcobran."</tpcobran>";
        $xml .= "   <dtvencto>".$dtvencto."</dtvencto>";
        $xml .= "   <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"TITCTO","TITCTO_CONCILIACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        if ($root->erro){
            echo 'showError("error","'.htmlentities($root->erro->registro->dscritic).'","Alerta - Ayllos","unblockBackground();btnVoltar();");';
           exit;
        }
        $dados = $root->dados;
        break;
    case 'BT': 
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <tpcobran>".$tpcobran."</tpcobran>";
        $xml .= "   <tpdepesq>".$tpdepesq."</tpdepesq>";
        $xml .= "   <nrdocmto>".$nrdocmto."</nrdocmto>";
        $xml .= "   <vltitulo>".converteFloat($vltitulo)."</vltitulo>";
        $xml .= "   <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"TITCTO","TITCTO_LOTEAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
            
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","unblockBackground();btnVoltar();");';
           exit;
        }
        $registros = $xmlObj->roottag->tags[0]->tags;

        $qtregist = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
        break;
    case 'BP': 
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <tpcobran>".$tpcobran."</tpcobran>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"TITCTO","TITCTO_CONSULTA_PAGADOR_REMETENTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
            
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","unblockBackground();btnVoltar();");';
           exit;

        }

        $registros = $xmlObj->roottag->tags[0]->tags;
        $qtregist = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
        
        if ($qtregist == 0) {
           echo 'showError("error","N&atilde;o h&aacute; registros para listar.","Alerta - Ayllos","unblockBackground();btnVoltar();");';
           exit;
        }
        break;
}

// Se a data for vazia, pega a data de hj.
if ($cddopcao == 'S' and empty($dtvencto)) {
    $dtvencto = $glbvars['dtmvtolt'];
}
// Verifica se voltou o numero do contrato
include('form_opcao_' . strtolower($cddopcao) . '.php');
?>

<script>
    controlaOpcao();
</script>