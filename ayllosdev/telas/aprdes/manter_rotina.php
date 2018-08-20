<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 08/03/2018
 * OBJETIVO     : Rotina para manter as operações da tela TITCTO
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();



$operacao = $_POST["operacao"];
$nrdconta = $_POST["nrdconta"] ? $_POST["nrdconta"] : '';
$nrcpfcgc = $_POST["nrcpfcgc"] ? $_POST["nrcpfcgc"] : '';
$nrborder = $_POST["nrborder"] ? $_POST["nrborder"] : '';
$dtborini = $_POST["dtborini"] ? $_POST["dtborini"] : '';
$dtborfim = $_POST["dtborfim"] ? $_POST["dtborfim"] : '';

$chave =  $_POST["chave"] ? $_POST["chave"] : '';
$dsparecer =  $_POST["dsparecer"] ? $_POST["dsparecer"] : '';


if (!isset($operacao) || $operacao=='') {
    exibeErro(htmlentities('Opera&ccedil;&atilde;o n&atilde;o encontrada'));
}

switch ($operacao){
    case "BUSCAR_ASSOCIADO":
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"DSCT0003","DSCT0003_BUSCAR_ASSOCIADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            $json['status'] = 'sucesso';
            $json['nrdconta'] = utf8_encode($root->dados->associado->nrdconta->cdata);
            $json['nrcpfcgc'] = utf8_encode($root->dados->associado->nrcpfcgc->cdata);
            $json['nmprimtl'] = utf8_encode($root->dados->associado->nmprimtl->cdata);
        }        
        echo json_encode($json);
    break;
    case "BUSCAR_BORDEROS":
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <nrborder>".$nrborder."</nrborder>";
        $xml .= "   <dtborini>".$dtborini."</dtborini>";
        $xml .= "   <dtborfim>".$dtborfim."</dtborfim>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"TELA_APRDES","BUSCAR_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            $dados = $root->dados;
            $html = '<table>
                        <thead>
                            <tr>
                                <th>Border&ocirc;</th>
                                <th>Conta</th>
                                <th>Valor da Proposta</th>
                                <th>Produto de C&eacute;dito</th>
                                <th>Situa&ccedil;&atilde;o</th>
                                <th>Decis&atilde;o da An&aacute;lise</th>
                                <th>Operador</th>
                            </tr>           
                        </thead>
                        <tbody>';

            foreach ($dados->find("inf") as $b){
                $html .= "<tr onclick='selecionaBordero(\"".$b->nrdconta."\",\"".$b->nrborder."\");'>";
                $html .= "<td>".$b->nrborder."</td>";
                $html .= "<td>".$b->nrdconta."</td>";
                $html .= "<td>".formataMoeda($b->vlborder)."</td>";
                $html .= "<td>".$b->dsctrlim."</td>";
                $html .= "<td>".$b->dsinsbdt."</td>";
                $html .= "<td>".$b->dsinsapr."</td>";
                $html .= "<td>".$b->cdoperad."</td>";
                $html .= "</tr>";
            }
            $html .= "</tbody></table>";
            $json['status'] = 'sucesso';
            $json["html"] = utf8_encode($html);
        }        
        echo json_encode($json);
        exit;
    break;

    case "GRAVA_PARECER":
        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <nrborder>".$nrborder."</nrborder>";
        $xml .= "   <titulos>".$chave."</titulos>";
        $xml .= "   <dsparecer>".$dsparecer."</dsparecer>";
       
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml,"TELA_APRDES","INSERIR_PARECER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;

        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            $dados = $root->dados;
            $json['status'] = 'sucesso';
            $json["mensagem"] = utf8_encode($dados);
        }        
        echo json_encode($json);
        
    break;

    
    case "CONCLUI_CHECAGEM":
        $titulos = isset($_POST["titulos"]) ? $_POST["titulos"] : array();
        if(count($titulos)==0){
            exibeErro("Selecione ao menos um t&iacute;tulo");
            exit;
        }
        $titulos = implode($titulos,",");

        $xml = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <nrborder>".$nrborder."</nrborder>";
        $xml .= "   <titulos>".$titulos."</titulos>";
        $xml .= " </Dados>";
        $xml .= "</Root>";
        $xmlResult = mensageria($xml,"TELA_APRDES","CONCLUI_CHECAGEM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getClassXML($xmlResult);
        $root = $xmlObj->roottag;
        // Se ocorrer um erro, mostra crítica
        $json = array();
        if ($root->erro){
            $json['status'] = 'erro';
            $json['mensagem'] = utf8_encode($root->erro->registro->dscritic);
        }
        else{
            $dados = $root->dados;
            $json['status'] = 'sucesso';
            $json["mensagem"] = utf8_encode($dados);
        }        
        echo json_encode($json);

    exit;
}
?>