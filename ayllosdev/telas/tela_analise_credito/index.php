<?php
/**
 * User: Bruno Luiz Katjarowski
 * Date: 22/03/2019
 * Time: 11:07
 * Projeto: ailos_prj438_s8
 */
// envia o usuário para o diretório public/

//Atualiza parametros
//Bruno Luiz Katzjarowski - Mout's  - 07/03/2019
$strParametros = "";
if(count($_GET) > 0){
    var_dump($_GET);
    foreach($_GET as $key => $value){
        reset($_GET);
        if ($key === key($_GET))
            $strParametros .= '?';
        $strParametros .= $key."=".$value;
        end($_GET);
        if (!($key === key($_GET)))
            $strParametros .= '&';
    }
}

header('Location: public/'.$strParametros);