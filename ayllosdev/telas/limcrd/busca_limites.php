<?php

/*!
	 * FONTE        : buscar_limites.php
	 * CRIAÇÃO      : Amasonas Borges Vieira Jr (Supero)
	 * DATA CRIAÇÃO : 19/02/2018
	 * OBJETIVO     : Arquivo para consultas em relação aos limites
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------      
	 */

session_cache_limiter("private");
session_start();

require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
require_once("../../class/xmlfile.php");
isPostMethod();

if ($_POST["action"] == "C") {
    $nr_page = isset($_POST["page"]) ? $_POST["page"] : 0;
    if (!is_numeric($nr_page))
        $nr_page = 3;

    $nr_page = 1;
    $endCount = $nr_page + 50;
    $admcrd = $_POST['admcrd'];
    $tplimcrd = $_POST['tplimcrd'];

    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
    $xml .= "   <cdadmcrd>" . $admcrd . "</cdadmcrd>";
    $xml .= "   <tplimcrd>" . $tplimcrd . "</tplimcrd>";
    $xml .= "   <only_cecred></only_cecred>";
    $xml .= "   <pagesize>50</pagesize>";
    $xml .= "   <pagenumber>" . $nr_page . "</pagenumber>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

   
    $xmlResult = mensageria($xml, "TELA_LIMCRD", "BUSCA_LIMCRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    
    $xmlObj = simplexml_load_string($xmlResult);
    $totalResult = $xmlObj->Dados->totalregistros;
    $totalPage = count($xmlObj->Dados->limite);
    
    $data = array();
    array_push($data, array("totalregistros" => strval($totalResult)));
    for ($i = 0; $i < $totalPage; $i++) {
        $obj = $xmlObj->Dados->limite[$i];
        $cdadmcrd = strval($obj->cdadmcrd[0]);
        $vllimite_minimo = number_format(strval($obj->vllimite_minimo),2,",",".");
        $vllimite_maximo = number_format(strval($obj->vllimite_maximo),2,",",".");
        $dsdias_debito = strval($obj->dsdias_debito);
        $tpcartao = strval($obj->tpcartao);
        $cdlimcrd = strval($obj->cdlimcrd);
        $nrctamae = strval($obj->nrctamae);

        array_push($data, array("CDADMCRD" => $cdadmcrd,
                                    "vllimite_minimo" => $vllimite_minimo,
                                    "vllimite_maximo" => $vllimite_maximo, 
                                    "dsdias_debito" => $dsdias_debito, 
                                    "cdlimcrd" => $cdlimcrd, 
                                    "nrctamae" => $nrctamae,
                                    "tpcartao" =>$tpcartao));
    }

    header('Content-Type: application/json');
    if ($nr_page == 0) {

    }
    echo json_encode($data);

} else {
    print_r($glbvars);
}


?>