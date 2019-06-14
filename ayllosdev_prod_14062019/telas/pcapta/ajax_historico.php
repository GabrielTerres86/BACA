<?php

/* !
 * FONTE        : ajax_produtos.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 19/08/2014
 * OBJETIVO     : Ajax de consulta para tela PCAPTA - historico dos produtos
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

setVarSession('nmrotina', 'HISTORICO');

$retorno = array();
$erro = 'N';
$msgErro = '';
$flgopcao = (isset($_POST["flgopcao"])) ? trim($_POST["flgopcao"]) : '';


if ($flgopcao == 'C') {
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CHISPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $erro = 'S';
    } else {
        $registros = $xmlObj->roottag->tags;

        foreach ($registros as $registro) {
            $retorno[] = array(
                'cdhscacc' => $registro->tags[0]->cdata,
                'cdhsvrcc' => $registro->tags[1]->cdata,
                'cdhsraap' => $registro->tags[2]->cdata,
                'cdhsnrap' => $registro->tags[3]->cdata,
                'cdhsprap' => $registro->tags[4]->cdata,
                'cdhsrvap' => $registro->tags[5]->cdata,
                'cdhsrdap' => $registro->tags[6]->cdata,
                'cdhsirap' => $registro->tags[7]->cdata,
                'cdhsrgap' => $registro->tags[8]->cdata,
                'cdhsvtap' => $registro->tags[9]->cdata
            );
        }
    }
} else if ($flgopcao == 'CAR') { // carrega produtos

    $stracao = (isset($_POST["stracao"])) ? trim($_POST["stracao"]) : '';    
    //valida a acao de tela para o carregamento dos produtos
    $idsitpro = ( $stracao == 'A' ) ? 1 : 0; // 1-ativos, 0-todos, 2-inativos
    
    $htmlRetorno = '';
    
    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>0</cdprodut>";
    $xml .= "   <idsitpro>$idsitpro</idsitpro>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CPRODU", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        $erro = 'S';
    } else {
        $registros = $xmlObj->roottag->tags;
        foreach ($registros as $registro) {
            //$htmlRetorno .= '<option value="' . str_replace(PHP_EOL, "", $registro->tags[0]->cdata) . '">' . $registro->tags[1]->cdata . '</option>';
            $retorno[str_replace(PHP_EOL, "", $registro->tags[0]->cdata)] = $registro->tags[1]->cdata;
        }
    }
    
} else if ($flgopcao == 'VCH') { // valida codigo historico

    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["valor"]) && !isset($_POST["campo"])) {
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';
    } else {
        $campo = (isset($_POST["campo"])) ? trim($_POST["campo"]) : '';
        $valor = (isset($_POST["valor"])) ? $_POST["valor"] : '';
    }

    if ($erro == 'N') {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>V</cddopcao>";
        $xml .= "   <cdprodut>0</cdprodut>"; //zero para validar apenas o codigo do historico
        $xml .= "   <$campo>$valor</$campo>"; //campo de historico com seu valor
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANHISPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $registros = $xmlObj->roottag->tags;
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'valido' => $registro->tags[0]->cdata,
                    'indebcre' => $registro->tags[1]->cdata,
                    'estrutura' => $registro->tags[2]->cdata
                );
            }
        }
    }
    
    
} else if ($flgopcao == 'V') { // validar
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdprodut"])) {
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';
    } else {
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    }

    if ($erro == 'N') {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>V</cddopcao>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANHISPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $registros = $xmlObj->roottag->tags;
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'carteira' => $registro->tags[0]->cdata
                );
            }
        }
    }
} else if ($flgopcao == 'A') { //alterar
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdprodut"]) || !isset($_POST["cdhscacc"]) || !isset($_POST["cdhsvrcc"]) || !isset($_POST["cdhsraap"]) || !isset($_POST["cdhsnrap"]) || !isset($_POST["cdhsprap"]) || !isset($_POST["cdhsrvap"]) || !isset($_POST["cdhsrdap"]) || !isset($_POST["cdhsirap"]) || !isset($_POST["cdhsrgap"]) || !isset($_POST["cdhsvtap"])) {
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';
    } else {
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $cdhscacc = (isset($_POST["cdhscacc"])) ? $_POST["cdhscacc"] : 0;
        $cdhsvrcc = (isset($_POST["cdhsvrcc"])) ? $_POST["cdhsvrcc"] : 0;
        $cdhsraap = (isset($_POST["cdhsraap"])) ? $_POST["cdhsraap"] : 0;
        $cdhsnrap = (isset($_POST["cdhsnrap"])) ? $_POST["cdhsnrap"] : 0;
        $cdhsprap = (isset($_POST["cdhsprap"])) ? $_POST["cdhsprap"] : 0;
        $cdhsrvap = (isset($_POST["cdhsrvap"])) ? $_POST["cdhsrvap"] : 0;
        $cdhsrdap = (isset($_POST["cdhsrdap"])) ? $_POST["cdhsrdap"] : 0;
        $cdhsirap = (isset($_POST["cdhsirap"])) ? $_POST["cdhsirap"] : 0;
        $cdhsrgap = (isset($_POST["cdhsrgap"])) ? $_POST["cdhsrgap"] : 0;
        $cdhsvtap = (isset($_POST["cdhsvtap"])) ? $_POST["cdhsvtap"] : 0;

        if ($cdprodut <= 0 || $cdhscacc <= 0 || $cdhsvrcc <= 0 || $cdhsraap <= 0 || $cdhsnrap <= 0 || $cdhsprap <= 0 || $cdhsrvap <= 0 || $cdhsrdap <= 0 || $cdhsirap <= 0 || $cdhsrgap <= 0 || $cdhsvtap <= 0) {
            $msgErro = 'Produto inv&aacute;lido.';
            $erro = 'S';
        }
    }

    if ($erro == 'N') {

        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>A</cddopcao>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <cdhscacc>" . $cdhscacc . "</cdhscacc>";
        $xml .= "   <cdhsvrcc>" . $cdhsvrcc . "</cdhsvrcc>";
        $xml .= "   <cdhsraap>" . $cdhsraap . "</cdhsraap>";
        $xml .= "   <cdhsnrap>" . $cdhsnrap . "</cdhsnrap>";
        $xml .= "   <cdhsprap>" . $cdhsprap . "</cdhsprap>";
        $xml .= "   <cdhsrvap>" . $cdhsrvap . "</cdhsrvap>";
        $xml .= "   <cdhsrdap>" . $cdhsrdap . "</cdhsrdap>";
        $xml .= "   <cdhsirap>" . $cdhsirap . "</cdhsirap>";
        $xml .= "   <cdhsrgap>" . $cdhsrgap . "</cdhsrgap>";
        $xml .= "   <cdhsvtap>" . $cdhsvtap . "</cdhsvtap>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANHISPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $registros = $xmlObj->roottag->tags;

            foreach ($registros as $registro) {
                if ($registro->cdata == 'OK') {
                    $retorno[] = array(
                        'msg' => 'OK'
                    );
                } else {
                    $erro = 'S';
                    $retorno = array('msg' => 'Ocorreu um erro. Favor tentar novamente.');
                }
            }
        }
    }
}
echo json_encode(array('rows' => count($retorno), 'records' => $retorno, 'erro' => $erro, 'msg' => $msgErro));
?>