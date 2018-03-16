<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 08/03/2018
 * OBJETIVO     : Rotina para manter as operações da tela TITCTO
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

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

switch ($operacao) {
    case 'BA': $procedure = 'busca_informacoes_associado';
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
    exibirErro('error', $msgErro, 'Alerta - Ayllos', $retornoAposErro, false);
}

// Associado
if ($operacao == 'BA') {
    $associado = $xmlObjeto->roottag->tags[0]->tags[0]->tags; // dados associado
    echo "cNmprimtl.val('" . getByTagName($associado, 'nmprimtl') . "');";
    echo "controlaAssociado();";
}
?>