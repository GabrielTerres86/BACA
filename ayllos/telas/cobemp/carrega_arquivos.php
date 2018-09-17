<?php

/* 
 * FONTE        : carrega_arquivos.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 13/03/2017
 * OBJETIVO     : Efetua busca dos arquivos
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

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;

$dtarqini = (isset($_POST['dtarqini'])) ? $_POST['dtarqini'] : '';
$dtarqfim = (isset($_POST['dtarqfim'])) ? $_POST['dtarqfim'] : '';
$nmarquiv = (isset($_POST['nmarquiv'])) ? $_POST['nmarquiv'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
    exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial()',false);
}

$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <dtarqini>" . $dtarqini . "</dtarqini>";
$xml .= "   <dtarqfim>" . $dtarqfim . "</dtarqfim>";
$xml .= "   <nmarquiv>" . $nmarquiv . "</nmarquiv>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

// Chamada mensageria
$xmlResult = mensageria($xml, "TELA_COBEMP", "COBEMP_ARQUIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

// Tratamento de erro
if (strtoupper($xmlObject->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObject->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);
} else {
    $registro = $xmlObject->roottag->tags[0]->tags;
    $qtregist = $xmlObject->roottag->tags[1]->cdata;
}

include('tab_arquivos.php');
?>