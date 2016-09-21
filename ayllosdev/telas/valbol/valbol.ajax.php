<?php
/* !
 * FONTE        : valbol_regras.php
 * CRIACAO      : Carlos Rafael Tanholi / CECRED
 * DATA CRIACAO : 24/04/2015
 * OBJETIVO     : Tela VALBOL
 * --------------
 * ALTERACOES   :
 * --------------
 */
session_start();

require_once('validador.class.php');

function somente_numero($aux_valor) {
    $new = "";

    for ($i = 0; $i < strlen($aux_valor); $i++) {
        if (is_numeric($aux_valor[$i])) {
            $new .= $aux_valor[$i];
        }
    }

    if (is_numeric($new)) {
        return $new;
    }
}

$retorno = array();
$erro = 'N';
$msgErro = '';

$aux_dstpdpag = $_REQUEST["aux_dstpdpag"];
$aux_cdbarras = somente_numero($_REQUEST["aux_cdbarras"]);
$aux_lindigi1 = somente_numero($_REQUEST["aux_lindigi1"]);
$aux_lindigi2 = somente_numero($_REQUEST["aux_lindigi2"]);
$aux_lindigi3 = somente_numero($_REQUEST["aux_lindigi3"]);
$aux_lindigi4 = somente_numero($_REQUEST["aux_lindigi4"]);
$aux_lindigi5 = somente_numero($_REQUEST["aux_lindigi5"]);
$aux_cdrepnum = $aux_cdbarras <> "" ? "CB" : "LD";
$aux_repnumer = $aux_cdbarras <> "" ? $aux_cdbarras : $aux_lindigi1 . $aux_lindigi2 . $aux_lindigi3 . $aux_lindigi4 . $aux_lindigi5;

if (trim($aux_repnumer) == "") {
    $erro = 'S';
    $msgErro = 'ATENÇÃO: Dados incorretos ou não informados.';
} else {
    if ($aux_dstpdpag == "titulo") {
        //valida o codigo de barras digitado
        $validador = new valida_titulo($aux_cdrepnum, $aux_repnumer);

        if ($validador->IniciaValidacao()) {
            $retorno[] = array(
                               'vlrdocum' => number_format($validador->getValor(), 2, ",", "."), 
                               'dtvencto' => $validador->getVencimento()
                               );
        } else {
            $erro = 'S';
            $msgErro = str_replace('\\n', '<br/>', $validador->getErro());
        }
    } else if ($aux_dstpdpag == "fatura") {
        $validador = new valida_fatura($aux_cdrepnum, $aux_repnumer);

        if ($validador->IniciaValidacao()) {
            $retorno[] = array(
                               'vlrdocum' => number_format($validador->getValor(), 2, ",", ".")
                              ); 
            
        } else {
            $erro = 'S';
            $msgErro = str_replace('\\n', '<br/>', $validador->getErro());
        }
    }
}

echo json_encode(array('rows' => count($retorno), 'records' => $retorno, 'erro' => $erro, 'msg'=> $msgErro));
?>