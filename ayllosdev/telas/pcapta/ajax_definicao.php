<?php
/* !
 * FONTE        : ajax_definicao.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 12/08/2014
 * OBJETIVO     : Ajax de consulta para tela PCAPTA - definicoes
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

$glbvars["nmrotina"] = 'DEFINICAO';

$retorno = array();
$erro = 'N';
$msgErro = '';
$flgopcao = (isset($_POST["flgopcao"])) ? trim($_POST["flgopcao"]) : '';

if  ( $flgopcao == 'CM' ) { //consulta Modalidades
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
    $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 20;
    $subopcao = (isset($_POST["subopcao"])) ? $_POST["subopcao"] : 'C';
    $idtxfixa = (isset($_POST["idtxfixa"])) ? $_POST["idtxfixa"] : 0;
    
    if ( $cdprodut > 0 && $cdcooper > 0 ) {
        
        $idsitmod = 0;
        if ( $subopcao == 'B' ) {
            $idsitmod = 1;
        } else if ( $subopcao == 'D' ) {
            $idsitmod = 2;
        }
        
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
	$xml .= "   <idsitmod>" . $idsitmod . "</idsitmod>";
	$xml .= "   <nrregist>" . $nrregist . "</nrregist>";        
	$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "CMODPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {           
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
        } else {
            $registros = $xmlObj->roottag->tags[0]->tags;
            $qtdregist = $xmlObj->roottag->tags[1]->cdata;
            
            include('tab_definicao.php');
        }   
    }   
    return false;
    
} else if  ( $flgopcao == 'CP' ) { //carrega Politicas
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
    $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 20;
    $subopcao = (isset($_POST["subopcao"])) ? $_POST["subopcao"] : 'C';
    $idtxfixa = (isset($_POST["idtxfixa"])) ? $_POST["idtxfixa"] : 0;
    
    if ( $cdprodut > 0 && $cdcooper > 0 ) {
        
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
	$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
	$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "CPOLCOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {           
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
        } else {
            $registros = $xmlObj->roottag->tags[0]->tags;
            $qtdregist = $xmlObj->roottag->tags[1]->cdata;
            
            include('tab_definicao.php');
        }   
    }   
    return false;
    
} else if  ( $flgopcao == 'C' ) { //consulta Taxa Fixa
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;

    if ( $cdprodut > 0 ) {

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
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
        } else {
            $registros = $xmlObj->roottag->tags;
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'idtxfixa'   => $registro->tags[5]->cdata, //retorna taxa fixa 
                    'nmdindex'   => $registro->tags[7]->cdata //nome do indexador
                );
            }
        }   
    }
} else if  ( $flgopcao == 'CONCAR' ) { // consulta dias de carencia

    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CMODCAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdprodut > 0 ) {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'qtdiacar' => $registro->tags[0]->cdata
                );
            }            
        }
    }    
    
} else if  ( $flgopcao == 'CONPRA' ) { // consulta prazo
    
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $qtdiacar = (isset($_POST["qtdiacar"])) ? $_POST["qtdiacar"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= "   <qtdiacar>" . $qtdiacar . "</qtdiacar>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CMODPRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {        
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdprodut > 0 ) {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'qtdiaprz' => $registro->tags[0]->cdata
                );
            }            
        }
    }    
} else if  ( $flgopcao == 'CONFAI' ) { // consulta faixa
    
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $qtdiacar = (isset($_POST["qtdiacar"])) ? $_POST["qtdiacar"] : 0;
    $qtdiaprz = (isset($_POST["qtdiaprz"])) ? $_POST["qtdiaprz"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= "   <qtdiacar>" . $qtdiacar . "</qtdiacar>";
    $xml .= "   <qtdiaprz>" . $qtdiaprz . "</qtdiaprz>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CMODVFA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdprodut > 0 ) {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'vlrfaixa' => $registro->tags[0]->cdata
                );
            }            
        }
    }    
} else if  ( $flgopcao == 'CONPERTAX' ) { // consulta faixa
    
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $qtdiacar = (isset($_POST["qtdiacar"])) ? $_POST["qtdiacar"] : 0;
    $qtdiaprz = (isset($_POST["qtdiaprz"])) ? $_POST["qtdiaprz"] : 0;
    $vlrfaixa = (isset($_POST["vlrfaixa"])) ? $_POST["vlrfaixa"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= "   <qtdiacar>" . $qtdiacar . "</qtdiacar>";
    $xml .= "   <qtdiaprz>" . $qtdiaprz . "</qtdiaprz>";
    $xml .= "   <vlrfaixa>" . $vlrfaixa . "</vlrfaixa>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CMODPERTAX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdprodut > 0 ) {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'cdmodali' => $registro->tags[0]->cdata,
                    'vlperren' => $registro->tags[1]->cdata,
                    'vltxfixa' => $registro->tags[2]->cdata
                );
            }            
        }
    }    
    
} else if  ( $flgopcao == 'V' ) { // validar
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdcooper"]) || !isset($_POST["cdmodali"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
        $cdmodali = (isset($_POST["cdmodali"])) ? $_POST["cdmodali"] : 0;
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>V</cddopcao>";
        $xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
        $xml .= "   <cdmodali>" . $cdmodali . "</cdmodali>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANMODCOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
        } else {
            $registros = $xmlObj->roottag->tags;
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'modalidade'  => $registro->tags[0]->cdata, //valida existencia da modalidade
                );
            }
        }
    }
} else if  ( $flgopcao == 'I' ) { //inserir
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdcooper"]) || !isset($_POST["cdmodali"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
        $cdmodali = (isset($_POST["cdmodali"])) ? $_POST["cdmodali"] : 0;
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>I</cddopcao>";
        $xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
        $xml .= "   <cdmodali>" . $cdmodali . "</cdmodali>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANMODCOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
            exit();            
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
} else if ( $flgopcao == 'E' || $flgopcao == 'D' || $flgopcao == 'B' ) {
   
   // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdmodali"]) || !isset($_POST["cdcooper"])) {
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';          
    } else {
        $cdmodali = (isset($_POST["cdmodali"])) ? $_POST["cdmodali"] : '';
        $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : '';
    }
    
    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>$flgopcao</cddopcao>";    
        $xml .= "   <cdcooper>$cdcooper</cdcooper>";    
        $xml .= "   <cdmodali>" . $cdmodali . "</cdmodali>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", 'MANMODCOP', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);   
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