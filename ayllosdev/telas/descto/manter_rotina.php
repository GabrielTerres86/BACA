<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 19/01/2012 
 * OBJETIVO     : Rotina para manter as operações da tela DESCTO
 * --------------
 * ALTERAÇÕES   : 02/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
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
$retornoAposErro = '';

// Recebe a operação que está sendo realizada
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : 0;
$cdcmpchq = (isset($_POST['cdcmpchq'])) ? $_POST['cdcmpchq'] : 0;
$cdbanchq = (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : 0;
$cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : 0;
$nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : 0;
$nrcheque = (isset($_POST['nrcheque'])) ? $_POST['nrcheque'] : 0;

if ($operacao == 'VC') {
    $nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;
    $nmcheque = (isset($_POST['nmcheque'])) ? $_POST['nmcheque'] : 0;
} else if ($operacao == 'AC') {
    $auxnrcpf = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;
    $auxnmchq = (isset($_POST['nmcheque'])) ? $_POST['nmcheque'] : 0;
    $nrcpfcgc = (isset($_POST['auxnrcpf'])) ? $_POST['auxnrcpf'] : 0;
    $nmcheque = (isset($_POST['auxnmchq'])) ? $_POST['auxnmchq'] : 0;
}

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Aimaro', '', false);
}

switch ($operacao) {
    case 'BA': $procedure = 'busca_informacoes_associado';
        break;
    case 'VC': $procedure = 'valida_cheques_descontados';
        break;
    case 'AC': $procedure = 'alterar_cheques_descontados';
        break;
}

// Monta o xml dinâmico de acordo com a operação 
$xml = "";
$xml .= "<Root>";
$xml .= "  <Cabecalho>";
$xml .= "	 <Bo>b1wgen0018.p</Bo>";
$xml .= "        <Proc>" . $procedure . "</Proc>";
$xml .= "  </Cabecalho>";
$xml .= "  <Dados>";
$xml .= "       <cdcooper>" . $glbvars['cdcooper'] . "</cdcooper>";
$xml .= "	<cdagenci>" . $glbvars['cdagenci'] . "</cdagenci>";
$xml .= "	<nrdcaixa>" . $glbvars['nrdcaixa'] . "</nrdcaixa>";
$xml .= "	<cdoperad>" . $glbvars['cdoperad'] . "</cdoperad>";
$xml .= "	<nmdatela>" . $glbvars['nmdatela'] . "</nmdatela>";
$xml .= "	<idorigem>" . $glbvars['idorigem'] . "</idorigem>";
$xml .= "	<dtmvtolt>" . $glbvars['dtmvtolt'] . "</dtmvtolt>";
$xml .= "	<cddopcao>" . $cddopcao . "</cddopcao>";
$xml .= "	<nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "	<nrcpfcgc>" . $nrcpfcgc . "</nrcpfcgc>";
$xml .= "	<nrborder>" . $nrborder . "</nrborder>";
$xml .= "	<cdcmpchq>" . $cdcmpchq . "</cdcmpchq>";
$xml .= "	<cdbanchq>" . $cdbanchq . "</cdbanchq>";
$xml .= "	<cdagechq>" . $cdagechq . "</cdagechq>";
$xml .= "	<nrctachq>" . $nrctachq . "</nrctachq>";
$xml .= "	<nrcheque>" . $nrcheque . "</nrcheque>";
$xml .= "	<nmcheque>" . $nmcheque . "</nmcheque>";
$xml .= "	<auxnrcpf>" . $auxnrcpf . "</auxnrcpf>";
$xml .= "	<auxnmchq>" . $auxnmchq . "</auxnmchq>";
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

//----------------------------------------------------------------------------------------------------------------------------------	
// Controle de Erros
//----------------------------------------------------------------------------------------------------------------------------------
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    $nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
    if (!empty($nmdcampo)) {
        $retornoAposErro = $retornoAposErro . " $('#" . $nmdcampo . "','#frmOpcao').focus();";
    }
    exibirErro('error', $msgErro, 'Alerta - Aimaro', $retornoAposErro, false);
}

// Associado
if ($operacao == 'BA') {
    $associado = $xmlObjeto->roottag->tags[0]->tags[0]->tags; // dados associado
    echo "cNmprimtl.val('" . getByTagName($associado, 'nmprimtl') . "');";
    echo "controlaAssociado();";
} else if ($operacao == 'VC') {
    echo "hideMsgAguardo();";
    echo "showConfirmacao('Confirmar alteracao?','Confirma&ccedil;&atilde;o - Aimaro','manterRotina(\'AC\');','estadoInicial();','sim.gif','nao.gif');";
} else if ($operacao == 'AC') {
    echo "estadoInicial();";
}
?>