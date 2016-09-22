<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann/Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 24/03/2016 
 * OBJETIVO     : Rotina para controlar as operações da tela TAB019 
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

$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0;
$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0;

$qtdiavig_c = (isset($_POST['qtdiavig_c'])) ? $_POST['qtdiavig_c'] : 0;

$qtprzmin = (isset($_POST['qtprzmin'])) ? $_POST['qtprzmin'] : 0;
$qtprzmax = (isset($_POST['qtprzmax'])) ? $_POST['qtprzmax'] : 0;

$txdmulta = (isset($_POST['txdmulta'])) ? $_POST['txdmulta'] : 0;
$vlconchq = (isset($_POST['vlconchq'])) ? $_POST['vlconchq'] : 0;
$vlmaxemi = (isset($_POST['vlmaxemi'])) ? $_POST['vlmaxemi'] : 0;

$pcchqloc = (isset($_POST['pcchqloc'])) ? $_POST['pcchqloc'] : 0;
$pcchqemi = (isset($_POST['pcchqemi'])) ? $_POST['pcchqemi'] : 0;
$qtdiasoc = (isset($_POST['qtdiasoc'])) ? $_POST['qtdiasoc'] : 0;
$qtdevchq = (isset($_POST['qtdevchq'])) ? $_POST['qtdevchq'] : 0;
$pctollim = (isset($_POST['pctollim'])) ? $_POST['pctollim'] : 0;

$vllimite_c = (isset($_POST['vllimite_c'])) ? $_POST['vllimite_c'] : 0;
$vlmaxemi_c = (isset($_POST['vlmaxemi_c'])) ? $_POST['vlmaxemi_c'] : 0;
$qtprzmax_c = (isset($_POST['qtprzmax_c'])) ? $_POST['qtprzmax_c'] : 0;
$pctollim_c = (isset($_POST['pctollim_c'])) ? $_POST['pctollim_c'] : 0;
$qtdiasli = (isset($_POST['qtdiasli'])) ? $_POST['qtdiasli'] : 0;
$horalimt = (isset($_POST['horalimt'])) ? $_POST['horalimt'] : 0;
$minlimit = (isset($_POST['minlimit'])) ? $_POST['minlimit'] : 0;
$qtdiasli_c = (isset($_POST['qtdiasli_c'])) ? $_POST['qtdiasli_c'] : 0;
$horalimt_c = (isset($_POST['horalimt_c'])) ? $_POST['horalimt_c'] : 0;
$minlimit_c = (isset($_POST['minlimit_c'])) ? $_POST['minlimit_c'] : 0;

$flemipar   = (isset($_POST['flemipar']))   ? $_POST['flemipar']   : 0;
$flemipar_c = (isset($_POST['flemipar_c'])) ? $_POST['flemipar_c'] : 0;
$przmxcmp   = (isset($_POST['przmxcmp']))   ? $_POST['przmxcmp']  : 0;
$przmxcmp_c = (isset($_POST['przmxcmp_c'])) ? $_POST['przmxcmp_c'] : 0;
$flpjzemi   = (isset($_POST['flpjzemi']))   ? $_POST['flpjzemi']   : 0;
$flpjzemi_c = (isset($_POST['flpjzemi_c'])) ? $_POST['flpjzemi_c'] : 0;
$flemisol   = (isset($_POST['flemisol']))   ? $_POST['flemisol']   : 0;
$flemisol_c = (isset($_POST['flemisol_c'])) ? $_POST['flemisol_c'] : 0;
$prcliqui   = (isset($_POST['prcliqui']))   ? $_POST['prcliqui']   : 0;
$prcliqui_c = (isset($_POST['prcliqui_c'])) ? $_POST['prcliqui_c'] : 0;
$qtmesliq   = (isset($_POST['qtmesliq']))   ? $_POST['qtmesliq']   : 0;
$qtmesliq_c = (isset($_POST['qtmesliq_c'])) ? $_POST['qtmesliq_c'] : 0;
$vlrenlim   = (isset($_POST['vlrenlim']))   ? $_POST['vlrenlim']   : 0;
$vlrenlim_c = (isset($_POST['vlrenlim_c'])) ? $_POST['vlrenlim_c'] : 0;
$qtmxrede   = (isset($_POST['qtmxrede']))   ? $_POST['qtmxrede']   : 0;
$qtmxrede_c = (isset($_POST['qtmxrede_c'])) ? $_POST['qtmxrede_c'] : 0;
$fldchqdv   = (isset($_POST['fldchqdv']))   ? $_POST['fldchqdv']   : 0;
$fldchqdv_c = (isset($_POST['fldchqdv_c'])) ? $_POST['fldchqdv_c'] : 0;
$vlmxassi   = (isset($_POST['vlmxassi']))   ? $_POST['vlmxassi']   : 0;
$vlmxassi_c = (isset($_POST['vlmxassi_c'])) ? $_POST['vlmxassi_c'] : 0;

