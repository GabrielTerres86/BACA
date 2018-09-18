<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 30/01/2012 
 * OBJETIVO     : Rotina para manter as operações da tela CUSTOD
 * --------------
 * ALTERAÇÕES   : 02/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 *                16/12/2016 - Alterações referentes ao projeto 300. (Reinert)
 *
 *				  06/02/2018 - Alterações referentes ao projeto 454.1 - Resgate de cheque em custodia. (Mateus Zimmermann - Mouts)
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

// Variáveis globais
$glb_cdcooper = (isset($glbvars['cdcooper'])) ? $glbvars['cdcooper'] : 0;
$glb_cdagenci = (isset($glbvars['cdagenci'])) ? $glbvars['cdagenci'] : 0;
$glb_nrdcaixa = (isset($glbvars['nrdcaixa'])) ? $glbvars['nrdcaixa'] : 0;
$glb_cdoperad = (isset($glbvars['cdoperad'])) ? $glbvars['cdoperad'] : '';
$glb_nmdatela = (isset($glbvars['nmdatela'])) ? $glbvars['nmdatela'] : '';
$glb_idorigem = (isset($glbvars['idorigem'])) ? $glbvars['idorigem'] : 0;
$glb_dtmvtolt = (isset($glbvars['dtmvtolt'])) ? $glbvars['dtmvtolt'] : '';

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
$dtmvtini = (isset($_POST['dtmvtini'])) ? $_POST['dtmvtini'] : '';
$dtmvtini = (validaData($dtmvtini)) ? $dtmvtini : '';
$dtmvtfim = (isset($_POST['dtmvtfim'])) ? $_POST['dtmvtfim'] : '';
$dtmvtfim = (validaData($dtmvtfim)) ? $dtmvtfim : '';
$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
$flgrelat = (isset($_POST['flgrelat'])) ? $_POST['flgrelat'] : '';
$nmdopcao = (isset($_POST['nmdopcao'])) ? $_POST['nmdopcao'] : '';
$nmdireto = (isset($_POST['nmdireto'])) ? $_POST['nmdireto'] : '';
$dsiduser = $nmdireto;
$dtlibera = (isset($_POST['dtlibera'])) ? $_POST['dtlibera'] : '';
$dtlibera = (validaData($dtlibera)) ? $dtlibera : '';
$dtmvtolx =(isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '';
$dtmvtolx = (validaData($dtmvtolx)) ? $dtmvtolx : '';
$nrdolote = (isset($_POST['nrdolote'])) ? $_POST['nrdolote'] : '';
$cdagelot = (isset($_POST['cdagelot'])) ? $_POST['cdagelot'] : '';
$protocolo = (!empty($_POST['protocolo'])) ? unserialize($_POST['protocolo']) : array();
$nrcpfcgc = (isset($nrcpfcgc)) ? $nrcpfcgc : 0;
$nmcheque = (isset($nmcheque)) ? $nmcheque : '';
$auxnrcpf = (isset($auxnrcpf)) ? $auxnrcpf : 0;
$auxnmchq = (isset($auxnmchq)) ? $auxnmchq : '';

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Aimaro', '', false);
}

if ($nrdconta == '0' && $cddopcao == 'I'){
	$retornoAposErro = "focaCampoErro('nrdconta','frmOpcao')";
	$msgErro = 'Informe o n&uacute;mero da conta.';
	exibirErro('error', $msgErro, 'Alerta - Aimaro', $retornoAposErro, false);
}

$BO = 'b1wgen0018.p';

switch ($operacao) {
    case 'BIA': $procedure = 'busca_informacoes_associado';
        break;
    case 'GLC': $procedure = 'gera-lotes-custodia';
        $BO = 'b1wgen0018i.p';
        break;
    case 'VLD': $procedure = 'valida_limites_desconto';
        $retornoAposErro = 'estadoInicial()';
        break;
}


// Monta o xml dinâmico de acordo com a operação 
$xml = "";
$xml .= "<Root>";
$xml .= "  <Cabecalho>";
$xml .= "	    <Bo>$BO</Bo>";
$xml .= "        <Proc>" . $procedure . "</Proc>";
$xml .= "  </Cabecalho>";
$xml .= "  <Dados>";
$xml .= "       <cdcooper>" . $glbvars['cdcooper'] . "</cdcooper>";
$xml .= "		<cdagenci>" . $glbvars['cdagenci'] . "</cdagenci>";
$xml .= "		<nrdcaixa>" . $glbvars['nrdcaixa'] . "</nrdcaixa>";
$xml .= "		<cdoperad>" . $glbvars['cdoperad'] . "</cdoperad>";
$xml .= "		<nmdatela>" . $glbvars['nmdatela'] . "</nmdatela>";
$xml .= "		<idorigem>" . $glbvars['idorigem'] . "</idorigem>";
$xml .= "		<dtmvtolt>" . $glbvars['dtmvtolt'] . "</dtmvtolt>";
$xml .= "		<cddopcao>" . $cddopcao . "</cddopcao>";
$xml .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "		<nrcpfcgc>" . $nrcpfcgc . "</nrcpfcgc>";
$xml .= "		<nrborder>" . $nrborder . "</nrborder>";
$xml .= "		<cdcmpchq>" . $cdcmpchq . "</cdcmpchq>";
$xml .= "		<cdbanchq>" . $cdbanchq . "</cdbanchq>";
$xml .= "		<cdagechq>" . $cdagechq . "</cdagechq>";
$xml .= "		<nrctachq>" . $nrctachq . "</nrctachq>";
$xml .= "		<nrcheque>" . $nrcheque . "</nrcheque>";
$xml .= "		<nmcheque>" . $nmcheque . "</nmcheque>";
$xml .= "		<auxnrcpf>" . $auxnrcpf . "</auxnrcpf>";
$xml .= "		<auxnmchq>" . $auxnmchq . "</auxnmchq>";
$xml .= "		<dtmvtini>" . $dtmvtini . "</dtmvtini>";
$xml .= "		<dtmvtfim>" . $dtmvtfim . "</dtmvtfim>";
$xml .= "		<cdagencx>" . $cdagenci . "</cdagencx>";
$xml .= "		<flgrelat>" . $flgrelat . "</flgrelat>";
$xml .= "		<nmdopcao>" . $nmdopcao . "</nmdopcao>";
$xml .= "		<dsiduser>" . $dsiduser . "</dsiduser>";
$xml .= "		<dtlibera>" . $dtlibera . "</dtlibera>";
$xml .= "		<dtmvtolx>" . $dtmvtolx . "</dtmvtolx>";
$xml .= "		<nrdolote>" . $nrdolote . "</nrdolote>";
$xml .= "		<cdagelot>" . $cdagelot . "</cdagelot>";
$xml .= xmlFilho($protocolo, 'Cheques', 'Itens');
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
        $retornoAposErro = $retornoAposErro . " focaCampoErro('" . $nmdcampo . "','frmOpcao');";
    }
    exibirErro('error', $msgErro, 'Alerta - Aimaro', $retornoAposErro, false);
}

