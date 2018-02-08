<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Leonardo de Freitas Oliveira - GFT
 * DATA CRIAÇÃO : 25/01/2018
 * OBJETIVO     : Rotina para controlar as operações da tela TAB052 
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

$tpcobran = (isset($_POST['tpcobran'])) ? $_POST['tpcobran'] : 0;
$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0;
$vlconsul = (isset($_POST['vlconsul'])) ? $_POST['vlconsul'] : 0;
$vlminsac = (isset($_POST['vlminsac'])) ? $_POST['vlminsac'] : 0;
$vlmaxsac = (isset($_POST['vlmaxsac'])) ? $_POST['vlmaxsac'] : 0;
$qtremcrt = (isset($_POST['qtremcrt'])) ? $_POST['qtremcrt'] : 0;
$qttitprt = (isset($_POST['qttitprt'])) ? $_POST['qttitprt'] : 0;
$qtrenova = (isset($_POST['qtrenova'])) ? $_POST['qtrenova'] : 0;
$qtdiavig = (isset($_POST['qtdiavig'])) ? $_POST['qtdiavig'] : 0;
$qtprzmin = (isset($_POST['qtprzmin'])) ? $_POST['qtprzmin'] : 0;
$qtprzmax = (isset($_POST['qtprzmax'])) ? $_POST['qtprzmax'] : 0;
// $cardbtit = (isset($_POST['cardbtit'])) ? $_POST['cardbtit'] : 0;
$cardbtit =  0;
$qtminfil = (isset($_POST['qtminfil'])) ? $_POST['qtminfil'] : 0;
$nrmespsq = (isset($_POST['nrmespsq'])) ? $_POST['nrmespsq'] : 0;
$pctitemi = (isset($_POST['pctitemi'])) ? $_POST['pctitemi'] : 0;
$pctolera = (isset($_POST['pctolera'])) ? $_POST['pctolera'] : 0;
$pcdmulta = (isset($_POST['pcdmulta'])) ? $_POST['pcdmulta'] : 0;
$pcnaopag = (isset($_POST['pcnaopag'])) ? $_POST['pcnaopag'] : 0;
$qtnaopag = (isset($_POST['qtnaopag'])) ? $_POST['qtnaopag'] : 0;
$qtprotes = (isset($_POST['qtprotes'])) ? $_POST['qtprotes'] : 0;

$vllimite_c = (isset($_POST['vllimite_c'])) ? $_POST['vllimite_c'] : 0;
$vlconsul_c = (isset($_POST['vlconsul_c'])) ? $_POST['vlconsul_c'] : 0;
$vlminsac_c = (isset($_POST['vlminsac_c'])) ? $_POST['vlminsac_c'] : 0;
$vlmaxsac_c = (isset($_POST['vlmaxsac_c'])) ? $_POST['vlmaxsac_c'] : 0;
$qtremcrt_c = (isset($_POST['qtremcrt_c'])) ? $_POST['qtremcrt_c'] : 0;
$qttitprt_c = (isset($_POST['qttitprt_c'])) ? $_POST['qttitprt_c'] : 0;
$qtrenova_c = (isset($_POST['qtrenova_c'])) ? $_POST['qtrenova_c'] : 0;
$qtdiavig_c = (isset($_POST['qtdiavig_c'])) ? $_POST['qtdiavig_c'] : 0;
$qtprzmin_c = (isset($_POST['qtprzmin_c'])) ? $_POST['qtprzmin_c'] : 0;
$qtprzmax_c = (isset($_POST['qtprzmax_c'])) ? $_POST['qtprzmax_c'] : 0;
$cardbtit_c = (isset($_POST['cardbtit_c'])) ? $_POST['cardbtit_c'] : 0;
$qtminfil_c = (isset($_POST['qtminfil_c'])) ? $_POST['qtminfil_c'] : 0;
$nrmespsq_c = (isset($_POST['nrmespsq_c'])) ? $_POST['nrmespsq_c'] : 0;
$pctitemi_c = (isset($_POST['pctitemi_c'])) ? $_POST['pctitemi_c'] : 0;
$pctolera_c = (isset($_POST['pctolera_c'])) ? $_POST['pctolera_c'] : 0;
$pcdmulta_c = (isset($_POST['pcdmulta_c'])) ? $_POST['pcdmulta_c'] : 0;
$pcnaopag_c = (isset($_POST['pcnaopag_c'])) ? $_POST['pcnaopag_c'] : 0;
$qtnaopag_c = (isset($_POST['qtnaopag_c'])) ? $_POST['qtnaopag_c'] : 0;
$qtprotes_c = (isset($_POST['qtprotes_c'])) ? $_POST['qtprotes_c'] : 0;

$cdopcao = '';

if ($cddopcao == 'AC') {
    $cdopcao = 'C';
} else {
    $cdopcao = $cddopcao;
}

