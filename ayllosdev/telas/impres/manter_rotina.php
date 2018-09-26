<?php 
/*!
* FONTE        : manter_rotina.php
* CRIAÇÃO      : Rogérius Militão (DB1)
* DATA CRIAÇÃO : 31/08/2011 
* OBJETIVO     : Rotina para manter as operações da tela IMPRES
* --------------
* ALTERAÇÕES   : 
*   10/09/2012 - Guilherme    (SUPERO) : Demonstrativo Aplicações: Campo data-Validacao
*   31/05/2013 - Daniel       (CECRED) : Fixado valor variavel flgtarif para yes. (Daniel)
*   08/08/2016 - Guilherme    (SUPERO) : M325 - Informe de Rendimentos Trimestral PJ
* -------------- 
*/
?> 

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Inicializa
$procedure = '';
$retornoAposErro = '';
$dtpadrao = ''; //date('d') . "/" . date('m') . "/" . date('Y');
// Recebe a operação que está sendo realizada
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : 0;
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0;
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$tpextrat = (isset($_POST['tpextrat'])) ? $_POST['tpextrat'] : '';
$tpmodelo = (isset($_POST['tpmodelo'])) ? $_POST['tpmodelo'] : '';
$dtrefere = (isset($_POST['dtrefere']) && $_POST['dtrefere'] <> '' ) ? $_POST['dtrefere'] : $dtpadrao;
$dtreffim = (isset($_POST['dtreffim']) && $_POST['dtreffim'] <> '' ) ? $_POST['dtreffim'] : $dtpadrao;
$flgtarif = $_POST['flgtarif'] == 'yes' ? 'yes' : 'no';
$nranoref = (isset($_POST['nranoref'])) ? $_POST['nranoref'] : '';
$inrelext = (isset($_POST['inrelext'])) ? $_POST['inrelext'] : '';
$inselext = (isset($_POST['inselext'])) ? $_POST['inselext'] : '';
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$tpinform = (isset($_POST['tpinform'])) ? $_POST['tpinform'] : 0;
$nrperiod = (isset($_POST['nrperiod'])) ? $_POST['nrperiod'] : 1;
$narplica = (isset($_POST['narplica'])) ? $_POST['narplica'] : 0;
$flgemiss = $_POST['flgemiss'] == 'yes' ? 'yes' : 'no';

$camposDc = (isset($_POST['camposDc'])) ? $_POST['camposDc'] : '';
$dadosDc = (isset($_POST['dadosDc'])) ? $_POST['dadosDc'] : '';

// Dependendo da operação, chamo uma procedure diferente
switch ($operacao) {
    // Consulta 
    case 'VD': $procedure = 'Valida_Dados';
        break;
    case 'VO': $procedure = 'Valida_Opcao';
        break;
    case 'GD': $procedure = 'Grava_Dados';
        break;
}

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Aimaro', '', false);
}

if ($tpextrat == '10') {
    $flgemiss = 'yes';
    $flgtarif = 'yes';
    $retornoAposErro = 'estadoCabecalho();';
}

/* Segundo Rodrigo sempre deve-se enviar TRUE */
$flgtarif = 'yes';

// Monta o xml dinâmico de acordo com a operação 
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0112.p</Bo>';
$xml .= '		<Proc>' . $procedure . '</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
$xml .= '		<cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
$xml .= '		<nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
$xml .= '		<cdoperad>' . $glbvars['cdoperad'] . '</cdoperad>';
$xml .= '		<nmdatela>' . $glbvars['nmdatela'] . '</nmdatela>';
$xml .= '		<idorigem>' . $glbvars['idorigem'] . '</idorigem>';
$xml .= '		<dtmvtolt>' . $glbvars['dtmvtolt'] . '</dtmvtolt>';
$xml .= '		<cddopcao>' . $cddopcao . '</cddopcao>';
$xml .= '		<nrdconta>' . $nrdconta . '</nrdconta>';
$xml .= '		<tpextrat>' . $tpextrat . '</tpextrat>';
$xml .= '		<tpmodelo>' . $tpmodelo . '</tpmodelo>';
$xml .= '		<dtrefere>' . $dtrefere . '</dtrefere>';
$xml .= '		<dtreffim>' . $dtreffim . '</dtreffim>';
$xml .= '		<flgtarif>' . $flgtarif . '</flgtarif>';
$xml .= '		<nranoref>' . $nranoref . '</nranoref>';
$xml .= '		<inselext>' . $inselext . '</inselext>';
$xml .= '		<nrctremp>' . $nrctremp . '</nrctremp>';
$xml .= '		<nraplica>' . $narplica . '</nraplica>';
$xml .= '		<flgemiss>' . $flgemiss . '</flgemiss>';
$xml .= '		<inrelext>' . $inrelext . '</inrelext>';
$xml .= '		<tpinform>' . $tpinform . '</tpinform>';
$xml .= '		<nrperiod>' . $nrperiod . '</nrperiod>';
$xml .= '		<intpextr>2</intpextr>';
$xml .= retornaXmlFilhos($camposDc, $dadosDc, 'Impres', 'Itens');
$xml .= '	</Dados>';
$xml .= '</Root>';

