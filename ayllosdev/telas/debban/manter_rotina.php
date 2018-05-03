<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 06/12/2017
 * OBJETIVO     : Rotina para controlar as operações da tela CONVEN
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
$cdempcon = (isset($_POST['cdempcon'])) ? $_POST['cdempcon'] : 0;
$cdsegmto = (isset($_POST['cdsegmto'])) ? $_POST['cdsegmto'] : 0;
$nmrescon = (isset($_POST['nmrescon'])) ? $_POST['nmrescon'] : '';
$nmextcon = (isset($_POST['nmextcon'])) ? $_POST['nmextcon'] : '';
$cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0;
$nrdolote = (isset($_POST['nrdolote'])) ? $_POST['nrdolote'] : 0;
$flginter = (isset($_POST['flginter'])) ? $_POST['flginter'] : 0;
$tparrecd = (isset($_POST['tparrecd'])) ? $_POST['tparrecd'] : 0;
$flgaccec = (isset($_POST['flgaccec'])) ? $_POST['flgaccec'] : 0;
$flgacsic = (isset($_POST['flgacsic'])) ? $_POST['flgacsic'] : 0;
$flgacbcb = (isset($_POST['flgacbcb'])) ? $_POST['flgacbcb'] : 0;

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibeErroNew($msgError);
}  

if ( $cddopcao == 'A' ||
     $cddopcao == 'I' ||
     $cddopcao == 'E' ||
     $cddopcao == 'X' ) {
         
	$xml = new XmlMensageria();    
    $xml->add('cddopcao',$cddopcao);
    $xml->add('cdempcon',$cdempcon);
    $xml->add('cdsegmto',$cdsegmto);
    $xml->add('nmrescon',$nmrescon);
    $xml->add('nmextcon',$nmextcon);
    $xml->add('cdhistor',$cdhistor);
    $xml->add('nrdolote',$nrdolote);
    $xml->add('flginter',$flginter);
    $xml->add('tparrecd',$tparrecd);
    $xml->add('flgaccec',$flgaccec);
    $xml->add('flgacsic',$flgacsic);
    $xml->add('flgacbcb',$flgacbcb);
   
    $xmlResult = mensageria($xml, "TELA_CONVEN", "GRAVAR_DADOS_CONVEN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
