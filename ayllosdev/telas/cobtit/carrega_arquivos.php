<?php
/* 
 * FONTE        : carrega_arquivos.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 14/06/2018
 * OBJETIVO     : Efetua busca dos arquivos
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

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <dtarqini>" . $dtarqini . "</dtarqini>";
$xml .= "   <dtarqfim>" . $dtarqfim . "</dtarqfim>";
$xml .= "   <nmarquiv>" . $nmarquiv . "</nmarquiv>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

// Chamada mensageria
$xmlResult = mensageria($xml, "COBTIT", "COBTIT_ARQUIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getClassXML($xmlResult);
$root = $xmlObj->roottag;
// Se ocorrer um erro, mostra crítica
if ($root->erro){
    exibirErro('error', $root->erro->registro->dscritic->cdata, 'Alerta - Ayllos', '', false);
    exit();
}

$registro = $root->dados->find("arq");
$qtregist = $root->dados->getAttribute("QTREGIST");

include('tab_arquivos.php');

?>