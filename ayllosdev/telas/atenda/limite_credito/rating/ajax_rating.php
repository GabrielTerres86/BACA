<?php
/*
 * FONTE        : ajax_rating.php
 * CRIACAO      : Luiz Otávio Olinger Momm
 * DATA CRIACAO : 04/03/2019
 * OBJETIVO     : 13638 - Rating - Manutenção/Alteração Nota do Rating na tela Atenda. P450 (Luiz Otávio Olinger Momm - AMCOM)
 * --------------
 * ALTERACAES   :
 * 001: [15/04/2019] Identificação quando for Analisar e quando for Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM)
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

if ($flgopcao == 'salvarRating' || $flgopcao == 'analisarRating') { //salva Rating
    // Verifica se os parametros necessarios foram informados
    $cdcooper = $glbvars["cdcooper"];
    $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
    $nrcontrato = (isset($_POST["nrcontrato"])) ? $_POST["nrcontrato"] : 0;
    $rating_sugerido = (isset($_POST["notanova"])) ? $_POST["notanova"] : '';
    $rating_justificativa = (isset($_POST["justificativa"])) ? $_POST["justificativa"] : '';
    /* [001] */
    $botao_chamada = (isset($_POST["btntipo"])) ? $_POST["btntipo"] : '';
    /* [001] */

    if (!in_array(strtoupper($rating_sugerido), array('AA', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', ''))) {
        echo json_encode(array('erro' => true, 'msg'=> ('Nova nota de rating inválida')));
        return;
    }

    // se vazio não tem justificativa pois vai para o motor
    if (strlen($rating_justificativa) < 11 && $rating_sugerido != '') {
        echo json_encode(array('erro' => true, 'msg'=> ('Quando nova nota informada, a justificativa deve possuir no mínimo 11 caracteres.')));
        return;
    }

    /* [001] */
    if (!in_array($botao_chamada, array('1', '2', '3'))) {
        echo json_encode(array('erro' => true, 'msg'=> ('Informar a origem do acionamento do Alterar Rating.')));
        return;
    }
    /* [001] */

    if ($nrcontrato > 0 && $nrdconta > 0) {

        // Montar o xml de Requisicao
        $xml = "<Root>";
        $xml .= "<Dados>";
        $xml .= "	<nrcpfcgc></nrcpfcgc>";
        $xml .= "	<nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "	<nrctro>".$nrcontrato."</nrctro>";
        $xml .= "	<tpproduto>1</tpproduto>";
        $xml .= "	<rating_sugerido>".$rating_sugerido."</rating_sugerido>";
        $xml .= "	<justificativa>".$rating_justificativa."</justificativa>";
        $xml .= "   <botao_chamada>".$botao_chamada."</botao_chamada>";
        $xml .= "</Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "TELA_RATMOV", "ALTERARRATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            $msgErro = utf8_encode($msgErro);
            $erro = true;
        } else {
            $erro = false;
        }
    } else {
        $erro = true;
        $msgErro = 'Não foi possível salvar o rating.';
    }
}
echo json_encode(array('erro' => $erro, 'msg'=> ($msgErro)));
return;