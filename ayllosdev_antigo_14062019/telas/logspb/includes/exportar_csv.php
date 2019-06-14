<?php
/*
Autor: Bruno luiz katzjarowski - Mout's
Data: 12/11/2018
Ultima alteração:

Alterações:
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

/**
 * @author Bruno Luiz K.;
 * 
 * @param      $string
 * @param bool $desc
 *
 * @return mixed|null|string|string[]
 */
function decodeString($string, $desc = false){
	if($desc){
		$string = html_entity_decode($string, ENT_QUOTES);
		$string = strip_tags($string);
	}
	$codificacaoAtual = mb_detect_encoding($string, 'auto', true);
	$content = mb_convert_encoding($string, 'ISO-8859-1', $codificacaoAtual);
	$content = str_replace(";",".",$content);
	
	return $content;
}


?>