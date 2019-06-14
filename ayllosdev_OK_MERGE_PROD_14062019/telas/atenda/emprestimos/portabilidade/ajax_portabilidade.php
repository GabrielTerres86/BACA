<?php
/*
 * FONTE        : ajax_portabilidade.php
 * CRIACAO      : Carlos Rafael 
 * DATA CRIACAO : 08/06/2015
 * OBJETIVO     : Ajax manipulacao de propostas de portabilidade - emprestimos
 * --------------
 * ALTERACAES   :
 *
 * --------------
 */
session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
isPostMethod();

$erro = 'N';
$msgErro = '';
$flgopcao = (isset($_POST["flgopcao"])) ? $_POST["flgopcao"] : '';

if ($flgopcao == 'CP') { //carrega campos Portabilidade
    // Verifica se os parametros necessarios foram informados
    $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
    $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
    $nrctremp = (isset($_POST["nrctremp"])) ? $_POST["nrctremp"] : 0;
    $tipo_consulta = (isset($_POST["tipo_consulta"])) ? $_POST["tipo_consulta"] : '';

    if ($nrctremp > 0 && $cdcooper > 0 && $nrdconta > 0) {

        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
        $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
        $xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
        $xml .= "   <tipo_consulta>". $tipo_consulta ."</tipo_consulta>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PORTAB_CRED", "CON_PORTAB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Aimaro', '', true);
        } else {
            $registros = $xmlObj->roottag->tags;
            
            foreach ($registros as $registro) {
                $retorno[] = array(
									'nrcontrato_if_origem'   => $registro->tags[1]->cdata, //
									'nrcnpjbase_if_origem'   => $registro->tags[2]->cdata, //
									'nmif_origem'            => $registro->tags[6]->cdata, //
									'cdmodali'               => $registro->tags[7]->cdata, //
									'dssit_portabilidade'    => utf8_encode($registro->tags[8]->cdata),
									'nrunico_portabilidade'  => $registro->tags[9]->cdata
                				  );
            }
        }
    }    
} else if ($flgopcao == 'VP') { //valida Portabilidade
    
    $operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : '';    
    $nrcnpjbase_if_origem = (isset($_POST["nrcnpjbase_if_origem"])) ? preg_replace('/[^0-9]{1,}/', '', $_POST["nrcnpjbase_if_origem"]) : 0;
    $nmif_origem = (isset($_POST["nmif_origem"])) ? $_POST["nmif_origem"] : '';    
    $nrcontrato_if_origem = (isset($_POST["nrcontrato_if_origem"])) ? $_POST["nrcontrato_if_origem"] : 0;    
    $cdmodali_portabilidade = (isset($_POST["cdmodali_portabilidade"])) ? $_POST["cdmodali_portabilidade"] : 0;    
    
    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <operacao>"             . $operacao . "</operacao>";
    $xml .= "   <nrcnpjbase_if_origem>" . $nrcnpjbase_if_origem . "</nrcnpjbase_if_origem>";
    $xml .= "   <nmif_origem>"          . $nmif_origem . "</nmif_origem>";
    $xml .= "   <nrcontrato_if_origem>" . $nrcontrato_if_origem . "</nrcontrato_if_origem>";
    $xml .= "   <cdmodali>"             . $cdmodali_portabilidade . "</cdmodali>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PORTAB_CRED", "VAL_PORTAB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $erro = 'S';
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
    } else {
        $registros = $xmlObj->roottag->tags;
        foreach ($registros as $registro) {
            $retorno[] = array(
                'nrcnpjbase_if_origem'   => $registro->tags[0]->cdata, //
                'nrcontrato_if_origem'   => $registro->tags[1]->cdata, //
                'nmif_origem'            => $registro->tags[2]->cdata, //
                'cdmodali'               => $registro->tags[3]->cdata  //
            );
        }
    }   
} else if ($flgopcao == 'GP') { //grava Portabilidade
    
    $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : '';    
    $nrctremp = (isset($_POST["nrctremp"])) ? $_POST["nrctremp"] : '';    
    $tpoperacao = (isset($_POST["tpoperacao"])) ? $_POST["tpoperacao"] : 1;    
    $nrcnpjbase_if_origem = (isset($_POST["nrcnpjbase_if_origem"])) ? preg_replace('/[^0-9]{1,}/', '', $_POST["nrcnpjbase_if_origem"]) : 0;
    $nmif_origem = (isset($_POST["nmif_origem"])) ? $_POST["nmif_origem"] : '';    
    $nrcontrato_if_origem = (isset($_POST["nrcontrato_if_origem"])) ? $_POST["nrcontrato_if_origem"] : 0;    

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>"             . $glbvars["cdcooper"] . "</cdcooper>";
    $xml .= "   <nrdconta>"             . $nrdconta . "</nrdconta>";
    $xml .= "   <nrctremp>"             . $nrctremp . "</nrctremp>";
    $xml .= "   <tpoperacao>"           . $tpoperacao . "</tpoperacao>";
    $xml .= "   <nrcnpjbase_if_origem>" . $nrcnpjbase_if_origem . "</nrcnpjbase_if_origem>";
    $xml .= "   <nmif_origem>"          . $nmif_origem . "</nmif_origem>";
    $xml .= "   <nrcontrato_if_origem>" . $nrcontrato_if_origem . "</nrcontrato_if_origem>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PORTAB_CRED", "CAD_PORTAB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $erro = 'S';
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
    }  

} else if ($flgopcao == 'CF') { //consulta finalidade

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";    
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PORTAB_CRED", "CON_FIN_PORTAB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $erro = 'S';
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }

    } else {    
        $registros = $xmlObj->roottag->tags;
        foreach ($registros as $registro) {
            $retorno[] = array(
                'cdfinemp'   => $registro->tags[0]->cdata, //
                'dsfinemp'   => $registro->tags[1]->cdata
            );
        }
		
		if ( count($retorno) == 0 ) {
			$msgErro = utf8_encode('Finalidade de Portabilidade nao cadastrada');
			$erro = 'S';
		}	
    }
    
}
echo json_encode(array('rows' => count($retorno), 'records' => $retorno, 'erro' => $erro, 'msg'=> $msgErro));