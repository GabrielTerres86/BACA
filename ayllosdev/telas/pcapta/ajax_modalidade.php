<?php
/* !
 * FONTE        : ajax_produtos.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 01/08/2014
 * OBJETIVO     : Ajax de consulta para tela PCAPTA - modalidades
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

setVarSession('nmrotina','MODALIDADE');

$retorno = array();
$erro = 'N';
$msgErro = '';
$flgopcao = (isset($_POST["flgopcao"])) ? trim($_POST["flgopcao"]) : '';

if  ( $flgopcao == 'CM' ) { //consulta Modalidades
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 20;
    $subopcao = (isset($_POST["subopcao"])) ? $_POST["subopcao"] : 'C';
    $idtxfixa = (isset($_POST["idtxfixa"])) ? $_POST["idtxfixa"] : 0;
    
    if ( $cdprodut > 0 ) {

        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
	$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
	$xml .= "   <nrregist>" . $nrregist . "</nrregist>";        
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "CMODAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $registros = $xmlObj->roottag->tags[0]->tags;
            $qtdregist = $xmlObj->roottag->tags[1]->cdata;
            
            include('tab_modalidade.php');
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
            $erro = 'S';
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
} else if  ( $flgopcao == 'V' ) { // validar
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdprodut"]) || !isset($_POST["qtdiacar"]) || !isset($_POST["qtdiaprz"])
        || !isset($_POST["vlrfaixa"]) || !isset($_POST["vlperren"]) || !isset($_POST["vltxfixa"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $qtdiacar = (isset($_POST["qtdiacar"])) ? $_POST["qtdiacar"] : 0;
        $qtdiaprz = (isset($_POST["qtdiaprz"])) ? $_POST["qtdiaprz"] : 0;       
        $vlrfaixa = (isset($_POST["vlrfaixa"])) ? str_replace(',','.',str_replace('.','', $_POST["vlrfaixa"]) ) : 0;
        $vlperren = (isset($_POST["vlperren"])) ? str_replace(',','.',str_replace('.','', $_POST["vlperren"]) ) : 0;
        $vltxfixa = (isset($_POST["vltxfixa"])) ? str_replace(',','.',str_replace('.','', $_POST["vltxfixa"]) ) : 0;
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>V</cddopcao>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <qtdiacar>" . $qtdiacar . "</qtdiacar>";
        $xml .= "   <qtdiaprz>" . $qtdiaprz . "</qtdiaprz>";
        $xml .= "   <vlrfaixa>" . $vlrfaixa . "</vlrfaixa>";
        $xml .= "   <vlperren>" . $vlperren . "</vlperren>";
        $xml .= "   <vltxfixa>" . $vltxfixa . "</vltxfixa>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANMOD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            $erro = 'S';
        } else {
            $registros = $xmlObj->roottag->tags;

            foreach ($registros as $registro) {
                $retorno[] = array(
                    'produto'     => $registro->tags[0]->cdata, //valida existencia do produto
                    'modalidade'  => $registro->tags[1]->cdata, //valida existencia da modalidade
                    'carencia'    => $registro->tags[2]->cdata, //valida carencia >= 30
                    'prazo'       => $registro->tags[3]->cdata, //valida prazo >= carencia
                    'taxa_fixa'   => $registro->tags[4]->cdata, //retorna taxa fixa S|N
                    'taxa_zerada' => $registro->tags[5]->cdata, //Se for taxa fixa, não permitir informar taxa zerada                
                    'percentual_zerado' => $registro->tags[6]->cdata, //se for sem taxa fixa, não permitir informar percentual de rentabilidade zerado
                    'rentabilidade'   => $registro->tags[7]->cdata //verifica se ja existe modalidade cadastrada com valor >= e %rentabilidade inferior                    
                );
            }
        }
    }
} else if  ( $flgopcao == 'I' ) { //inserir
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdprodut"]) || !isset($_POST["qtdiacar"]) || !isset($_POST["qtdiaprz"])
        || !isset($_POST["vlrfaixa"]) || !isset($_POST["vlperren"]) || !isset($_POST["vltxfixa"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $qtdiacar = (isset($_POST["qtdiacar"])) ? $_POST["qtdiacar"] : 0;
        $qtdiaprz = (isset($_POST["qtdiaprz"])) ? $_POST["qtdiaprz"] : 0;
        $vlrfaixa = (isset($_POST["vlrfaixa"])) ? str_replace(',','.',str_replace('.','', $_POST["vlrfaixa"]) ) : 0;
        $vlperren = (isset($_POST["vlperren"])) ? str_replace(',','.',str_replace('.','', $_POST["vlperren"]) ) : 0;
        $vltxfixa = (isset($_POST["vltxfixa"])) ? str_replace(',','.',str_replace('.','', $_POST["vltxfixa"]) ) : 0;
    }   

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>I</cddopcao>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <qtdiacar>" . $qtdiacar . "</qtdiacar>";
        $xml .= "   <qtdiaprz>" . $qtdiaprz . "</qtdiaprz>";
        $xml .= "   <vlrfaixa>" . $vlrfaixa . "</vlrfaixa>";
        $xml .= "   <vlperren>" . $vlperren . "</vlperren>";
        $xml .= "   <vltxfixa>" . $vltxfixa . "</vltxfixa>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANMOD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
    if (!isset($_POST["cdmodali"])) {
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';          
    } else {
        $cdmodali = (isset($_POST["cdmodali"])) ? $_POST["cdmodali"] : '';
    }
    
    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>E</cddopcao>";    
        $xml .= "   <cdmodali>" . $cdmodali . "</cdmodali>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", 'MANMOD', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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