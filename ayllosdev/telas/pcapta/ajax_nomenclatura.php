<?php

/* !
 * FONTE        : ajax_nomenclatura.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 26/08/2014
 * OBJETIVO     : Ajax de consulta para tela PCAPTA - nomenclatura dos produtos
 * --------------
 * ALTERAÇÕES   : 23/10/2018 - Inclusão das principais características - Proj. 411.2 - CIS Corporate
 *
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

setVarSession('nmrotina','NOMENCLATURA');

$retorno = array();
$erro = 'N';
$msgErro = '';
$flgopcao = (isset($_POST["flgopcao"])) ? trim($_POST["flgopcao"]) : '';


if  ( $flgopcao == 'C' ) {
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $cdnomenc = (isset($_POST["cdnomenc"])) ? $_POST["cdnomenc"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= "   <cdnomenc>" . $cdnomenc . "</cdnomenc>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CNOMPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $erro = 'S';
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdnomenc > 0 ) {
        
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'cdnomenc' => $registro->tags[0]->cdata,
                    'cdprodut' => $registro->tags[1]->cdata,
                    'dsnomenc' => $registro->tags[2]->cdata,
                    'idsitnom' => $registro->tags[3]->cdata,
                    'qtmincar' => $registro->tags[4]->cdata,
                    'qtmaxcar' => $registro->tags[5]->cdata,
                    'vlminapl' => $registro->tags[6]->cdata,
                    'vlmaxapl' => $registro->tags[7]->cdata,
                    'dscaract' => $registro->tags[8]->cdata,
                    'aplicacao' => $registro->tags[9]->cdata
                );
            }
            
        } else {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'cdnomenc' => $registro->tags[0]->cdata,
                    'dsnomenc' => $registro->tags[1]->cdata
                );
            }            
        }
    }
    
} else if  ( $flgopcao == 'V' ) { // validar
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdprodut"]) || !isset($_POST["dsnomenc"]) || !isset($_POST["qtmincar"]) || 
        !isset($_POST["qtmaxcar"]) || !isset($_POST["vlminapl"]) || !isset($_POST["vlmaxapl"]) || !isset($_POST["idsitnom"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $cdnomenc = (isset($_POST["cdnomenc"]) && trim($_POST["cdnomenc"]) != '' ) ? $_POST["cdnomenc"] : 0;        
        $dsnomenc = (isset($_POST["dsnomenc"])) ? $_POST["dsnomenc"] : '';
        $qtmincar = (isset($_POST["qtmincar"])) ? $_POST["qtmincar"] : 0;
        $qtmaxcar = (isset($_POST["qtmaxcar"])) ? $_POST["qtmaxcar"] : 0;
        $vlminapl = (isset($_POST["vlminapl"])) ? str_replace(',','.',str_replace('.','', $_POST["vlminapl"])) : 0;
        $vlmaxapl = (isset($_POST["vlmaxapl"])) ? str_replace(',','.',str_replace('.','', $_POST["vlmaxapl"])) : 0;
        $dscaract = (isset($_POST["dscaract"])) ? $_POST["dscaract"] : '';
        $idsitnom = (isset($_POST["idsitnom"])) ? $_POST["idsitnom"] : 0;
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>V</cddopcao>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <cdnomenc>" . $cdnomenc . "</cdnomenc>";        
        $xml .= "   <dsnomenc>" . $dsnomenc . "</dsnomenc>";
        $xml .= "   <idsitnom>" . $idsitnom . "</idsitnom>";
        $xml .= "   <qtmincar>" . $qtmincar . "</qtmincar>";
        $xml .= "   <qtmaxcar>" . $qtmaxcar . "</qtmaxcar>";
        $xml .= "   <vlminapl>" . $vlminapl . "</vlminapl>";
        $xml .= "   <vlmaxapl>" . $vlmaxapl . "</vlmaxapl>";
        $xml .= "   <dscaract>" . $dscaract . "</dscaract>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MNOMPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $registros = $xmlObj->roottag->tags;
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'produto'      => $registro->tags[0]->cdata, //verifica a existencia do produto (S|N)
                    'nomenclatura' => $registro->tags[1]->cdata, //verifica se ja existe a nomenclatura com status ativa (S|N)
                    'nom_valcar'   => $registro->tags[2]->cdata, //verifica se ja existe nomenclatura com mesmo valor e carencia (S|N)
                    'carencia'     => $registro->tags[3]->cdata, //valida a carencia maxima > carencia minima (S|N)
                    'valor'        => $registro->tags[4]->cdata, //valida o valor maximo > valor minimo (S|N)
                    'situacao'     => $registro->tags[5]->cdata  //valida a situacao (1-ativa,2-inativa) (S|N)
                );
            }
        }
    }
} else if  ( $flgopcao == 'A' ) { //alterar

    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdprodut"]) || !isset($_POST["dsnomenc"]) || !isset($_POST["qtmincar"]) || 
        !isset($_POST["qtmaxcar"]) || !isset($_POST["vlminapl"]) || !isset($_POST["vlmaxapl"]) || !isset($_POST["idsitnom"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $cdnomenc = (isset($_POST["cdnomenc"])) ? $_POST["cdnomenc"] : 0;
        $dsnomenc = (isset($_POST["dsnomenc"])) ? $_POST["dsnomenc"] : '';
        $qtmincar = (isset($_POST["qtmincar"])) ? $_POST["qtmincar"] : 0;
        $qtmaxcar = (isset($_POST["qtmaxcar"])) ? $_POST["qtmaxcar"] : 0;
        $vlminapl = (isset($_POST["vlminapl"])) ? str_replace(',','.',str_replace('.','', $_POST["vlminapl"])) : 0;
        $vlmaxapl = (isset($_POST["vlmaxapl"])) ? str_replace(',','.',str_replace('.','', $_POST["vlmaxapl"])) : 0;
        $dscaract = (isset($_POST["dscaract"])) ? $_POST["dscaract"] : '';
        $idsitnom = (isset($_POST["idsitnom"])) ? $_POST["idsitnom"] : 0;
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>A</cddopcao>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <cdnomenc>" . $cdnomenc . "</cdnomenc>";
        $xml .= "   <dsnomenc>" . $dsnomenc . "</dsnomenc>";
        $xml .= "   <idsitnom>" . $idsitnom . "</idsitnom>";
        $xml .= "   <qtmincar>" . $qtmincar . "</qtmincar>";
        $xml .= "   <qtmaxcar>" . $qtmaxcar . "</qtmaxcar>";
        $xml .= "   <vlminapl>" . $vlminapl . "</vlminapl>";
        $xml .= "   <vlmaxapl>" . $vlmaxapl . "</vlmaxapl>";
        $xml .= "   <dscaract>" . $dscaract . "</dscaract>";
        $xml .= " </Dados>";
        $xml .= "</Root>";   
        
        $xmlResult = mensageria($xml, "PCAPTA", "MNOMPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
    
} else if  ( $flgopcao == 'I' ) { //inserir
        
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdprodut"]) || !isset($_POST["dsnomenc"]) || !isset($_POST["qtmincar"]) || 
        !isset($_POST["qtmaxcar"]) || !isset($_POST["vlminapl"]) || !isset($_POST["vlmaxapl"]) || !isset($_POST["idsitnom"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $dsnomenc = (isset($_POST["dsnomenc"])) ? $_POST["dsnomenc"] : '';
        $qtmincar = (isset($_POST["qtmincar"])) ? $_POST["qtmincar"] : 0;
        $qtmaxcar = (isset($_POST["qtmaxcar"])) ? $_POST["qtmaxcar"] : 0;
        $vlminapl = (isset($_POST["vlminapl"])) ? str_replace(',','.',str_replace('.','', $_POST["vlminapl"])) : 0;
        $vlmaxapl = (isset($_POST["vlmaxapl"])) ? str_replace(',','.',str_replace('.','', $_POST["vlmaxapl"])) : 0;
        $dscaract = (isset($_POST["dscaract"])) ? $_POST["dscaract"] : '';
        $idsitnom = (isset($_POST["idsitnom"])) ? $_POST["idsitnom"] : 0;
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>I</cddopcao>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <dsnomenc>" . $dsnomenc . "</dsnomenc>";
        $xml .= "   <idsitnom>" . $idsitnom . "</idsitnom>";
        $xml .= "   <qtmincar>" . $qtmincar . "</qtmincar>";
        $xml .= "   <qtmaxcar>" . $qtmaxcar . "</qtmaxcar>";
        $xml .= "   <vlminapl>" . $vlminapl . "</vlminapl>";
        $xml .= "   <vlmaxapl>" . $vlmaxapl . "</vlmaxapl>";
        $xml .= "   <dscaract>" . $dscaract . "</dscaract>";
        $xml .= " </Dados>";
        $xml .= "</Root>";        
        
        $xmlResult = mensageria($xml, "PCAPTA", "MNOMPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
    if (!isset($_POST["cdprodut"]) && !isset($_POST["cdnomenc"])) {
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';          
    } else {
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $cdnomenc = (isset($_POST["cdnomenc"])) ? $_POST["cdnomenc"] : 0;

        if (!validaInteiro($cdprodut) && !validaInteiro($cdnomenc)) {
            $msgErro = 'Produto inv&aacute;lido.';
            $erro = 'S';
        }
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>E</cddopcao>";    
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <cdnomenc>" . $cdnomenc . "</cdnomenc>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MNOMPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $retorno[] = array(
                'msg' => $xmlObj->roottag->tags[0]->cdata
            );
        }
    }
}
echo json_encode(array('rows' => count($retorno), 'records' => $retorno, 'erro' => $erro, 'msg'=> $msgErro));
?>