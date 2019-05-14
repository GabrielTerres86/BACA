<?php
/**
 * User: Bruno Luiz Katjarowski
 * Date: 08/03/2019
 * Time: 09:37
 * Projeto: ailos_prj438_s8
 */
session_start();
$json = $_SESSION['token_json'];
$jsonFiltro = $_SESSION[$json];
$retorno['data'] = $jsonFiltro;
$retorno['ok'] = true;
echo json_encode($retorno);