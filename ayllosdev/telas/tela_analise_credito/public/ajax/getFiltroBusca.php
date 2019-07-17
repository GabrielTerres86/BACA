<?php
/**
 * User: Bruno Luiz Katjarowski
 * Date: 08/03/2019
 * Time: 09:37
 * Projeto: ailos_prj438_s8
 */

// seta para usar o dominio principal para autenticacao
ini_set('session.cookie_domain', '.cecred.coop.br' );

// novo limite de memoria
ini_set('memory_limit','1000M');

// Increase max_execution_time. If a large pdf fails, increase it even more.
ini_set('max_execution_time', 180);

// Increase this for old PHP versions (like 5.3.3). If a large pdf fails, increase it even more.
ini_set('pcre.backtrack_limit', 1000000);

session_start();

$json 				= $_SESSION['token_json'];
$jsonFiltro			= $_SESSION[$json];
$retorno['data'] 	= $jsonFiltro;
$retorno['ok'] 		= true;

echo json_encode($retorno);
//print_r($retorno['data']);