// Associado
if ($operacao == 'BIA') {

    if ($cddopcao != 'S') {
        $associado = $xmlObjeto->roottag->tags[0]->tags[0]->tags; // dados associado
        echo "cNmprimtl.val('" . getByTagName($associado, 'nmprimtl') . "');";
		
        echo "inpessoa = " . getByTagName($associado, 'inpessoa') . ";";
        echo "idastcjt = " . getByTagName($associado, 'idastcjt') . ";";
    }

    echo "controlaAssociado();";
} else if ($operacao == 'AC') {
    echo "estadoInicial();";
} else if ($operacao == 'GLC') {
    $msgretur = $xmlObjeto->roottag->tags[0]->attributes['MSGRETUR'];
    exibirErro('inform', $msgretur, 'Alerta - Aimaro', 'estadoInicial();', false);
} else if ($operacao == 'VLD') {
    echo "hideMsgAguardo();";
    $dtlibera = $xmlObjeto->roottag->tags[0]->attributes['DTLIBERA'];
    echo "cDtlibera.habilitaCampo().val('" . $dtlibera . "');";
    echo "cDtlibera.select();";
} else if ($operacao == 'VDD') {
    echo "hideMsgAguardo();";
    echo "$('#'+frmOpcao+' fieldset:eq(1)').css({'display':'block'});";
    echo "cDtlibera.desabilitaCampo();";
    echo "cDtmvtolt.habilitaCampo().select();";
    echo "cCdagenci.habilitaCampo();";
    echo "cNrdolote.habilitaCampo();";
    echo "trocaBotao('Incluir');";
} else if ($operacao == 'VLE') {

    // Inicializa a cheque
    $p = array();

    // Pega o total de protocolo 
    $total = count($xmlObjeto->roottag->tags[0]->tags);

    // Armazena os cheques em custodia/desconto
    for ($i = 0; $i < $total; $i++) {
        $protocolo = $xmlObjeto->roottag->tags[0]->tags[$i]->tags;
        $p[$i]['indrelat'] = getByTagName($protocolo, 'indrelat');
        $p[$i]['dtmvtolt'] = getByTagName($protocolo, 'dtmvtolt');
        $p[$i]['cdagenci'] = getByTagName($protocolo, 'cdagenci');
        $p[$i]['nrdconta'] = getByTagName($protocolo, 'nrdconta');
        $p[$i]['nrborder'] = getByTagName($protocolo, 'nrborder');
        $p[$i]['nrdolote'] = getByTagName($protocolo, 'nrdolote');
        $p[$i]['qtchqcop'] = getByTagName($protocolo, 'qtchqcop');
        $p[$i]['qtchqmen'] = getByTagName($protocolo, 'qtchqmen');
        $p[$i]['qtchqmai'] = getByTagName($protocolo, 'qtchqmai');
        $p[$i]['qtchqtot'] = getByTagName($protocolo, 'qtchqtot');
        $p[$i]['vlchqcop'] = getByTagName($protocolo, 'vlchqcop');
        $p[$i]['vlchqmen'] = getByTagName($protocolo, 'vlchqmen');
        $p[$i]['vlchqmai'] = getByTagName($protocolo, 'vlchqmai');
        $p[$i]['vlchqtot'] = getByTagName($protocolo, 'vlchqtot');
        $p[$i]['nmoperad'] = getByTagName($protocolo, 'nmoperad');
        $p[$i]['dtlibera'] = getByTagName($protocolo, 'dtlibera');
        $p[$i]['cdbccxlt'] = getByTagName($protocolo, 'cdbccxlt');
        $p[$i]['qtcompln'] = getByTagName($protocolo, 'qtcompln');
        $p[$i]['vlcompdb'] = getByTagName($protocolo, 'vlcompdb');
    }

    if ($total > 0) {
        echo "protocolo='" . serialize($p) . "';";
    }

    $dsdolote = $xmlObjeto->roottag->tags[0]->attributes['DSDOLOTE'];
    exibirErro('inform', $dsdolote, 'Alerta - Aimaro', 'cDtmvtolt.select();', false);
    echo "$('#btConcluir', '#divTela #divBotoes').css({'display':''});";
}
?>
