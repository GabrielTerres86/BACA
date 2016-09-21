<?php
/*
 * Entrada - REST da /webjud
 *
 * @autor: Guilherme/SUPERO
 */
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once("class_rest_webjud.php");

$oRestWebjud = new RestWebjud();
$oRestWebjud->processaRequisicao();

?>