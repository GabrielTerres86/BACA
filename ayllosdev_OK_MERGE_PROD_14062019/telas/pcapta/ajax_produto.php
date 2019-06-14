<?php

/* !
 * FONTE        : ajax_produtos.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 22/07/2014
 * OBJETIVO     : Ajax de consulta para tela PCAPTA - produtos de captacao
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

setVarSession('nmrotina','PRODUTOS');

$retorno = array();
$erro = 'N';
$msgErro = '';
$flgopcao = (isset($_POST["flgopcao"])) ? trim($_POST["flgopcao"]) : '';

if  ( $flgopcao == 'C' ) {
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= "   <idsitpro>0</idsitpro>";            
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CPRODU", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $erro = 'S';
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdprodut > 0 ) {
        
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'cdprodut' => $registro->tags[0]->cdata,
                    'nmprodut' => $registro->tags[1]->cdata,
                    'idsitpro' => $registro->tags[2]->cdata,
                    'cddindex' => $registro->tags[3]->cdata,
                    'idtippro' => $registro->tags[4]->cdata,
                    'idtxfixa' => $registro->tags[5]->cdata,
                    'idacumul' => $registro->tags[6]->cdata,
                    'nommitra' => $registro->tags[7]->cdata,
                    'indplano' => $registro->tags[8]->cdata
                );
            }
            
        } else {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'cdprodut' => $registro->tags[0]->cdata,
                    'nmprodut' => $registro->tags[1]->cdata
                );
            }            
        }
    }
    
} else if  ( $flgopcao == 'V' ) { // validar
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["nmprodut"]) || !isset($_POST["idsitpro"]) || !isset($_POST["cddindex"])
        || !isset($_POST["idtippro"]) || !isset($_POST["idtxfixa"]) || !isset($_POST["idacumul"]) || !isset($_POST["indplano"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $nmprodut = (isset($_POST["nmprodut"])) ? $_POST["nmprodut"] : '';
        $idsitpro = (isset($_POST["idsitpro"])) ? $_POST["idsitpro"] : 0;
        $cddindex = (isset($_POST["cddindex"])) ? $_POST["cddindex"] : 0;
        $idtippro = (isset($_POST["idtippro"])) ? $_POST["idtippro"] : 0;
        $idtxfixa = (isset($_POST["idtxfixa"])) ? $_POST["idtxfixa"] : 0;
        $idacumul = (isset($_POST["idacumul"])) ? $_POST["idacumul"] : 0;
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;        
        $indplano = (isset($_POST["indplano"])) ? $_POST["indplano"] : 0;       
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>V</cddopcao>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <nmprodut>" . $nmprodut . "</nmprodut>";
        $xml .= "   <idsitpro>" . $idsitpro . "</idsitpro>";
        $xml .= "   <cddindex>" . $cddindex . "</cddindex>";
        $xml .= "   <idtippro>" . $idtippro . "</idtippro>";
        $xml .= "   <idtxfixa>" . $idtxfixa . "</idtxfixa>";
        $xml .= "   <idacumul>" . $idacumul . "</idacumul>";
        $xml .= "   <nommitra>" . $nommitra . "</nommitra>";
        $xml .= "   <indplano>" . $indplano . "</indplano>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $registros = $xmlObj->roottag->tags;
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'carteira'    => $registro->tags[0]->cdata,
                    'modalidade'  => $registro->tags[1]->cdata,                
                    'nome'        => $registro->tags[2]->cdata,                
                    'parametro'   => $registro->tags[3]->cdata                
                );
            }
        }
    }
} else if  ( $flgopcao == 'I' ) { //inserir
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["nmprodut"]) || !isset($_POST["idsitpro"]) || !isset($_POST["cddindex"])
        || !isset($_POST["idtippro"]) || !isset($_POST["idtxfixa"]) || !isset($_POST["idacumul"]) || !isset($_POST["indplano"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';        
    } else {
        $nmprodut = (isset($_POST["nmprodut"])) ? $_POST["nmprodut"] : '';
        $idsitpro = (isset($_POST["idsitpro"])) ? $_POST["idsitpro"] : 0;
        $cddindex = (isset($_POST["cddindex"])) ? $_POST["cddindex"] : 0;
        $idtippro = (isset($_POST["idtippro"])) ? $_POST["idtippro"] : 0;
        $idtxfixa = (isset($_POST["idtxfixa"])) ? $_POST["idtxfixa"] : 0;
        $idacumul = (isset($_POST["idacumul"])) ? $_POST["idacumul"] : 0;
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $indplano = (isset($_POST["indplano"])) ? $_POST["indplano"] : 0;   

        if (trim($nmprodut) == '') {
            $msgErro = 'Produto inv&aacute;lido.';
            $erro = 'S';                           
        }
    }

    if ( $erro == 'N' ) {        
        if ( $cdprodut > 0 ) {
            $flgopcao = 'A';
        }
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>" . $flgopcao . "</cddopcao>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <nmprodut>" . $nmprodut . "</nmprodut>";
        $xml .= "   <idsitpro>" . $idsitpro . "</idsitpro>";
        $xml .= "   <cddindex>" . $cddindex . "</cddindex>";
        $xml .= "   <idtippro>" . $idtippro . "</idtippro>";
        $xml .= "   <idtxfixa>" . $idtxfixa . "</idtxfixa>";
        $xml .= "   <idacumul>" . $idacumul . "</idacumul>";
        $xml .= "   <nommitra>" . $nommitra . "</nommitra>";
        $xml .= "   <indplano>" . $indplano . "</indplano>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $registros = $xmlObj->roottag->tags;

            foreach ($registros as $registro) {
                if ( $registro->tags[0]->cdata == 'OK' ) {            
                    $retorno[] = array(
                        'msg' => $registro->tags[0]->cdata
                    );
                }
            }
        }
    }    
} else if ( $flgopcao == 'E' ) {
   
   // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdprodut"])) {
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';          
    } else {
        $cdProdut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;

        if (!validaInteiro($cdProdut)) {
            $msgErro = 'Produto inv&aacute;lido.';
            $erro = 'S';
        }
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>E</cddopcao>";    
        $xml .= "   <cdprodut>" . $cdProdut . "</cdprodut>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $registros = $xmlObj->roottag->tags[0];
            foreach ($registros as $registro) {
                if ( $registro->tags[0]->cdata == 'OK' ) {
                    $retorno[] = array(
                        'msg' => $registro->tags[0]->cdata
                    );                
                }
            }        
        }
    }
}
echo json_encode(array('rows' => count($retorno), 'records' => $retorno, 'erro' => $erro, 'msg'=> $msgErro));
?>