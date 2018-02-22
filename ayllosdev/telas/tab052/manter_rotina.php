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
$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0;

$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0;
$vlconsul = (isset($_POST['vlconsul'])) ? $_POST['vlconsul'] : 0;
$vlminsac = (isset($_POST['vlminsac'])) ? $_POST['vlminsac'] : 0;
$qtremcrt = (isset($_POST['qtremcrt'])) ? $_POST['qtremcrt'] : 0;
$qttitprt = (isset($_POST['qttitprt'])) ? $_POST['qttitprt'] : 0;
$qtdiavig = (isset($_POST['qtdiavig'])) ? $_POST['qtdiavig'] : 0;
$qtprzmin = (isset($_POST['qtprzmin'])) ? $_POST['qtprzmin'] : 0;
$qtprzmax = (isset($_POST['qtprzmax'])) ? $_POST['qtprzmax'] : 0;
$cardbtit = (isset($_POST['cardbtit'])) ? $_POST['cardbtit'] : 0;
$qtminfil = (isset($_POST['qtminfil'])) ? $_POST['qtminfil'] : 0;
$nrmespsq = (isset($_POST['nrmespsq'])) ? $_POST['nrmespsq'] : 0;
$pctitemi = (isset($_POST['pctitemi'])) ? $_POST['pctitemi'] : 0;
$pctolera = (isset($_POST['pctolera'])) ? $_POST['pctolera'] : 0;
$pcdmulta = (isset($_POST['pcdmulta'])) ? $_POST['pcdmulta'] : 0;
$pcnaopag = (isset($_POST['pcnaopag'])) ? $_POST['pcnaopag'] : 0;
$qtnaopag = (isset($_POST['qtnaopag'])) ? $_POST['qtnaopag'] : 0;
$qtprotes = (isset($_POST['qtprotes'])) ? $_POST['qtprotes'] : 0;

$vlmxassi = (isset($_POST['vlmxassi'])) ? $_POST['vlmxassi'] : 0;
$qtmxtbib = (isset($_POST['qtmxtbib'])) ? $_POST['qtmxtbib'] : 0;
$flemipar = (isset($_POST['flemipar'])) ? $_POST['flemipar'] : 0;
$flpjzemi = (isset($_POST['flpjzemi'])) ? $_POST['flpjzemi'] : 0;
$flpdctcp = (isset($_POST['flpdctcp'])) ? $_POST['flpdctcp'] : 0;
$qttliqcp = (isset($_POST['qttliqcp'])) ? $_POST['qttliqcp'] : 0;
$vltliqcp = (isset($_POST['vltliqcp'])) ? $_POST['vltliqcp'] : 0;
$qtmintgc = (isset($_POST['qtmintgc'])) ? $_POST['qtmintgc'] : 0;
$vlmintgc = (isset($_POST['vlmintgc'])) ? $_POST['vlmintgc'] : 0;

//novo
$qtmitdcl = (isset($_POST['qtmitdcl'])) ? $_POST['qtmitdcl'] : 0;
$vlmintcl = (isset($_POST['vlmintcl'])) ? $_POST['vlmintcl'] : 0;
$qtmesliq = (isset($_POST['qtmesliq'])) ? $_POST['qtmesliq'] : 0;

$vlmxprat = (isset($_POST['vlmxprat'])) ? $_POST['vlmxprat'] : 0;
$pcmxctip = (isset($_POST['pcmxctip'])) ? $_POST['pcmxctip'] : 0;
$flcocpfp = (isset($_POST['flcocpfp'])) ? $_POST['flcocpfp'] : 0;
$qtmxdene = (isset($_POST['qtmxdene'])) ? $_POST['qtmxdene'] : 0;
$qtdiexbo = (isset($_POST['qtdiexbo'])) ? $_POST['qtdiexbo'] : 0; 
$qtmxtbay = (isset($_POST['qtmxtbay'])) ? $_POST['qtmxtbay'] : 0;

//$pctitpag = (isset($_POST['pctitpag'])) ? $_POST['pctitpag'] : 0;


/*_c*/
$vllimite_c = (isset($_POST['vllimite_c'])) ? $_POST['vllimite_c'] : 0;
$vlconsul_c = (isset($_POST['vlconsul_c'])) ? $_POST['vlconsul_c'] : 0;
$vlminsac_c = (isset($_POST['vlminsac_c'])) ? $_POST['vlminsac_c'] : 0;
$qtremcrt_c = (isset($_POST['qtremcrt_c'])) ? $_POST['qtremcrt_c'] : 0;
$qttitprt_c = (isset($_POST['qttitprt_c'])) ? $_POST['qttitprt_c'] : 0;
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

