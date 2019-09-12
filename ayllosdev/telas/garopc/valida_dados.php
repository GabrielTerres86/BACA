<?php 
/*!
 * FONTE        : valida_dados.php
 * CRIACAO      : Mateus Zimmermann (Mouts)
 * DATA CRIACAO : Abril/2019
 * OBJETIVO     : Valida os dados
 
   Alteracoes   : 
 */

    session_start();

    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../class/xmlfile.php');

    isPostMethod();	

    // Guardo os parametos do POST em variaveis	
    $nmdatela     = (isset($_POST['nmdatela']))     ? $_POST['nmdatela']     : '';
    $tipaber      = (isset($_POST['tipaber']))      ? $_POST['tipaber']      : '';
    $nrdconta     = (isset($_POST['nrdconta']))     ? $_POST['nrdconta']     : 0;
    $nrctater     = (isset($_POST['nrctater']))     ? $_POST['nrctater']     : 0;
    $lintpctr     = (isset($_POST['lintpctr']))     ? $_POST['lintpctr']     : 0;
    $vlropera     = (isset($_POST['vlropera']))     ? $_POST['vlropera']     : 0;
    $permingr     = (isset($_POST['permingr']))     ? $_POST['permingr']     : 0;
    $inresper     = (isset($_POST['inresper']))     ? $_POST['inresper']     : 0;
    $diatrper     = (isset($_POST['diatrper']))     ? $_POST['diatrper']     : 0;
    $tpctrato     = (isset($_POST['tpctrato']))     ? $_POST['tpctrato']     : 0;
    $inaplpro     = (isset($_POST['inaplpro']))     ? $_POST['inaplpro']     : 0;
    $vlaplpro     = (isset($_POST['vlaplpro']))     ? $_POST['vlaplpro']     : 0;
    $inpoupro     = (isset($_POST['inpoupro']))     ? $_POST['inpoupro']     : 0;
    $vlpoupro     = (isset($_POST['vlpoupro']))     ? $_POST['vlpoupro']     : 0;
    $inresaut     = (isset($_POST['inresaut']))     ? $_POST['inresaut']     : 0;
    $inaplter     = (isset($_POST['inaplter']))     ? $_POST['inaplter']     : 0;
    $vlaplter     = (isset($_POST['vlaplter']))     ? $_POST['vlaplter']     : 0;
    $inpouter     = (isset($_POST['inpouter']))     ? $_POST['inpouter']     : 0;
    $vlpouter     = (isset($_POST['vlpouter']))     ? $_POST['vlpouter']     : 0;
    $ret_execfunc = (isset($_POST['ret_execfunc'])) ? $_POST['ret_execfunc'] : '';
    $err_execfunc = (isset($_POST['err_execfunc'])) ? $_POST['err_execfunc'] : '';

    $xml  = "";
    $xml .= "<Root>";
    $xml .= "  <Dados>";
    $xml .= "    <nmdatela>".$nmdatela."</nmdatela>";
    $xml .= "    <tipaber>".$tipaber."</tipaber>";
    $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "    <nrctater>".$nrctater."</nrctater>";
    $xml .= "    <lintpctr>".$lintpctr."</lintpctr>";
    $xml .= "    <vlropera>".converteFloat($vlropera)."</vlropera>";
    $xml .= "    <permingr>".converteFloat($permingr)."</permingr>";
    $xml .= "    <inresper>".$inresper."</inresper>";
    $xml .= "    <diatrper>".$diatrper."</diatrper>";
    $xml .= "    <tpctrato>".$tpctrato."</tpctrato>";
    $xml .= "    <inaplpro>".$inaplpro."</inaplpro>";
    $xml .= "    <vlaplpro>".converteFloat($vlaplpro)."</vlaplpro>";
    $xml .= "    <inpoupro>".$inpoupro."</inpoupro>";
    $xml .= "    <vlpoupro>".converteFloat($vlpoupro)."</vlpoupro>";
    $xml .= "    <inresaut>".$inresaut."</inresaut>";
    $xml .= "    <inaplter>".$inaplter."</inaplter>";
    $xml .= "    <vlaplter>".converteFloat($vlaplter)."</vlaplter>";
    $xml .= "    <inpouter>".$inpouter."</inpouter>";
    $xml .= "    <vlpouter>".converteFloat($vlpouter)."</vlpouter>";
    $xml .= "  </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_GAROPC", "GAROPC_VALIDA_DADOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
        //exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaFundo($(\'#divUsoGAROPC\'))', false);
        exibirErro('error',$msgErro,'Alerta - Ayllos', $err_execfunc, false);
    }

    $registros = $xmlObject->roottag->tags[0];

    echo "fechaRotina($('#divUsoGAROPC'));";

    echo $ret_execfunc;
?>