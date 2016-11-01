<?php

/*
 * FONTE        : busca_associado.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 24/08/2015
 * OBJETIVO     : Rotina para buscar dados associasdo na tela COBEMP
 * --------------
 * ALTERAÇÕES   : 
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
$procedure = 'busca_associado';

// Recebe a operação que está sendo realizada
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

if ($cddopcao == 'M') { // Manutencao de Contratos
    $retornoAposErro = 'focaCampoErro(\'nrdconta\', \'frmManutencao\');';
} else {
    $retornoAposErro = 'focaCampoErro(\'nrdconta\', \'frmContratos\');';
}

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], 'C')) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml dinâmico de acordo com a operação 
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0010.p</Bo>';
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
$xml .= '		<nrdconta>' . $nrdconta . '</nrdconta>';
$xml .= '	</Dados>';
$xml .= '</Root>';

$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

// Controle de Erros
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Ayllos', $retornoAposErro, false);
}

// Busca valores do XML
$associado = $xmlObjeto->roottag->tags[0]->tags[0]->tags; // dados associado
//		echo "cNmprimtl.val('".getByTagName($associado,'nmprimtl')."');";
		
//$cdagenci = $xmlObjeto->roottag->tags[0]->attributes["CDAGENCI"];
//$nmprimtl = $xmlObjeto->roottag->tags[0]->attributes["NMPRIMTL"];

if ($cddopcao == 'M') { // Manutencao
    echo "$('#nmprimtl','#frmManutencao').val('".getByTagName($associado,'nmprimtl')."');";
    echo "$('#nrctremp','#frmManutencao').focus();";
} else {
    echo "$('#nmprimtl','#frmContratos').val('".getByTagName($associado,'nmprimtl')."');";
    echo "$('#cdagenci','#frmContratos').val('".getByTagName($associado,'cdagenci')."');";
}