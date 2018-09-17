<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/03/2016 
 * OBJETIVO     : Rotina para controlar as operações da tela CONPRO
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


// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
$dtinicio = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '';
$dtafinal = (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : '';
$insitest = (isset($_POST['insitest'])) ? $_POST['insitest'] : '';
$insitefe = (isset($_POST['insitefe'])) ? $_POST['insitefe'] : '';
$insitapr = (isset($_POST['insitapr'])) ? $_POST['insitapr'] : '';
$tpproduto = (isset($_POST['tpproduto'])) ? $_POST['tpproduto'] : '9';

$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;



if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibeErroNew($msgError);
}

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
$xml .= "   <codigopa>" . $cdagenci . "</codigopa>";
$xml .= "   <dtinicio>" . $dtinicio . "</dtinicio>";
$xml .= "   <dtafinal>" . $dtafinal . "</dtafinal>";
$xml .= "   <insitest>" . $insitest . "</insitest>";
$xml .= "   <insitefe>" . $insitefe . "</insitefe>";
$xml .= "   <insitapr>" . $insitapr . "</insitapr>";
$xml .= "   <tpproduto>". $tpproduto. "</tpproduto>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONPRO", "CONPRO_CONSULTA", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);




if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibeErroNew($msgErro);
    exit();
}

$registros = $xmlObj->roottag->tags[0]->tags;
$qtregist = $xmlObj->roottag->tags[1]->cdata;


include('tab_resultado.php');


function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}
