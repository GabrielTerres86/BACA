<?php

session_start();
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('session.cookie_domain', '.cecred.coop.br' );


date_default_timezone_set('America/Sao_Paulo');

// inicio
include 'assets/classes/sys.chamadas.class.php';
include 'assets/classes/sys.getxml.class.php';
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../class/xmlfile.php');


// verifica se veio requisição
if (isset($_POST['requisicao'])) {

    // pega a requisição
    $requisicao = $_POST['requisicao'];

    // verifica se é LOG
    if ($requisicao == 'log') {

        // executa a chamada do mensageria
        // echo 'sim, e log';

        $cdcooper            = $_SESSION['globalCDCOOPER'];
        $nrdconta            = $_SESSION['globalNRDCONTA'];
        $cdoperador          = $_SESSION['globalCDOPERAD'];
        $nrcontrato          = $_SESSION['globalNRPROPOSTA'];
        $tpproduto           = $_SESSION['globalTPPRODUTO'];
        $dhinicio_acesso     = $_SESSION['globalDHINICIO'];
        $dhfim_acesso        = date('d/m/Y H:i:s');

        if ($_SESSION['globalIDANALISE'] === -1) {
            $idanalise_contrato_acesso = null;
        } else {
            $idanalise_contrato_acesso = $_SESSION['globalIDANALISE'];
        }

        // Devemos validar o token do operador
        // Montar o xml de Requisicao
        $xml  = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <cdoperador>".$cdoperador."</cdoperador>";
        $xml .= "   <nrcontrato>".$nrcontrato."</nrcontrato>";
        $xml .= "   <tpproduto>".$tpproduto."</tpproduto>";
        $xml .= "   <dhinicio_acesso>".$dhinicio_acesso."</dhinicio_acesso>";
        $xml .= "   <dhfim_acesso>".$dhfim_acesso."</dhfim_acesso>";
        $xml .= "   <idanalise_contrato_acesso>".$idanalise_contrato_acesso."</idanalise_contrato_acesso>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria(
            $xml,
            "TELA_ANALISE_CREDITO",
            "INSERE_CONTROLE_ACESSO",
            $cdcooper,
            1,
            1,
            5,
            $cdoperador,
            "</Root>");

        $xmlData = simplexml_load_string($xmlResult);

        if(isset($xmlData->Erro)){
            
            $retornoTelaUnica['Erro'] = "Erro XML: ".$xmlData->Erro;

        }else{

            $_SESSION['globalIDANALISE'] = (string) $xmlData->idanalise_contrato_acesso;
        }

    }


}

?>