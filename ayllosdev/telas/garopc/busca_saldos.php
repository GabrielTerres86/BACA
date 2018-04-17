<?php
/*!
 * FONTE        : busca_saldos.php
 * CRIACAO      : Jaison Fernando
 * DATA CRIACAO : Novembro/2017
 * OBJETIVO     : Rotina para buscar os dados

   Alteracoes   : 
 */

    session_start();

    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../class/xmlfile.php');

    isPostMethod();

    // Guardo os parâmetos do POST em variáveis	
    $gar_nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
    $gar_tpctrato = (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : 0;
    $gar_nrctaliq = (isset($_POST['nrctaliq'])) ? $_POST['nrctaliq'] : 0;
    $gar_dsctrliq = (isset($_POST['dsctrliq'])) ? $_POST['dsctrliq'] : '';

    $xml  = "<Root>";
    $xml .= "  <Dados>";
    $xml .= "    <nrdconta>".$gar_nrdconta."</nrdconta>";
    $xml .= "    <tpctrato>".$gar_tpctrato."</tpctrato>";
    $xml .= "    <nrctaliq>".$gar_nrctaliq."</nrctaliq>";
    $xml .= "    <dsctrliq>".$gar_dsctrliq."</dsctrliq>";
    $xml .= "  </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_GAROPC", "GAROPC_BUSCA_SALDOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
        exibirErro('error',$msgErro,'Alerta - Ayllos','', false);
    }

    $registros = $xmlObject->roottag->tags[0];

    echo "$('#gar_ter_apli_sld', '#frmGAROPC').val('".getByTagName($registros->tags,'VLAPLTER')."');";
    echo "$('#gar_ter_poup_sld', '#frmGAROPC').val('".getByTagName($registros->tags,'VLPOUTER')."');";
?>