$vlmxassi_c = (isset($_POST['vlmxassi_c'])) ? $_POST['vlmxassi_c'] : 0;
$qtmxtbib_c = (isset($_POST['qtmxtbib_c'])) ? $_POST['qtmxtbib_c'] : 0;
$flemipar_c = (isset($_POST['flemipar_c'])) ? $_POST['flemipar_c'] : 0;
$flpjzemi_c = (isset($_POST['flpjzemi_c'])) ? $_POST['flpjzemi_c'] : 0;
$flpdctcp_c = (isset($_POST['flpdctcp_c'])) ? $_POST['flpdctcp_c'] : 0;
$qttliqcp_c = (isset($_POST['qttliqcp_c'])) ? $_POST['qttliqcp_c'] : 0;
$vltliqcp_c = (isset($_POST['vltliqcp_c'])) ? $_POST['vltliqcp_c'] : 0;
$qtmintgc_c = (isset($_POST['qtmintgc_c'])) ? $_POST['qtmintgc_c'] : 0;
$vlmintgc_c = (isset($_POST['vlmintgc_c'])) ? $_POST['vlmintgc_c'] : 0;
//novo
$qtmitdcl_c = (isset($_POST['qtmitdcl_c'])) ? $_POST['qtmitdcl_c'] : 0;
$vlmintcl_c = (isset($_POST['vlmintcl_c'])) ? $_POST['vlmintcl_c'] : 0;
$qtmesliq_c = (isset($_POST['qtmesliq_c'])) ? $_POST['qtmesliq_c'] : 0;

$vlmxprat_c = (isset($_POST['vlmxprat_c'])) ? $_POST['vlmxprat_c'] : 0;
$pcmxctip_c = (isset($_POST['pcmxctip_c'])) ? $_POST['pcmxctip_c'] : 0;
$flcocpfp_c = (isset($_POST['flcocpfp_c'])) ? $_POST['flcocpfp_c'] : 0;
$qtmxdene_c = (isset($_POST['qtmxdene_c'])) ? $_POST['qtmxdene_c'] : 0;
$qtdiexbo_c = (isset($_POST['qtdiexbo_c'])) ? $_POST['qtdiexbo_c'] : 0;

$qtmxtbay_c = (isset($_POST['qtmxtbay_c'])) ? $_POST['qtmxtbay_c'] : 0;