if (($msgError = validaPermissao(
                    $glbvars['nmdatela'], 
                    $glbvars['nmrotina'], 
                    $cdopcao)) <> '') {
    exibeErroNew($msgError);
}


if ($cdopcao == 'C') {

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <tpcobran>".$tpcobran."</tpcobran>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TAB052","TAB052_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

} else {
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <tpcobran>".$tpcobran."</tpcobran>";
    $xml .= "   <vllimite>".converteFloat($vllimite)."</vllimite>";
    $xml .= "   <vllimite_c>".converteFloat($vllimite_c)."</vllimite_c>";

    $xml .= "   <vlconsul>". converteFloat($vlconsul)."</vlconsul>";
    $xml .= "   <vlconsul_c>". converteFloat($vlconsul_c)."</vlconsul_c>";

    $xml .= "   <vlmaxsac>". converteFloat($vlmaxsac)."</vlmaxsac>";
    $xml .= "   <vlmaxsac_c>". converteFloat($vlmaxsac_c)."</vlmaxsac_c>";

    $xml .= "   <vlminsac>". converteFloat($vlminsac)."</vlminsac>";
    $xml .= "   <vlminsac_c>". converteFloat($vlminsac_c)."</vlminsac_c>";

    $xml .= "   <qtremcrt>". $qtremcrt."</qtremcrt>";
    $xml .= "   <qtremcrt_c>". $qtremcrt_c."</qtremcrt_c>";

    $xml .= "   <qttitprt>". $qttitprt."</qttitprt>";
    $xml .= "   <qttitprt_c>". $qttitprt_c."</qttitprt_c>";

    $xml .= "   <qtrenova>". $qtrenova."</qtrenova>";
    $xml .= "   <qtrenova_c>". $qtrenova_c."</qtrenova_c>";

    $xml .= "   <qtdiavig>". $qtdiavig."</qtdiavig>";
    $xml .= "   <qtdiavig_c>". $qtdiavig_c."</qtdiavig_c>";

    $xml .= "   <qtprzmin>". $qtprzmin."</qtprzmin>";
    $xml .= "   <qtprzmin_c>". $qtprzmin_c."</qtprzmin_c>";

    $xml .= "   <qtprzmax>". $qtprzmax."</qtprzmax>";
    $xml .= "   <qtprzmax_c>". $qtprzmax_c."</qtprzmax_c>";

    $xml .= "   <qtminfil>". $qtminfil."</qtminfil>";
    $xml .= "   <qtminfil_c>". $qtminfil_c."</qtminfil_c>";

    $xml .= "   <nrmespsq>". $nrmespsq."</nrmespsq>";
    $xml .= "   <nrmespsq_c>". $nrmespsq_c."</nrmespsq_c>";

    $xml .= "   <pctitemi>". $pctitemi."</pctitemi>";
    $xml .= "   <pctitemi_c>". $pctitemi_c."</pctitemi_c>";

    $xml .= "   <pctolera>". $pctolera."</pctolera>";
    $xml .= "   <pctolera_c>". $pctolera_c."</pctolera_c>";

    $xml .= "   <pcdmulta>". $pcdmulta."</pcdmulta>";
    $xml .= "   <pcdmulta_c>". $pcdmulta_c."</pcdmulta_c>";
	
    $xml .= "   <cardbtit>". $cardbtit."</cardbtit>";
    $xml .= "   <cardbtit_c>". $cardbtit_c."</cardbtit_c>";

    $xml .= "   <pcnaopag>". $pcnaopag."</pcnaopag>";
    $xml .= "   <pcnaopag_c>". $pcnaopag_c."</pcnaopag_c>";

    $xml .= "   <qtnaopag>". $qtnaopag."</qtnaopag>";
    $xml .= "   <qtnaopag_c>". $qtnaopag_c."</qtnaopag_c>";

    $xml .= "   <qtprotes>". $qtprotes."</qtprotes>";
    $xml .= "   <qtprotes_c>". $qtprotes_c."</qtprotes_c>";

    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria(
            $xml,
            "TAB052",
            "TAB052_ALTERAR", 
            $glbvars["cdcooper"], 
            $glbvars["cdagenci"], 
            $glbvars["nrdcaixa"], 
            $glbvars["idorigem"], 
            $glbvars["cdoperad"], 
            "</Root>");
    $xmlObj = getObjectXML($xmlResult);
}


if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
       
    }
     $nmdcampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
    exibeErroNew($msgErro,$nmdcampo);
    exit();
}

$registros = $xmlObj->roottag->tags[0]->tags;

