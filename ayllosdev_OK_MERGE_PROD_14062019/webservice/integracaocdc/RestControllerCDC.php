<?php
/*
 * Entrada - REST dos Convênios CDC
 *
 * @autor: Lucas Reinert
 */

require_once("../../class/xmlfile.php");	
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');

// Capturar nome do serviço e garantir que esteja em lower case
$servico = strtolower($_SERVER["HTTP_SERVICE"]);

if (!file_exists("class_rest_".$servico.".php")){
	// Serviço inválido
	echo json_encode(array('status' => 404
						  ,'dscritic' => 'Serviço não encontrado'));
}else{	
	require_once("class_rest_".$servico.".php");

	$oRestCDC = new RestCDC();
	$oRestCDC->processaRequisicao();
}
?>