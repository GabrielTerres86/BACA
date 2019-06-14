<?php
/*
Autor: Bruno luiz katzjarowski - Mout's
Data: 12/11/2018
Ultima alteração:

Alterações:
Data: 03/05/2019 : INC0011194 :Foi removido o método "function decodeString" Thiago Fronza - Mout'S  
*/
define("PULAR_LINHA", "\n");
define("DELIMITAR_COLUNA", ";");

/**
 * @author Bruno Luiz K.;
 * @param string $fileName
 * @param null   $cabecalho
 * @param null   $valores
 */
function writeArchive($fileName = "archive", $cabecalho = null, $valores = null){
	
	$filename = sprintf($fileName.'_%s.csv', date('Y-m-d H-i'));
	
	$tmpName = tempnam(sys_get_temp_dir(), 'data');
	$file = fopen($tmpName, 'w');
	
	fputcsv($file, $cabecalho, DELIMITAR_COLUNA);
	foreach ($valores as $val){
		fputcsv($file, $val, DELIMITAR_COLUNA);
	}
	fclose($file);
	
	/* Abre uma chamada especifica somente para este arquivo temp */
	header('Content-Description: File Transfer');
	header('Content-Type: text/csv');
	header('Content-Disposition: attachment; filename='.$filename);
	ob_end_clean(); //finalizar buffer sem enviar
	header('Content-Transfer-Encoding: binary');
	header('Expires: 0');
	header('Cache-Control: must-revalidate');
	header('Pragma: public');
	header('Content-Length: ' . filesize($tmpName));
	
	//ob_clean();//finalizar buffer
	flush(); //descarregar o buffer acumulado
	readfile($tmpName); //ler arquivo/enviar
	unlink($tmpName); //deletar arquivo temporario
	exit();
}

?>