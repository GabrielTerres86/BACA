<?php
/*!
 * FONTE        : busca_dados_garopc.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 16/11/2017
 * OBJETIVO     : Rotina para buscar os dados
 * ALTERACOES   : 
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Guardo os parâmetos do POST em variáveis	
    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
    $tpctrato = (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : 0;
    $nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;

    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <tpctrato>".$tpctrato."</tpctrato>";
    $xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_ADITIV", "ADITIV_DADOS_GAROPC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
        exibirErro('error',$msgErro,'Alerta - Aimaro','', false);
    }

    $registros = $xmlObject->roottag->tags[0];

    echo "$('#idcobert', '#frmCab').val('".getByTagName($registros->tags,'IDCOBOPE')."');";
    echo "$('#codlinha', '#frmCab').val('".getByTagName($registros->tags,'CODLINHA')."');";
    echo "$('#vlropera', '#frmCab').val('".getByTagName($registros->tags,'VLROPERA')."');";
    
    echo "abrirTelaGAROPC();";
?>