$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);
//----------------------------------------------------------------------------------------------------------------------------------	
// Controle de Erros
//----------------------------------------------------------------------------------------------------------------------------------

if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    $nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
    if (!empty($nmdcampo)) {
        $retornoAposErro = $retornoAposErro . " $('#" . $nmdcampo . "').focus();";
    }
    exibirErro('error', $msgErro, 'Alerta - Aimaro', $retornoAposErro, false);
}

$dsextrat = '';
$msgretor = '';

$dtrefere = !empty($xmlObjeto->roottag->tags[0]->attributes['DTREFERE']) ? $xmlObjeto->roottag->tags[0]->attributes['DTREFERE'] : $dtrefere;
$dtreffim = !empty($xmlObjeto->roottag->tags[0]->attributes['DTREFFIM']) ? $xmlObjeto->roottag->tags[0]->attributes['DTREFFIM'] : $dtreffim;

if ($operacao == 'VO') {
    echo "cDtrefere.val('" . $dtrefere . "');";
    echo "cDtreffim.val('" . $dtreffim . "');";
}
if (($cddopcao == 'I' and $operacao == 'VO')) {

    $dsextrat = $xmlObjeto->roottag->tags[0]->attributes['DSEXTRAT'];
    $msgretor = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];

    echo 'var aux 	= new Array();';
    echo 'var i 	= arrayImpres.length;';

    echo 'aux[\'nrdconta\'] = "' . $nrdconta . '";';
    echo 'aux[\'tpextrat\'] = "' . $tpextrat . '";';
    echo 'aux[\'tpmodelo\'] = "' . $tpmodelo . '";';
    echo 'aux[\'dsextrat\'] = "' . $dsextrat . '";';
    echo 'aux[\'dtrefere\'] = "' . $dtrefere . '";';
    echo 'aux[\'dtreffim\'] = "' . $dtreffim . '";';
    echo 'aux[\'flgtarif\'] = "' . $flgtarif . '";';
    echo 'aux[\'inrelext\'] = "' . $inrelext . '";';
    echo 'aux[\'inselext\'] = "' . $inselext . '";';
    echo 'aux[\'nrctremp\'] = "' . $nrctremp . '";';
    echo 'aux[\'nraplica\'] = "' . $narplica . '";';
    echo 'aux[\'nranoref\'] = "' . $nranoref . '";';
    echo 'aux[\'flgemiss\'] = "' . $flgemiss . '";';
    echo 'aux[\'inisenta\'] = "' . $flgtarif . '";';
    echo 'aux[\'tpinform\'] = "' . $tpinform . '";';
    echo 'aux[\'nrperiod\'] = "' . $nrperiod. '";';
    echo 'aux[\'insitext\'] = "1";';

    // recebe
    echo 'arrayImpres[i] = aux;';
}

if (!empty($msgretor)) {

    $sim = $flgemiss == "no" ? "manterRotina(\'GD\');" : "controlaLayout(\'" . $operacao . "\');";
    echo "showConfirmacao('" . $msgretor . "','Confirma&ccedil;&atilde;o - Aimaro','" . $sim . "','controlaLayout(\'NO\');','sim.gif','nao.gif');";
} else if ($operacao == 'VO' and $flgemiss == 'no') {
    echo "manterRotina('GD');";
} else {
    echo "controlaLayout('" . $operacao . "');";
}
?>