if ($cdopcao == 'C') {
    foreach ($registros as $r) {

	
        echo '$("#vllimite", "#frmTab052").val("' . getByTagName($r->tags, 'vllimite') . '");';
        echo '$("#vllimite_c", "#frmTab052").val("' . getByTagName($r->tags, 'vllimite_c') . '");';
        
        echo '$("#vlconsul", "#frmTab052").val("' . getByTagName($r->tags, 'vlconsul') . '");';
        echo '$("#vlconsul_c", "#frmTab052").val("' . getByTagName($r->tags, 'vlconsul_c') . '");';       
        
        echo '$("#vlminsac", "#frmTab052").val("' . getByTagName($r->tags, 'vlminsac') . '");';
        echo '$("#vlminsac_c", "#frmTab052").val("' . getByTagName($r->tags, 'vlminsac_c') . '");';

        echo '$("#vlmaxsac", "#frmTab052").val("' . getByTagName($r->tags, 'vlmaxsac') . '");';
        echo '$("#vlmaxsac_c", "#frmTab052").val("' . getByTagName($r->tags, 'vlmaxsac_c') . '");';

        echo '$("#qtremcrt", "#frmTab052").val("' . getByTagName($r->tags, 'qtremcrt') . '");';
        echo '$("#qtremcrt_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtremcrt_c') . '");';

        echo '$("#qttitprt", "#frmTab052").val("' . getByTagName($r->tags, 'qttitprt') . '");';
        echo '$("#qttitprt_c", "#frmTab052").val("' . getByTagName($r->tags, 'qttitprt_c') . '");';

        echo '$("#qtrenova", "#frmTab052").val("' . getByTagName($r->tags, 'qtrenova') . '");';
        echo '$("#qtrenova_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtrenova_c') . '");';

        echo '$("#qtdiavig", "#frmTab052").val("' . getByTagName($r->tags, 'qtdiavig') . '");';
        echo '$("#qtdiavig_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtdiavig_c') . '");';

        echo '$("#qtprzmin", "#frmTab052").val("' . getByTagName($r->tags, 'qtprzmin') . '");';
        echo '$("#qtprzmin_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtprzmin_c') . '");';

        echo '$("#qtprzmax", "#frmTab052").val("' . getByTagName($r->tags, 'qtprzmax') . '");';
        echo '$("#qtprzmax_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtprzmax_c') . '");';

        echo '$("#cardbtit", "#frmTab052").val("' . getByTagName($r->tags, 'cardbtit') . '");';
        echo '$("#cardbtit_c", "#frmTab052").val("' . getByTagName($r->tags, 'cardbtit_c') . '");';

        echo '$("#qtminfil", "#frmTab052").val("' . getByTagName($r->tags, 'qtminfil') . '");';
        echo '$("#qtminfil_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtminfil_c') . '");';

        echo '$("#nrmespsq", "#frmTab052").val("' . getByTagName($r->tags, 'nrmespsq') . '");';
        echo '$("#nrmespsq_c", "#frmTab052").val("' . getByTagName($r->tags, 'nrmespsq_c') . '");';

        echo '$("#pctitemi", "#frmTab052").val("' . getByTagName($r->tags, 'pctitemi') . '");';
        echo '$("#pctitemi_c", "#frmTab052").val("' . getByTagName($r->tags, 'pctitemi_c') . '");';

        echo '$("#pctolera", "#frmTab052").val("' . getByTagName($r->tags, 'pctolera') . '");';
        echo '$("#pctolera_c", "#frmTab052").val("' . getByTagName($r->tags, 'pctolera_c') . '");';

        echo '$("#pcdmulta", "#frmTab052").val("' . getByTagName($r->tags, 'pcdmulta') . '");';
        echo '$("#pcdmulta_c", "#frmTab052").val("' . getByTagName($r->tags, 'pcdmulta_c') . '");';

        echo '$("#pcnaopag", "#frmTab052").val("' . getByTagName($r->tags, 'pcnaopag') . '");';
        echo '$("#pcnaopag_c", "#frmTab052").val("' . getByTagName($r->tags, 'pcnaopag_c') . '");';

        echo '$("#qtnaopag", "#frmTab052").val("' . getByTagName($r->tags, 'qtnaopag') . '");';
        echo '$("#qtnaopag_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtnaopag_c') . '");';

        echo '$("#qtprotes", "#frmTab052").val("' . getByTagName($r->tags, 'qtprotes') . '");';
        echo '$("#qtprotes_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtprotes_c') . '");'; 
    }
}

if ($cddopcao == "A") {
    echo 'showError("inform","Par&acirc;metros alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
}

function exibeErroNew($msgErro,$nmdcampo) {
    echo 'hideMsgAguardo();';
    if ($nmdcampo <> ""){
        $nmdcampo = '$(\'#'.$nmdcampo.'\', \'#frmTab052\').focus();';
    }
    $msgErro = str_replace('"','',$msgErro);
    $msgErro = preg_replace('/\s/',' ',$msgErro);
    
    echo 'showError("error","' .$msgErro. '","Alerta - Ayllos","liberaCampos(); '.$nmdcampo.'");'; 
    exit();
}