//$pctitpag_c = (isset($_POST['pctitpag_c'])) ? $_POST['pctitpag_c'] : 0;

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
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    //print_r($xml);

    $xmlResult = mensageria($xml,"TAB052","TAB052_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);


} else {
	$xml = "<Root>";
    $xml .= " <Dados>";

    $xml .= "   <tpcobran>".$tpcobran."</tpcobran>";
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";

    $xml .= "   <vllimite>".converteFloat($vllimite)."</vllimite>";
    $xml .= "   <vllimite_c>".converteFloat($vllimite_c)."</vllimite_c>";

    $xml .= "   <vlconsul>". converteFloat($vlconsul)."</vlconsul>";
    $xml .= "   <vlconsul_c>". converteFloat($vlconsul_c)."</vlconsul_c>";

    $xml .= "   <vlminsac>". converteFloat($vlminsac)."</vlminsac>";
    $xml .= "   <vlminsac_c>". converteFloat($vlminsac_c)."</vlminsac_c>";

    $xml .= "   <qtremcrt>". $qtremcrt."</qtremcrt>";
    $xml .= "   <qtremcrt_c>". $qtremcrt_c."</qtremcrt_c>";

    $xml .= "   <qttitprt>". $qttitprt."</qttitprt>";
    $xml .= "   <qttitprt_c>". $qttitprt_c."</qttitprt_c>";

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

    $xml .= "   <vlmxassi>". converteFloat($vlmxassi)."</vlmxassi>";
    $xml .= "   <vlmxassi_c>". converteFloat($vlmxassi_c)."</vlmxassi_c>";

    $xml .= "   <qtmxtbib>". $qtmxtbib."</qtmxtbib>";
    $xml .= "   <qtmxtbib_c>". $qtmxtbib_c."</qtmxtbib_c>";

    $xml .= "   <flemipar>". $flemipar."</flemipar>";
    $xml .= "   <flemipar_c>". $flemipar_c."</flemipar_c>";

    $xml .= "   <flpjzemi>". $flpjzemi."</flpjzemi>";
    $xml .= "   <flpjzemi_c>". $flpjzemi_c."</flpjzemi_c>";

    $xml .= "   <flpdctcp>". $flpdctcp."</flpdctcp>";
    $xml .= "   <flpdctcp_c>". $flpdctcp_c."</flpdctcp_c>";

    $xml .= "   <qttliqcp>". $qttliqcp."</qttliqcp>";
    $xml .= "   <qttliqcp_c>". $qttliqcp_c."</qttliqcp_c>";

    $xml .= "   <vltliqcp>". converteFloat($vltliqcp)."</vltliqcp>";
    $xml .= "   <vltliqcp_c>". converteFloat($vltliqcp_c)."</vltliqcp_c>";

    $xml .= "   <qtmintgc>". $qtmintgc."</qtmintgc>";
    $xml .= "   <qtmintgc_c>". $qtmintgc_c."</qtmintgc_c>";

    $xml .= "   <vlmintgc>". converteFloat($vlmintgc)."</vlmintgc>";
    $xml .= "   <vlmintgc_c>". converteFloat($vlmintgc_c)."</vlmintgc_c>";

    //novo 
    $xml .= "   <qtmitdcl>". $qtmitdcl."</qtmitdcl>";
    $xml .= "   <qtmitdcl_c>". $qtmitdcl_c."</qtmitdcl_c>";

    $xml .= "   <vlmintcl>". converteFloat($vlmintcl)."</vlmintcl>";
    $xml .= "   <vlmintcl_c>". converteFloat($vlmintcl_c)."</vlmintcl_c>";
    // fim novo


    $xml .= "   <qtmesliq>". $qtmesliq."</qtmesliq>";
    $xml .= "   <qtmesliq_c>". $qtmesliq_c."</qtmesliq_c>";

    $xml .= "   <vlmxprat>". converteFloat($vlmxprat)."</vlmxprat>";
    $xml .= "   <vlmxprat_c>". converteFloat($vlmxprat_c)."</vlmxprat_c>";

    $xml .= "   <pcmxctip>". converteFloat($pcmxctip)."</pcmxctip>";
    $xml .= "   <pcmxctip_c>". converteFloat($pcmxctip_c)."</pcmxctip_c>";


    $xml .= "   <qtmxdene>". $qtmxdene."</qtmxdene>";
    $xml .= "   <qtmxdene_c>". $qtmxdene_c."</qtmxdene_c>";

    $xml .= "   <qtdiexbo>". $qtdiexbo."</qtdiexbo>";
    $xml .= "   <qtdiexbo_c>". $qtdiexbo_c."</qtdiexbo_c>";

    $xml .= "   <qtmxtbay>".$qtmxtbay."</qtmxtbay>";
    $xml .= "   <qtmxtbay_c>".$qtmxtbay_c."</qtmxtbay_c>";
    

    /* inicio campos excluidos */

    $xml .= "   <pctitpag>0</pctitpag>";
    $xml .= "   <pctitpag_c>0</pctitpag_c>";

    $xml .= "   <flcocpfp>0</flcocpfp>";
    $xml .= "   <flcocpfp_c>0</flcocpfp_c>";

    $xml .= "   <vlmaxsac>0</vlmaxsac>";
    $xml .= "   <vlmaxsac_c>0</vlmaxsac_c>";

    $xml .= "   <qtrenova>0</qtrenova>";
    $xml .= "   <qtrenova_c>0</qtrenova_c>";
    

    
     /*  fim campos excluidos */
    

    $xml .= " </Dados>";
    $xml .= "</Root>";

    //print_r($xml);


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

        echo '$("#cddepart", "#frmTab052").val("' . getByTagName($r->tags, 'dsdepart') . '");';
	
        echo '$("#vllimite", "#frmTab052").val("' . getByTagName($r->tags, 'vllimite') . '");';
        echo '$("#vllimite_c", "#frmTab052").val("' . getByTagName($r->tags, 'vllimite_c') . '");';
        
        echo '$("#vlconsul", "#frmTab052").val("' . getByTagName($r->tags, 'vlconsul') . '");';
        echo '$("#vlconsul_c", "#frmTab052").val("' . getByTagName($r->tags, 'vlconsul_c') . '");';       
        
        echo '$("#vlminsac", "#frmTab052").val("' . getByTagName($r->tags, 'vlminsac') . '");';
        echo '$("#vlminsac_c", "#frmTab052").val("' . getByTagName($r->tags, 'vlminsac_c') . '");';
    
        echo '$("#qtremcrt", "#frmTab052").val("' . getByTagName($r->tags, 'qtremcrt') . '");';
        echo '$("#qtremcrt_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtremcrt_c') . '");';

        echo '$("#qttitprt", "#frmTab052").val("' . getByTagName($r->tags, 'qttitprt') . '");';
        echo '$("#qttitprt_c", "#frmTab052").val("' . getByTagName($r->tags, 'qttitprt_c') . '");';

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

        echo '$("#vlmxassi", "#frmTab052").val("' . getByTagName($r->tags, 'vlmxassi') . '");';
        echo '$("#vlmxassi_c", "#frmTab052").val("' . getByTagName($r->tags, 'vlmxassi_c') . '");'; 
		
        echo '$("#flemipar", "#frmTab052").val("' . getByTagName($r->tags, 'flemipar') . '");';
        echo '$("#flemipar_c", "#frmTab052").val("' . getByTagName($r->tags, 'flemipar_c') . '");'; 
		
		echo '$("#flpjzemi", "#frmTab052").val("' . getByTagName($r->tags, 'flpjzemi') . '");';
        echo '$("#flpjzemi_c", "#frmTab052").val("' . getByTagName($r->tags, 'flpjzemi_c') . '");'; 
		
		echo '$("#flpdctcp", "#frmTab052").val("' . getByTagName($r->tags, 'flpdctcp') . '");';
        echo '$("#flpdctcp_c", "#frmTab052").val("' . getByTagName($r->tags, 'flpdctcp_c') . '");'; 
		
		echo '$("#qttliqcp", "#frmTab052").val("' . getByTagName($r->tags, 'qttliqcp') . '");';
        echo '$("#qttliqcp_c", "#frmTab052").val("' . getByTagName($r->tags, 'qttliqcp_c') . '");'; 
		
		echo '$("#vltliqcp", "#frmTab052").val("' . getByTagName($r->tags, 'vltliqcp') . '");';
        echo '$("#vltliqcp_c", "#frmTab052").val("' . getByTagName($r->tags, 'vltliqcp_c') . '");'; 
			
		echo '$("#qtmintgc", "#frmTab052").val("' . getByTagName($r->tags, 'qtmintgc') . '");';
        echo '$("#qtmintgc_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtmintgc_c') . '");'; 
		
		echo '$("#vlmintgc", "#frmTab052").val("' . getByTagName($r->tags, 'vlmintgc') . '");';
        echo '$("#vlmintgc_c", "#frmTab052").val("' . getByTagName($r->tags, 'vlmintgc_c') . '");'; 


        //novo
        echo '$("#qtmitdcl", "#frmTab052").val("' . getByTagName($r->tags, 'qtmitdcl') . '");';
        echo '$("#qtmitdcl_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtmitdcl_c') . '");'; 

        echo '$("#vlmintcl", "#frmTab052").val("' . getByTagName($r->tags, 'vlmintcl') . '");';
        echo '$("#vlmintcl_c", "#frmTab052").val("' . getByTagName($r->tags, 'vlmintcl_c') . '");'; 
        //fim novo
        
		
		echo '$("#qtmesliq", "#frmTab052").val("' . getByTagName($r->tags, 'qtmesliq') . '");';
        echo '$("#qtmesliq_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtmesliq_c') . '");'; 
		
		echo '$("#vlmxprat", "#frmTab052").val("' . getByTagName($r->tags, 'vlmxprat') . '");';
        echo '$("#vlmxprat_c", "#frmTab052").val("' . getByTagName($r->tags, 'vlmxprat_c') . '");'; 
		
		echo '$("#pcmxctip", "#frmTab052").val("' . getByTagName($r->tags, 'pcmxctip') . '");';
        echo '$("#pcmxctip_c", "#frmTab052").val("' . getByTagName($r->tags, 'pcmxctip_c') . '");'; 
		
		echo '$("#flcocpfp", "#frmTab052").val("' . getByTagName($r->tags, 'flcocpfp') . '");';
        echo '$("#flcocpfp_c", "#frmTab052").val("' . getByTagName($r->tags, 'flcocpfp_c') . '");'; 
		
		echo '$("#qtmxdene", "#frmTab052").val("' . getByTagName($r->tags, 'qtmxdene') . '");';
        echo '$("#qtmxdene_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtmxdene_c') . '");'; 
		
		echo '$("#qtdiexbo", "#frmTab052").val("' . getByTagName($r->tags, 'qtdiexbo') . '");';
        echo '$("#qtdiexbo_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtdiexbo_c') . '");'; 
		
		echo '$("#qtmxtbib", "#frmTab052").val("' . getByTagName($r->tags, 'qtmxtbib') . '");';
        echo '$("#qtmxtbib_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtmxtbib_c') . '");'; 

        echo '$("#qtmxtbay", "#frmTab052").val("' . getByTagName($r->tags, 'qtmxtbay') . '");';
        echo '$("#qtmxtbay_c", "#frmTab052").val("' . getByTagName($r->tags, 'qtmxtbay_c') . '");'; 

        //echo '$("#pctitpag", "#frmTab052").val("' . getByTagName($r->tags, 'pctitpag') . '");';
        //echo '$("#pctitpag_c", "#frmTab052").val("' . getByTagName($r->tags, 'pctitpag_c') . '");'; 

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
