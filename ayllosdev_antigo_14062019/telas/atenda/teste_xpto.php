<?php
ini_set('display_errors',1);
ini_set('display_startup_erros',1);
error_reporting(E_ALL);

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../class/xmlfile.php");


        $glbvars["cdcooper"] = 1;
        $glbvars["cdagenci"] = 0;
        $glbvars["nrdcaixa"] = 0;
        $glbvars["cdoperad"] = 1;
        $glbvars["dtmvtoan"] = '29/07/2015';
        $glbvars["dtmvtolt"] = '30/07/2015';
        $glbvars["dtmvtopr"] = '31/07/2015';
        $glbvars["nmdatela"] = 'ATENDA';
        $glbvars["inproces"] = 1;
        $glbvars["idorigem"] = 5;

        $nrdconta = ((isset($_GET['nrdconta'])) ? $_GET['nrdconta'] : 396);
        $nrdctitg = 0;
        $flgerlog = "no";

        echo "Inicio do teste XPTO <br />";
        echo '<b>Conta: ' . $nrdconta .'</b><br />';

        // Monta o xml de requisição
        $xmlGetDadosAtenda  = "";
        $xmlGetDadosAtenda .= "<Root>";
        $xmlGetDadosAtenda .= " <Cabecalho>";
        $xmlGetDadosAtenda .= "         <Bo>b1wgen0001.p</Bo>";
        $xmlGetDadosAtenda .= "         <Proc>carrega_dados_atenda</Proc>";
        $xmlGetDadosAtenda .= " </Cabecalho>";
        $xmlGetDadosAtenda .= " <Dados>";
        $xmlGetDadosAtenda .= "         <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
        $xmlGetDadosAtenda .= "         <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
        $xmlGetDadosAtenda .= "         <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
        $xmlGetDadosAtenda .= "         <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
        $xmlGetDadosAtenda .= "         <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
        $xmlGetDadosAtenda .= "         <dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
        $xmlGetDadosAtenda .= "         <dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";
        $xmlGetDadosAtenda .= "         <dtiniper>".date("d/m/Y")."</dtiniper>";
        $xmlGetDadosAtenda .= "         <dtfimper>".date("d/m/Y")."</dtfimper>";
        $xmlGetDadosAtenda .= "         <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
        $xmlGetDadosAtenda .= "         <idorigem>".$glbvars["idorigem"]."</idorigem>";
        $xmlGetDadosAtenda .= "         <nrdconta>".$nrdconta."</nrdconta>";
        $xmlGetDadosAtenda .= "         <idseqttl>1</idseqttl>";
        $xmlGetDadosAtenda .= "         <nrdctitg>".$nrdctitg."</nrdctitg>";
        $xmlGetDadosAtenda .= "         <inproces>".$glbvars["inproces"]."</inproces>";
        $xmlGetDadosAtenda .= "         <flgerlog>".$flgerlog."</flgerlog>";
        $xmlGetDadosAtenda .= " </Dados>";
        $xmlGetDadosAtenda .= "</Root>";

        // Executa script para envio do XML
        $xmlResult = getDataXML($xmlGetDadosAtenda);

        // Cria objeto para classe de tratamento de XML
        $xmlObjDadosAtenda = getObjectXML($xmlResult);

        // Se ocorrer um erro, mostra crítica
        if (strtoupper($xmlObjDadosAtenda->roottag->tags[0]->name) == "ERRO") {
                echo 'ERRO: carrega_dados_atenda: ' . $xmlObjDadosAtenda->roottag->tags[0]->tags[0]->tags[4]->cdata . '<br / >';
                exit();
        }

        echo 'carrega_dados_atenda: OK<br / >';

        // Monta o xml de requisi&ccedil;&atilde;o
        $xml  = "";
        $xml .= "<Root>";
        $xml .= "  <Cabecalho>";
        $xml .= "    <Bo>b1wgen0147.p</Bo>";
        $xml .= "    <Proc>dados_bndes</Proc>";
        $xml .= "  </Cabecalho>";
        $xml .= "  <Dados>";
        $xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
        $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "  </Dados>";
        $xml .= "</Root>";
        // Executa script para envio do XML
        $xmlResult = getDataXML($xml);
        // Cria objeto para classe de tratamento de XML
        $xmlGetBnd = getObjectXML($xmlResult);
        echo 'dados_bndes: OK<br / >';

        // Monta o xml de requisi&ccedil;&atilde;o
        $xmlConsorcio  = "";
        $xmlConsorcio .= "<Root>";
        $xmlConsorcio .= "  <Cabecalho>";
        $xmlConsorcio .= "    <Bo>b1wgen0162.p</Bo>";
        $xmlConsorcio .= "    <Proc>indicativo_consorcio</Proc>";
        $xmlConsorcio .= "  </Cabecalho>";
        $xmlConsorcio .= "  <Dados>";
        $xmlConsorcio .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
        $xmlConsorcio .= "    <nrdconta>".$nrdconta."</nrdconta>";
        $xmlConsorcio .= "  </Dados>";
        $xmlConsorcio .= "</Root>";
        // Executa script para envio do XML
        $xmlResult = getDataXML($xmlConsorcio);
        // Cria objeto para classe de tratamento de XML
        $xmlGetConsorcio = getObjectXML($xmlResult);
        echo 'indicativo_consorcio: OK<br / >';

?>
