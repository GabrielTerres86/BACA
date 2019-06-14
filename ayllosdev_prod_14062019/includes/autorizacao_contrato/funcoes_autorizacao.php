<?php
/*
Autor: Bruno Luiz Katzjarowski - Mout's;
Data: 18/02/2019;
ultima alteração:

*/    
    
function getDscomplementoDctror($cdopcao,$dados){

    $tipoOpcao = "";
    switch($cdopcao){
        case 'I':
            $tipoOpcao = "Inclusao";
            break;
        case 'A':
            $tipoOpcao = "Alteracao";
            break;
        case 'E':
            $tipoOpcao = "Cancelamento";
            break;
    }
    $retorno = $tipoOpcao;

    $retorno .= '#'.$dados["cdbanchq"];
    $retorno .= '#'.$dados["cdagechq"];
    $retorno .= '#'.$dados["nrdconta"];
    $retorno .= '#'.$dados["nrinichq"];
    $retorno .= '#'.(isset($dados["nrfinchq"]) ? $dados["nrfinchq"] : '0'  );

    return $retorno;
}


function getDscomplementoMantal($dados){
    global $nrdconta;

    $retorno = "Inclusao";
    $retorno .= '#'.$dados['cdbanchq'];
    $retorno .= '#'.$dados['cdagechq'];
    $retorno .= '#'.$nrdconta;
    $retorno .= '#'.$dados['nrinichq'];
    $retorno .= '#'.$dados['nrfimchq'];
    return $retorno;
}

?>