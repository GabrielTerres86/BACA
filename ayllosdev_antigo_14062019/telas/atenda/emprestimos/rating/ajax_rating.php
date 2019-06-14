<?php
/*
 * FONTE        : ajax_rating.php
 * CRIACAO      : Luiz Otávio Olinger Momm
 * DATA CRIACAO : 26/02/2019
 * OBJETIVO     : 13638 - Rating - Manutenção/Alteração Nota do Rating na tela Atenda. P450 (Luiz Otávio Olinger Momm - AMCOM)
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

$erro = false;
$msgErro = '';
$flgopcao = (isset($_POST["flgopcao"])) ? $_POST["flgopcao"] : '';

if ($flgopcao == 'salvarRating') { //salva Rating
    // Verifica se os parametros necessarios foram informados
    $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
    $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
    $nrctremp = (isset($_POST["nrctremp"])) ? $_POST["nrctremp"] : 0;
    $nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
    $rating_sugerido = (isset($_POST["notanova"])) ? $_POST["notanova"] : '';
    $rating_justificativa = (isset($_POST["justificativa"])) ? $_POST["justificativa"] : '';

    if (!in_array(strtoupper($rating_sugerido), array('AA', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', ''))) {
        echo json_encode(array('erro' => true, 'msg'=> ('Nova nota de rating inválida')));
        return;
    }

    // se vazio não tem justificativa pois vai para o motor
    if (strlen($rating_justificativa) < 11 && $rating_sugerido != '') {
        echo json_encode(array('erro' => true, 'msg'=> ('Quando nova nota informada, a justificativa deve possuir no mínimo 11 caracteres.')));
        return;
    }

    if ($nrctremp > 0 && $cdcooper > 0 && $nrdconta > 0) {

        // Montar o xml de Requisicao
        $xml = "<Root>";
        $xml .= "<Dados>";
        $xml .= "	<nrcpfcgc></nrcpfcgc>";
        $xml .= "	<nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "	<nrctro>".$nrctremp."</nrctro>";
        $xml .= "	<tpproduto>0</tpproduto>";
        $xml .= "	<rating_sugerido>".$rating_sugerido."</rating_sugerido>";
        $xml .= "	<justificativa>".$rating_justificativa."</justificativa>";
        $xml .= "</Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "TELA_RATMOV", "ALTERARRATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            $erro = true;
        } else {
            $erro = false;
        }
    } else {
        $erro = true;
        $msgErro = 'Não foi possível salvar o rating.';
    }
}
echo json_encode(array('erro' => $erro, 'msg'=> $msgErro));
return;