$cdopcao = '';

if ($cddopcao == 'AC') {
    $cdopcao = 'C';
} else {
    $cdopcao = $cddopcao;
}

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cdopcao)) <> '') {
    exibeErroNew($msgError);
}

if ($cdopcao == 'C') {

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TAB019","TAB019_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
} else {

	
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
    $xml .= "   <vllimite>".str_replace(',','.', $vllimite)."</vllimite>";
    $xml .= "   <vllimite_c>".str_replace(',','.', $vllimite_c)."</vllimite_c>";
    $xml .= "   <qtdiavig>".$inpessoa."</qtdiavig>";
    $xml .= "   <qtdiavig_c>".$qtdiavig_c."</qtdiavig_c>";
    $xml .= "   <qtprzmin>".$qtprzmin."</qtprzmin>";
    $xml .= "   <qtprzmin_c>".$inpessoa."</qtprzmin_c>";
    $xml .= "   <qtprzmax>".$qtprzmax."</qtprzmax>";
    $xml .= "   <qtprzmax_c>".$qtprzmax_c."</qtprzmax_c>";
    $xml .= "   <txdmulta>".str_replace(',','.', $txdmulta)."</txdmulta>";
    $xml .= "   <txdmulta_c>".$inpessoa."</txdmulta_c>";
    $xml .= "   <vlconchq>".str_replace(',','.', $vlconchq)."</vlconchq>";
    $xml .= "   <vlconchq_c>".$inpessoa."</vlconchq_c>";
    $xml .= "   <vlmaxemi>".str_replace(',','.', $vlmaxemi)."</vlmaxemi>";
    $xml .= "   <vlmaxemi_c>".str_replace(',','.', $vlmaxemi_c)."</vlmaxemi_c>";
    $xml .= "   <pcchqloc>".$pcchqloc."</pcchqloc>";
    $xml .= "   <pcchqloc_c>".$inpessoa."</pcchqloc_c>";
    $xml .= "   <pcchqemi>".$pcchqemi."</pcchqemi>";
    $xml .= "   <pcchqemi_c>".$inpessoa."</pcchqemi_c>";
    $xml .= "   <qtdiasoc>".$qtdiasoc."</qtdiasoc>";
    $xml .= "   <qtdiasoc_c>".$inpessoa."</qtdiasoc_c>";
    $xml .= "   <qtdevchq>".$qtdevchq."</qtdevchq>";
    $xml .= "   <qtdevchq_c>".$inpessoa."</qtdevchq_c>";
    $xml .= "   <pctollim>".$pctollim."</pctollim>";
    $xml .= "   <pctollim_c>".$pctollim_c."</pctollim_c>";
    $xml .= "   <qtdiasli>".$qtdiasli."</qtdiasli>";
    $xml .= "   <qtdiasli_c>".$qtdiasli_c."</qtdiasli_c>";
    $xml .= "   <horalimt>".$horalimt."</horalimt>";
    $xml .= "   <horalimt_c>".$horalimt_c."</horalimt_c>";
    $xml .= "   <minlimit>".$minlimit."</minlimit>";
    $xml .= "   <minlimit_c>".$minlimit_c."</minlimit_c>";
    $xml .= "   <flemipar> ".$flemipar."</flemipar>";
    $xml .= "   <flemipar_c>". $flemipar_c. "</flemipar_c>";
    $xml .= "   <przmxcmp>".   $przmxcmp .  "</przmxcmp >";
    $xml .= "   <przmxcmp_c>". $przmxcmp_c. "</przmxcmp_c>";
    $xml .= "   <flpjzemi>".   $flpjzemi .  "</flpjzemi >";
    $xml .= "   <flpjzemi_c>". $flpjzemi_c. "</flpjzemi_c>";
    $xml .= "   <flemisol>".   $flemisol .  "</flemisol >";
    $xml .= "   <flemisol_c>". $flemisol_c. "</flemisol_c>";
    $xml .= "   <prcliqui>".   $prcliqui .  "</prcliqui >";
    $xml .= "   <prcliqui_c>". $prcliqui_c. "</prcliqui_c>";
    $xml .= "   <qtmesliq>".   $qtmesliq .  "</qtmesliq >";
    $xml .= "   <qtmesliq_c>". $qtmesliq_c. "</qtmesliq_c>";
    $xml .= "   <vlrenlim>".   $vlrenlim .  "</vlrenlim >";
    $xml .= "   <vlrenlim_c>". $vlrenlim_c. "</vlrenlim_c>";
    $xml .= "   <qtmxrede>".   $qtmxrede .  "</qtmxrede >";
    $xml .= "   <qtmxrede_c>". $qtmxrede_c. "</qtmxrede_c>";
    $xml .= "   <fldchqdv>".   $fldchqdv .  "</fldchqdv >";
    $xml .= "   <fldchqdv_c>". $fldchqdv_c. "</fldchqdv_c>";
    $xml .= "   <vlmxassi>".   str_replace(',','.', $vlmxassi).   "</vlmxassi >";
    $xml .= "   <vlmxassi_c>". str_replace(',','.', $vlmxassi_c). "</vlmxassi_c>";    
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TAB019","TAB019_ALTERAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		
		echo '$("#dsdepart", "#frmTab019").val("' . getByTagName($r->tags, 'dsdepart') . '");';
		
        echo '$("#vllimite", "#frmTab019").val("' . getByTagName($r->tags, 'vllimite') . '");';
        echo '$("#vllimite_c", "#frmTab019").val("' . getByTagName($r->tags, 'vllimite_c') . '");';
        echo '$("#qtdiavig", "#frmTab019").val("' . getByTagName($r->tags, 'qtdiavig') . '");';
        echo '$("#qtdiavig_c", "#frmTab019").val("' . getByTagName($r->tags, 'qtdiavig_c') . '");';       
        echo '$("#qtprzmin", "#frmTab019").val("' . getByTagName($r->tags, 'qtprzmin') . '");';
        echo '$("#qtprzmin_c", "#frmTab019").val("' . getByTagName($r->tags, 'qtprzmin_c') . '");';
		
        echo '$("#qtprzmax", "#frmTab019").val("' . getByTagName($r->tags, 'qtprzmax') . '");';
        echo '$("#qtprzmax_c", "#frmTab019").val("' . getByTagName($r->tags, 'qtprzmax_c') . '");';
        echo '$("#txdmulta", "#frmTab019").val("' . getByTagName($r->tags, 'txdmulta') . '");';
        echo '$("#txdmulta_c", "#frmTab019").val("' . getByTagName($r->tags, 'txdmulta_c') . '");';
        echo '$("#vlconchq", "#frmTab019").val("' . getByTagName($r->tags, 'vlconchq') . '");';
        echo '$("#vlconchq_c", "#frmTab019").val("' . getByTagName($r->tags, 'vlconchq_c') . '");';
        echo '$("#vlmaxemi", "#frmTab019").val("' . getByTagName($r->tags, 'vlmaxemi') . '");';
        echo '$("#vlmaxemi_c", "#frmTab019").val("' . getByTagName($r->tags, 'vlmaxemi_c') . '");';
		
		echo '$("#pcchqloc", "#frmTab019").val("' . getByTagName($r->tags, 'pcchqloc') . '");';
		echo '$("#pcchqloc_c", "#frmTab019").val("' . getByTagName($r->tags, 'pcchqloc_c') . '");';
		echo '$("#pcchqemi", "#frmTab019").val("' . getByTagName($r->tags, 'pcchqemi') . '");';
		echo '$("#pcchqemi_c", "#frmTab019").val("' . getByTagName($r->tags, 'pcchqemi_c') . '");';
		echo '$("#qtdiasoc", "#frmTab019").val("' . getByTagName($r->tags, 'qtdiasoc') . '");';
		echo '$("#qtdiasoc_c", "#frmTab019").val("' . getByTagName($r->tags, 'qtdiasoc_c') . '");';
		echo '$("#qtdevchq", "#frmTab019").val("' . getByTagName($r->tags, 'qtdevchq') . '");';
		echo '$("#qtdevchq_c", "#frmTab019").val("' . getByTagName($r->tags, 'qtdevchq_c') . '");';
		echo '$("#pctollim", "#frmTab019").val("' . getByTagName($r->tags, 'pctollim') . '");';
		echo '$("#pctollim_c", "#frmTab019").val("' . getByTagName($r->tags, 'pctollim_c') . '");';
		echo '$("#qtdiasli", "#frmTab019").val("' . getByTagName($r->tags, 'qtdiasli') . '");';
		echo '$("#qtdiasli_c", "#frmTab019").val("' . getByTagName($r->tags, 'qtdiasli_c') . '");';
		
		echo '$("#horalimt", "#frmTab019").val("' . getByTagName($r->tags, 'horalimt') . '");';
		echo '$("#minlimit", "#frmTab019").val("' . getByTagName($r->tags, 'minlimit') . '");';
		echo '$("#horalimt_c", "#frmTab019").val("' . getByTagName($r->tags, 'horalimt_c') . '");';
		echo '$("#minlimit_c", "#frmTab019").val("' . getByTagName($r->tags, 'minlimit_c') . '");';
        
        echo '$("#flemipar"  , "#frmTab019").val("' . getByTagName($r->tags, 'Flemipar') . '");';    
        echo '$("#flemipar_c", "#frmTab019").val("' . getByTagName($r->tags, 'Flemipar_c') . '");';
        echo '$("#przmxcmp"  , "#frmTab019").val("' . getByTagName($r->tags, 'Przmxcmp') . '");';    
        echo '$("#przmxcmp_c", "#frmTab019").val("' . getByTagName($r->tags, 'Przmxcmp_c') . '");';  
        echo '$("#flpjzemi"  , "#frmTab019").val("' . getByTagName($r->tags, 'Flpjzemi') . '");';    
        echo '$("#flpjzemi_c", "#frmTab019").val("' . getByTagName($r->tags, 'Flpjzemi_c') . '");';  
        echo '$("#flemisol"  , "#frmTab019").val("' . getByTagName($r->tags, 'Flemisol') . '");';    
        echo '$("#flemisol_c", "#frmTab019").val("' . getByTagName($r->tags, 'Flemisol_c') . '");';  
        echo '$("#prcliqui"  , "#frmTab019").val("' . getByTagName($r->tags, 'Prcliqui') . '");';    
        echo '$("#prcliqui_c", "#frmTab019").val("' . getByTagName($r->tags, 'Prcliqui_c') . '");';  
        echo '$("#qtmesliq"  , "#frmTab019").val("' . getByTagName($r->tags, 'Qtmesliq') . '");';    
        echo '$("#qtmesliq_c", "#frmTab019").val("' . getByTagName($r->tags, 'Qtmesliq_c') . '");';  
        echo '$("#vlrenlim"  , "#frmTab019").val("' . getByTagName($r->tags, 'Vlrenlim') . '");';    
        echo '$("#vlrenlim_c", "#frmTab019").val("' . getByTagName($r->tags, 'Vlrenlim_c') . '");';  
        echo '$("#qtmxrede"  , "#frmTab019").val("' . getByTagName($r->tags, 'Qtmxrede') . '");';    
        echo '$("#qtmxrede_c", "#frmTab019").val("' . getByTagName($r->tags, 'Qtmxrede_c') . '");';  
        echo '$("#fldchqdv"  , "#frmTab019").val("' . getByTagName($r->tags, 'Fldchqdv') . '");';    
        echo '$("#fldchqdv_c", "#frmTab019").val("' . getByTagName($r->tags, 'Fldchqdv_c') . '");';  
        echo '$("#vlmxassi"  , "#frmTab019").val("' . getByTagName($r->tags, 'Vlmxassi') . '");';    
        echo '$("#vlmxassi_c", "#frmTab019").val("' . getByTagName($r->tags, 'Vlmxassi_c') . '");';  
        
    }
}

if ($cddopcao == "A") {
    echo 'showError("inform","Parametros alterados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
}

function exibeErroNew($msgErro,$nmdcampo) {
    echo 'hideMsgAguardo();';
    if ($nmdcampo <> ""){
        $nmdcampo = '$(\'#'.$nmdcampo.'\', \'#frmTab019\').focus();';
    }
    $msgErro = str_replace('"','',$msgErro);
    $msgErro = preg_replace('/\s/',' ',$msgErro);
    
    echo 'showError("error","' .$msgErro. '","Alerta - Ayllos","liberaCampos(); '.$nmdcampo.'");'; 
    exit();
}
