<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 06/12/2017
 * OBJETIVO     : Rotina para controlar as operações da tela GT0018
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
$tparrecd = (isset($_POST['tparrecd'])) ? $_POST['tparrecd'] : 0;
$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : '';
$cdempcon = (isset($_POST['cdempcon'])) ? $_POST['cdempcon'] : 0;
$cdsegmto = (isset($_POST['cdsegmto'])) ? $_POST['cdsegmto'] : 0;
$nmrescon = (isset($_POST['nmrescon'])) ? $_POST['nmrescon'] : '';
$nmextcon = (isset($_POST['nmextcon'])) ? $_POST['nmextcon'] : '';
$vltarint = (isset($_POST['vltarint'])) ? $_POST['vltarint'] : 0;
$vltartaa = (isset($_POST['vltartaa'])) ? $_POST['vltartaa'] : 0;
$vltarcxa = (isset($_POST['vltarcxa'])) ? $_POST['vltarcxa'] : 0;
$vltardeb = (isset($_POST['vltardeb'])) ? $_POST['vltardeb'] : 0;
$vltarcor = (isset($_POST['vltarcor'])) ? $_POST['vltarcor'] : 0;
$vltararq = (isset($_POST['vltararq'])) ? $_POST['vltararq'] : 0;
$nrrenorm = (isset($_POST['nrrenorm'])) ? $_POST['nrrenorm'] : 0;
$nrtolera = (isset($_POST['nrtolera'])) ? $_POST['nrtolera'] : 0;
$dsdianor = (isset($_POST['dsdianor'])) ? $_POST['dsdianor'] : '';
$dtcancel = (isset($_POST['dtcancel'])) ? $_POST['dtcancel'] : '';
$nrlayout = (isset($_POST['nrlayout'])) ? $_POST['nrlayout'] : '';


if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibeErroNew($msgError);
}  

if ( $cddopcao == 'A' ||
     $cddopcao == 'I' ||
     $cddopcao == 'E' ||
     $cddopcao == 'X' ) {
         
	$xml = new XmlMensageria();    
    $xml->add('cddopcao',$cddopcao);
    $xml->add('tparrecd',$tparrecd);
    $xml->add('cdempres',$cdempres);
    $xml->add('cdempcon',$cdempcon);
    $xml->add('cdsegmto',$cdsegmto);
    $xml->add('nmrescon',$nmrescon);
    $xml->add('nmextcon',$nmextcon);
    $xml->add('vltarint',$vltarint);
    $xml->add('vltartaa',$vltartaa);
    $xml->add('vltarcxa',$vltarcxa);
    $xml->add('vltardeb',$vltardeb);
    $xml->add('vltarcor',$vltarcor);
    $xml->add('vltararq',$vltararq);
    $xml->add('nrrenorm',$nrrenorm);
    $xml->add('nrtolera',$nrtolera);
    $xml->add('dsdianor',$dsdianor);
    $xml->add('dtcancel',$dtcancel);
    $xml->add('nrlayout',$nrlayout);
   
    $xmlResult = mensageria($xml, "TELA_GT0018", "GRAVAR_DADOS_GT0018", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }
    if ($cddopcao == 'A' || $cddopcao == 'I' || $cddopcao == 'E' || $cddopcao == 'X' ) { 
    
        $dsmensage = $xmlObj->roottag->tags[0]->tags[0]->cdata;
        echo 'showError("inform","'.$dsmensage.'","Notifica&ccedil;&atilde;o - Ayllos","hideMsgAguardo();estadoInicial();");';		
    }
}
function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}
