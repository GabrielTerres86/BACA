<?php
    
    /*
    * FONTE        : gravaContratosLiquidados.php
    * CRIAÇÃO      : Diego Simas (AMcom)
    * DATA CRIAÇÃO : 11/07/2018
    * OBJETIVO     : Grava contratos liquidados.
    */	
	
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');

	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
    $dsliquid = (isset($_POST['dsliquid'])) ? $_POST['dsliquid'] : 0;

    $xml  = "";
    $xml .= "<Root>";
    $xml .= "  <Dados>";
    $xml .= "    <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
    $xml .= "    <dsliquid>".$dsliquid."</dsliquid>";
    $xml .= "  </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_ATENDA_PRESTACOES", "GRAVAR_CONTRATOS_LIQUID", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        echo "<script>";
        echo "showError('inform','".$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata."','Notifica&ccedil;&atilde;o - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaRotina($(\'#divUsoGenerico\'),divRotina);');";		
        echo "</script>";
    }else{
        echo "<script>";
        echo "showError('inform','V&iacute;nculo gravado com sucesso.','Notifica&ccedil;&atilde;o - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaRotina($(\'#divUsoGenerico\'),divRotina);');";		
        echo "</script>";
    }	
?>
